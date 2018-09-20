function get_strategies(config_struct)
% GETSTRATEGIES - get strategies
% 
% INPUT: 
%  Variable name: config_struct
%  Size: 1x1
%  Class: struct
%  Description: Fields correspond to constants and hyperparameters. 
%  Fields: 
%  - out_path: (string) path for saving MATLAB output
%  - aviPath: (string) path to the AVI files
%  - graphicsPath: (string) path to MATALB graphical output
%  - trackPath: (string) path to segmentation results
%  - manualAnnotationsPath: (string) path to manual annotations
%  - timestamps_file_name_<dataset>: (string) file name with path of 
%      timestamps file name for each data-set <dataset> of the analysis
%  - folders_<dataset>: (cell array) string folder names which belong to 
%      each data-set <dataset> of the analysis
%  - tasks: (cell array) string identifiers for different tasks
%  - FOV: (double) size of field of view in mm^2
%  - Npix: (double) number of pixels per row/column in the imaging plane
%  - framespersec_<dataset>: (double) frame rate of reconstructed real-time
%      magnetic resonance imaging videos in frames per second for each 
%      data-set <dataset> of the analysis
%  - ncl: (double array) entries are (i) the number of constriction 
%      locations at the hard and soft palate and (ii) the number of 
%      constriction locations at the hypopharynx (not including the 
%      nasopharynx).
%  - f: (double) hyperparameter which determines the percent of data used 
%      in locally weighted linear regression estimator of the jacobian; 
%      multiply f by 100 to obtain the percentage
%  - verbose: controls non-essential graphical and text output
% 
%  Variable name: folder
%  Size: arbitrary
%  Class: char
%  Description: determines which participant/scan of the data-set to 
%    analyze
% 
% FUNCTION OUTPUT:
%  Variable name: strategies
%  Size: 1x1
%  Class: struct
%  Description: Struct with the following fields.
%  - jaw: Nx6 array of double; entries are jaw contributions to change in
%  each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - lip: Nx6 array of double; entries are lip contributions to change in
%  each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - tng: Nx6 array of double; entries are tongue contributions to change 
%  in each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - tng: Nx6 array of double; entries are velum contributions to change 
%  in each of 6 constriction degrees (columns) in N real-time magnetic 
%  resonance imaging video frames (rows)
%  - dz: Nx6 array of double; entries are change in each of 6 constriction 
%  degrees (columns) in N real-time magnetic resonance imaging video frames
%  (rows)
%  - dw: Nx8 array of double; entries are change in 8 factor coefficients 
%  (columns) in N real-time magnetic resonance imaging video frames (rows)
%  - cl: (cell array of strings) identifier for the 6 places of 
%  articulation
% 
% SAVED OUTPUT: 
%  none
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Dec. 20, 2016

% Load contour data, constriction degree measurements, and factors
load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f))),'contour_data')

disp('Computing articulator strategies')

