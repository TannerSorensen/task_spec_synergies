function get_map(configStruct,varargin)
% WRAPFWDMAP - estimate the forward kinematic map
%
% input
%  PATHOUT - path to save output
%  CRIT - error tolerance for linear approx.
%  FRAMERATE - frame rate assuming two TR per frame
%  VERBOSE - controls output to MATLAB terminal
%
% Last Updated: Oct. 13, 2016
%
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California

if nargin < 2
    q = struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2);
elseif nargin == 2
    q = varargin{1};
else
    q = struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2);
    warning(['Function get_map.m was called with %d input arguments,' ...
        ' but requires 1 (optionally 2)'],nargin)
end

% load task variables and weights for subjects SUBJ
out_path = configStruct.out_path;
frames_per_sec = configStruct.frames_per_sec;
crit = 0.5;

load(fullfile(out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)))

nf = 8;
nz = 6;
nObs = length(contour_data.tvsim{1}.cd);

z=NaN(nObs,nz);
%flag = ones(nObs,1);
for j=1:nz
    z(:,j) = contour_data.tvsim{j}.cd;
%     for i=1:nObs
%         if z(i,j) == 0
%             flag(i) = 0; continue;
%         end;
%     end;
end
w=contour_data.weights(:,1:nf);


%z = z(flag > 0,:);
%w = w(flag > 0,:);

[dzdt,dwdt] = getGrad(z,w,frames_per_sec,contour_data.files);


disp('Making forward map')

% initialize
Nobs = size(z,1);
lib = {true(Nobs,1)};       % library has one cluster for whole data-set
centers = zeros(0);         % center container
fwd = cell(0);              % forward map container
jac = cell(0);              % jacobian container
jacDot = cell(0);           % time-derivative of jacobian container
clusterInd = zeros(Nobs,1); % cluster membership indicator
linInd = zeros(0);          % cluster linearity indicator

% clustering parameters
minSize = size(z,2)+1;      % minimum cluster size (no. elements)
k = 2;                      % clusters break in two

while ~isempty(lib)
    % pick out the next cluster
    curCluster = lib{1};
    
    % remove current cluster from library
    rem = cellfun(@(x) all(x==curCluster), lib);
    lib = lib(~rem);
    
    % do linearity test
    [linear,dzdw,resid] = linearityTest(z(curCluster,:), w(curCluster,:), crit);
    
    if linear
        % add center and jac to containers
        [centers,fwd,jac,jacDot,clusterInd,linInd] = addCluster(curCluster,dzdt,dwdt,z,w,dzdw,resid,centers,fwd,jac,jacDot,clusterInd,linInd,linear);
    else
        % break cluster into k smaller clusters
        [lib,centers,fwd,jac,jacDot,clusterInd,linInd] = breakCluster(curCluster,lib,dzdt,dwdt,z,w,k,minSize,centers,fwd,jac,jacDot,clusterInd,dzdw,resid,linInd,linear);
    end
end

% Diagnostic information
fprintf(1,['\n*****\nNo. observed data-points: %d\n',...
    'Linearity criterion: %.2f\n',...
    'Minimum cluster size: %d\n',...
    'No. clusters: %d\n',...
    'No. clusters per observed data-point: %.3f\n',...
    'Percent of clusters which are linear: %.0f%%\n*****\n'],...
    Nobs, crit, minSize, size(centers,1), size(centers,1)/Nobs, 100*sum(linInd)/size(centers,1));

contour_data.centers = centers;
contour_data.fwd = fwd;
contour_data.jac = jac;
contour_data.jacDot = jacDot;
contour_data.Nobs = Nobs;
contour_data.crit = crit;
contour_data.minSize = minSize;
contour_data.nClusters = size(centers,1);
contour_data.linear = linInd;
contour_data.nLinClusters = sum(linInd);

save(fullfile(configStruct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)),'contour_data')

end