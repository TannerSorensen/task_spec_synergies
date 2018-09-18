function calc_rms_error(pathOut,nf)
% CALC_RMS_ERROR - calculate root mean square error of the approximation by
% factor weights and of the approximation by inverting the forward
% kinematic map.
% 
% input:
%  PATHOUT - path to save output
%  NF - number of factors
% 
% Last Updated: Nov. 22, 2016
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California

load(fullfile(pathOut, 'clusters.mat'))
subj = fields(clusters);
nDir = length(subj);
total_nf = nf.nJaw + nf.nTng + nf.nLip + nf.nVel;
load(fullfile(pathOut, 'gfa.mat'))
load(fullfile(pathOut, 'tv.mat'))
load(fullfile(pathOut, 'contourdata.mat'))

for h=1:nDir
    
    nz = length(tv.(subj{h}).tv);
    
    disp(['Calculating RMS error for subject ' subj{h}])
    
    % subject specific xy-coordinates
    xyo = [contourdata.(subj{h}).X contourdata.(subj{h}).Y];
    [nObs,d]=size(xyo);
    
    % initialize data structures
    squared_error_z = zeros(nObs,d);
    squared_error_w = zeros(nObs,d);
    xy_z = zeros(nObs,d);
    xy_w = zeros(nObs,d);
    
    % subject specific weights and constriction variables
    weights = gfa.(subj{h}).weights;
    parameters = gfa.(subj{h}).parameters(:,1:total_nf)';
    nheadf = size(gfa.(subj{h}).weights,2)-total_nf;
    sigma = std(weights);
    z=NaN(nz,nObs);
    for j=1:nz
        z(j,:) = tv.(subj{h}).tv{j}.cd;
    end
    
    for i=1:nObs
        indx = getNearestCluster(parameters(:,i),clusters.(subj{h}).centers,total_nf);
        F = clusters.(subj{h}).fwd{indx};
        wHat = pinv(F)*z(:,i);
        wHat = [wHat(2:end);zeros(nheadf,1)];
        
        xy_z(i,:) = weights_to_vtshape(sigma.*wHat', ...
            gfa.(subj{h}).mean_vtshape, gfa.(subj{h}).U_gfa);
        squared_error_z(i,:) = (xy_z(i,:)-xyo(i,:)).^2;
        
        xy_w(i,:) = weights_to_vtshape(weights(i,:),...
             gfa.(subj{h}).mean_vtshape, gfa.(subj{h}).U_gfa);
        squared_error_w(i,:) = (xy_w(i,:)-xyo(i,:)).^2;
    end
    
    rms_error_z = sqrt(mean(squared_error_z,1));
    rms_error_w = sqrt(mean(squared_error_w,1));

    selectSegments=[1 2 3 4 7 12 15];

    sections=gfa.(subj{h}).SectionsID;

    segmentIndices=find(ismember(sections,selectSegments));
    
    mean_rms_oversegment_z = mean(rms_error_z(segmentIndices)); % in mm
    mean_rms_oversegment_w = mean(rms_error_w(segmentIndices)); % in mm
    
    disp('RMS over selected segments: ')
    disp(['w to original - ' num2str(mean_rms_oversegment_w) ' mm']);
    disp(['z to original - ' num2str(mean_rms_oversegment_z) ' mm']);
    
    rms.(subj{h}).mean_rms_oversegment_z = mean_rms_oversegment_z;
    rms.(subj{h}).mean_rms_oversegment_w = mean_rms_oversegment_w;
end

save(fullfile(pathOut, 'rms.mat'),'rms')

end