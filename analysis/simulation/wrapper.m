% WRAPPER - wraps function MAIN, which estimates the forward kinematic map
% and runs simulations
% 
% Constriction locations can be set manually by running TVLOCS.m before 
% WRAPPER using the following command in the MATLAB terminal:
%   >> tvlocs(config.mat_path)
% Note that the relevant config file must be loaded. In order for the
% manually set constriction locations to be used, set ncl in the config
% file to an empty array. Otherwise, constriction locations are discovered
% automatically. 
% 
% Last Updated: Nov. 18, 2016
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California

addpath(genpath(pwd))                % add subdirectories to MATLAB path
dataset = 'var';

outPath = configStruct.outPath;
load(fullfile(outPath,sprintf('tv_%s',dataset)))
load(fullfile(outPath,sprintf('U_gfa_%s',dataset)))
load(fullfile(outPath,sprintf('contourdata_%s',dataset)))

% path variables
trackPath = configStruct.trackPath;       % path to track files
outPath = configStruct.outPath;           % path to save output
graphicsPath = configStruct.graphicsPath; % path to save graphics

% MRI parameters
frameRate = configStruct.framespersec_var;% frame rate

% other
ncl = configStruct.ncl;                   % number of constriction locations at 
                                    %  (1) palate, (2) hypopharynx
nf = 8;                     % number of factors in factor model
verbose = false;                    % controls output to MATLAB terminal

% estimate forward kinematic map, run simulations
folders = configStruct.(sprintf('folders_%s',dataset));

% parameters of the simulation
nZ = 6;
nPhi = 8;
omega = zeros(nZ,1);   % natural frequencies of task variables
z0 = [0 0 0 0 0 0]';   % targets for LA, alvCD, palCD, velCD, pharCD, VEL
W = eye(nPhi);
time = 0.2;            % time in sec
n_frames = 10;        % No. frames in which to linearize ODE
h2 = time./n_frames;
h1 = 0.1*h2;        % time step
phiInit = zeros(2*nPhi,1);
f = configStruct.f;

for i=1:length(folders)
    for j=1:nZ
        if j==1
            z = zeros(length(tv.(sprintf('participant_%s',folders{i})).tv{j}.cd),nZ); 
        end
        z(:,j) = tv.(sprintf('participant_%s',folders{i})).tv{j}.cd;
    end
    
    % Get weights.
    xy = [contourdata.(sprintf('participant_%s',folders{i})).X, contourdata.(sprintf('participant_%s',folders{i})).Y];
    [xy,mean_vtshape] = zscore(xy);
    phi = xy*U_gfa.(sprintf('participant_%s',folders{i}));
    [phi,mu,sigma] = zscore(phi);
    
    % Use central difference formula to get time derivative of weights and
    % constriction degrees. 
    [dzdt,dphidt] = getGrad(z,phi,1,contourdata.(sprintf('participant_%s',folders{i})).File);
    
    for k=1:nZ
        omega(k) = 50;
        [t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,nZ,nPhi,z,phi,dzdt,dphidt,f);
        omega(k) = 0;

        % create video
        fnam=sprintf('simulation_video_%d_%d.avi',i,k);
        v = VideoWriter(fullfile(graphicsPath, fnam));
        v.FrameRate = 24;
        open(v)

        figID = figure('Color','w');
        for j=round(linspace(1,size(phiOut,2),2*24))

            xy_data = weights_to_vtshape(sigma.*phiOut(1:nPhi,j)', mean_vtshape, U_gfa.(sprintf('participant_%s',folders{i})));
            plot_from_xy(xy_data,contourdata.(sprintf('participant_%s',folders{i})).SectionsID,'k');
            axis square, axis tight, axis off

            frame = getframe(figID,[0 0 560 420]);
            writeVideo(v,frame)
            clf
        end
        close(v)
        close(figID)
    end
end