% Get weights.
X = [contour_data.X, contour_data.Y];
X = X - mean(X);
W = X*pinv(contour_data.U_gfa');
nw = size(W,2);

n = length(contour_data.tv{1}.cd); % number of video frames
nz = length(contour_data.tv);
Z = zeros(n,nz);
for i=1:nz
    % Get constriction degrees.
    Z(:,i) = contour_data.tv{i}.cd;
end

% Use central difference formula to get time derivative of weights and
% constriction degrees. 
[~,dwdt] = get_grad(Z,W,1,contour_data.files);

% Get q nearest neighbors of each articulator parameter value.
fn = round(config_struct.f*n);
[idx, dist] = knnsearch(W,W,'dist','euclidean','K',fn);

% Initialize constants.
jaw_idxs = 1:config_struct.q.jaw;
tng_idxs = (config_struct.q.jaw+1):(config_struct.q.jaw+config_struct.q.tng);
lip_idxs = (config_struct.q.jaw+config_struct.q.tng+1):(config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip);
vel_idxs = (config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+1):(config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+config_struct.q.vel);
Pjaw = zeros(nw);
Pjaw(jaw_idxs,jaw_idxs) = eye(length(jaw_idxs));
Ptng = zeros(nw);
Ptng(tng_idxs,tng_idxs) = eye(length(tng_idxs));
Plip = zeros(nw);
Plip(lip_idxs,lip_idxs) = eye(length(lip_idxs));
Pvel = zeros(nw);
Pvel(vel_idxs,vel_idxs) = eye(length(vel_idxs));

% Initialize containers.
jaw = zeros(n,nz);
lip = zeros(n,nz);
tng = zeros(n,nz);
vel = zeros(n,nz);

for i=1:n
    % Estimate the jacobian J of the forward map at point w(i,:)
    G = lscov([ones(length(idx(i,:)),1) W(idx(i,:),:)], Z(idx(i,:),:), ...
        arrayfun(@(u) weight_fun(u), dist(i,:)./dist(i,end)));
    J = G(2:end,:)';

    % Determine the contributions of articulators to change in
    % constriction degree.
    jaw(i,:) = J*Pjaw*dwdt(i,:)';
    lip(i,:) = J*Plip*dwdt(i,:)';
    tng(i,:) = J*Ptng*dwdt(i,:)';
    vel(i,:) = J*Pvel*dwdt(i,:)';
end

% initialize task variable-file name associations
biomarker = [];
try
    % read in table that associates file names codes (column one, 
    % 'file_name' to task variables (column two, 'task_variable')
    tv_key = readtable(fullfile(config_struct.manual_annotations_path,'tv_key.csv'));
    file_list_key = tv_key.file_name;
    task_variable_key = tv_key.task_variable;
    
    % establish correspondence between the six task variables and the 
    % numerical indices 1,2,3,4,5,6
    task_variable_num_ids = 1:6;
    task_variable_string_ids = {'bilabial','alveolar','palatal','velar','pharyngeal','velopharyngeal'};
    
    % initialize matrix with three columns:
    % - column 1: file number
    % - column 2: task variable numerical id
    % - column 3: biomarker value
    biomarker = zeros(0,3);
    
    % for each task variable
    for i=1:length(task_variable_string_ids)
        
        % for each file name code that is specified for that task variable
        idx = find(strcmp(task_variable_key,task_variable_string_ids{i}));
        for j=1:length(idx)
            
            % get the file numbers that match the file name code
            file_nums = find(cellfun(@(x) contains(x,file_list_key{idx(j)}),contour_data.file_list))';
            
            % get biomarkers that match file numbers in file_nums
            bms = ones(size(file_nums));
            for k=1:length(file_nums)
                if task_variable_num_ids(i) == 1 % compute jaw/(jaw+lips)
                    bm = diff(quantile(cumsum(jaw(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])) ...
                        / (diff(quantile(cumsum(jaw(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])) ...
                        + diff(quantile(cumsum(lip(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])));
                else % compute jaw/(jaw+tongue)
                    bm = diff(quantile(cumsum(jaw(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])) ...
                        / (diff(quantile(cumsum(jaw(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])) ...
                        + diff(quantile(cumsum(tng(contour_data.files==file_nums(k),task_variable_num_ids(i))),[0.1 0.9])));
                end
                bms(k) = bm;
            end
            
            % concatenate file numbers, task variables, and biomarker
            % values onto the biomarker container
            biomarker = cat(1,biomarker,[file_nums,repmat(task_variable_num_ids(i),size(file_nums,1),1),bms]);
        end
    end
    biomarker = table(biomarker(:,1),biomarker(:,2),biomarker(:,3),'VariableNames',{'file','tv','bm'});
catch
    warning('Could not open or process task variable key file\n  %s\nCheck that file exists and has columns ''file_name'' and ''task_variable''',...
        fullfile(config_struct.manual_annotations_path,'tv_key.csv'))
end

contour_data.strategies = struct('jaw',jaw,'lip',lip,'tng',tng,'vel',vel,'biomarker',biomarker);

save(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f))),'contour_data')

end