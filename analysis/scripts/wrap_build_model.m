% WRAP_BUILD_MODEL This script generates contour data, factors, and
% constriction degrees for every non-hidden directory in the directory 
% SUBJECT_DIR. 
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

% add to path the functions called during the analysis
addpath(genpath(fullfile('..','span_contour_processing','functions')))

% obtain a cell array subject_list whose entries are the string subject
% identifiers.
subject_dir = fullfile('..','segmentation_results');
subject_list = dir(subject_dir);
subject_list = {subject_list.name};
subject_list = subject_list(cellfun(@(x) ~startsWith(x,'.'), subject_list)); % omit hidden directories

% set regex expression into which the string subject identifiers will be
% substituted in to obtain paths to segmentation results
% (master_track_path), outputs of the analysis (master_out_path), and 
% manual annotations for the analysis (master_manual_annotations_path)
config_struct = config;
master_track_path = config_struct.track_path;
master_out_path = config_struct.out_path;
master_manual_annotations_path = config_struct.manual_annotations_path;

% set the correspondence between file name templates (e.g., aia, apa, etc.)
% and places of articulation (e.g., palatal, bilabial, etc.)
tv_key_tab = table({'aia','aia','apa','ata','aka'}',...
        {'palatal','pharyngeal','bilabial','alveolar','velar'}',...
        'VariableNames',{'file_name','task_variable'});

% set the parameters of the factor analysis
jaw_fac = [1 2 3];
tng_fac = [4 6 8];
lip_fac = 3;
q_init = struct('jaw',jaw_fac(1),'tng',tng_fac(1),'lip',2,'vel',1,'lar',2);
variant_switch = 'sorensen2018';

% set the f values to test
f = 0.2:0.1:0.9;

cluster=get_SLURM_cluster('--time=23:59:59');
parpool(8)

parfor i=1:length(subject_list)
    fprintf(1,'subject %s (%d/%d)\n', subject_list{i},i,length(subject_list))
    
    % set the constant parameters of the analysis
    config_struct = config;
    
    % substitute the participant string identifier into the path. 
    config_struct.track_path = strrep(master_track_path,'%s',subject_list{i});
    config_struct.out_path = strrep(master_out_path,'%s',subject_list{i});
    config_struct.manual_annotations_path = strrep(master_manual_annotations_path,'%s',subject_list{i});
    
    % verify that the directory containing segmentation results exists
    if ~exist(config_struct.track_path,'dir')
        warning(['The directory containing segmentation results does not exist. ',...
            'Create directory\n  %s\nor change the directory name in the file config.m'],...
            config_struct.track_path)
    end

    % make directory for outputs, if the directory does not exist
    if ~exist(config_struct.out_path,'dir')
        mkdir(config_struct.out_path)
    end
    
    % determine if the file exists
    config_struct.q = q_init;
    init_contour_data_file_name = fullfile(config_struct.out_path,...
        sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
        config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f)));
    exist_flag = exist(init_contour_data_file_name,'file') ~= 2;
    
    % the call to make_contour_data below generates the file 
    % 'contourdata_jawN_tngN_lipN_velN_larN_fM.mat.mat' in the directory 
    % config_struct.out_path, where N are numbers of factors and M is
    % neighborhood size (100*f = percent of training data in neighborhood)
    if exist_flag
        make_contour_data(config_struct)
    end
    
    % obtain manual annotations for pharynx location, or load them if they
    % already exist
    if exist(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'file') == 0
        make_manual_annotations(config_struct,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
            config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f)));
    end
    tmp_struct = load(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'phar_idx');
    phar_idx = tmp_struct.phar_idx;
    
    tv_key_path_name = strrep(master_manual_annotations_path,'%s',subject_list{i});
    if ~exist(tv_key_path_name,'dir')
        mkdir(tv_key_path_name)
    end
    writetable(tv_key_tab,fullfile(tv_key_path_name,'tv_key.csv'))
    
    % measure task variables
    if exist_flag
        get_tv(config_struct,false,phar_idx)
    end
    
    % obtain models for different f parameter values
    for ell=1:length(f)
        config_struct.f = f(ell);
        % obtain models with different factor analysis parameterizations
        for j=1:length(jaw_fac)
            for k=1:length(tng_fac)
                config_struct.q = struct('jaw',jaw_fac(j),'tng',tng_fac(k),'lip',2,'vel',1,'lar',2);
                build_model(config_struct,init_contour_data_file_name,variant_switch)
            end
            for k=1:length(lip_fac)
                config_struct.q = struct('jaw',jaw_fac(j),'tng',4,'lip',lip_fac(k),'vel',1,'lar',2);
                build_model(config_struct,init_contour_data_file_name,variant_switch)
            end
        end
    end
    
%     % substitute the participant string identifier into the path. 
%     config_struct.track_path = strrep(master_track_path,subject_list{i},'%s');
%     config_struct.out_path = strrep(master_out_path,subject_list{i},'%s');
%     config_struct.manual_annotations_path = strrep(master_manual_annotations_path,subject_list{i},'%s');
end

% set the constant parameters of the analysis
config_struct = config;

% write table for biomarker values with different factor analysis
% parameters
bm_tab = get_biomarker_table(config_struct,subject_list);
writetable(bm_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'bm_tab.csv'))

% write table for residual values with different f parameter values
[err_tab,stds_tab] = get_error_table(config_struct,subject_list);
writetable(err_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'err_tab.csv'))
writetable(stds_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'stds_tab.csv'))

function build_model(config_struct,init_contour_data_file_name,variant_switch)
% BUILD_MODEL
% 
% INPUT:
%  Variable name: config_struct
%  Size: 1x1
%  Class: struct
%  Description: Fields correspond to constants and hyperparameters. 
%  Fields: 
%  - out_path: (string) path for saving MATLAB output
%  - track_path: (string) path to segmentation results
%  - manual_annotations_path: (string) path to manual annotations
%  - fov: (double) size of field of view in mm^2
%  - n_pix: (double) number of pixels per row/column in the imaging plane
%  - frames_per_sec: (double) frame rate of reconstructed real-time
%      magnetic resonance imaging videos in frames per second
%  - verbose: (logical) if true, plot graphics; otherwise, do not plot.
%
% FUNCTION OUTPUT:
%  none
%
% EXAMPLE USAGE: 
%  >> build_model(config_struct,init_contour_data_file_name,variant_switch)
% 
% SAVED OUTPUT:
%  Path: config_struct.path_out
%  File name: value of sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)
%  Variable name: contour_data
%  Size: 1x1
%  Class: struct
%  Description: Struct with fields for each subject (field name is subject
%    ID, e.g., 'at1_rep'). The fields are structs with the following
%    fields.
%  Fields:
%  - X: X-coordinates of tissue-air boundaries in columns and time-samples
%      in rows
%  - Y: Y-coordinates of tissue-air boundaries in columns and time-samples
%      in rows
%  - files: file ID for each time-sample, note that this indexes the cell
%      array of string file names in fl
%  - file_list: cell array of string file names indexed by the entries of File
%  - sections_id: array of numeric IDs for X- and Y-coordinates in the
%      columns of the variables in fields X, Y; the correspondences are as
%      follows: 01 Epiglottis; 02 Tongue; 03 Incisor; 04 Lower Lip; 05 Jaw;
%      06 Trachea; 07 Pharynx; 08 Upper Bound; 09 Left Bound; 10 Low Bound;
%      11 Palate; 12 Velum; 13 Nasal Cavity; 14 Nose; 15 Upper Lip
%  - frames: frame number; 1 is first segmented video frame
%  - video_frames: frame number; 1 is first frame of avi video file
%  - tv: (cell array) cell array of length 6 with the fields corresponding
%     to the phonetic places of articulation: 
%       (1) LA - lip aperture; 
%       (2) ALV - alveolar constriction degree; 
%       (3) PAL - palatal constriction degree; 
%       (4) VEL - velar constriction degree;
%       (5) PHAR - pharyngeal constriction degree; 
%       (6) VP - velopharyngeal port. 
%      Each field is a structured array with fields corresponding to
%      consriction degree, index of inner structure used to compute the
%      constriction degree, and index of the outer structure used to
%      compute the constriction degree.
%       cd - (Nx1) double array containing constriction degrees
%       in - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of inner structure used to compute the
%       constriction degree.
%       out - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of outer structure used to compute the
%       constriction degree.
%    - mean_vt_shape: double array with the mean value of each contour
%     vertex
%    - U_gfa: double array of size 400xQ, where Q is the number of factors,
%     as determined by optional input q, which has the factors in the
%     columns.
%    - weights: double array of size NxQ, where N is the number of
%     real-time magnetic resonance images and Q is the number of factors,
%     as determined by the optional input q. The entries are the factor
%     scores for each factor in each image. 
%  - strategies: struct with the following fields:
%    - jaw: Nx6 array of double; entries are jaw contributions to change in
%     each of 6 constriction degrees (columns) in N real-time magnetic 
%     resonance imaging video frames (rows)
%    - lip: Nx6 array of double; entries are lip contributions to change in
%     each of 6 constriction degrees (columns) in N real-time magnetic 
%     resonance imaging video frames (rows)
%    - tng: Nx6 array of double; entries are tongue contributions to change 
%     in each of 6 constriction degrees (columns) in N real-time magnetic 
%     resonance imaging video frames (rows)
%    - tng: Nx6 array of double; entries are velum contributions to change 
%     in each of 6 constriction degrees (columns) in N real-time magnetic 
%     resonance imaging video frames (rows)
%    - dz: Nx6 array of double; entries are change in each of 6 
%     constriction degrees (columns) in N real-time magnetic resonance 
%     imaging video frames (rows)
%    - dw: Nx8 array of double; entries are change in 8 factor coefficients
%     (columns) in N real-time magnetic resonance imaging video frames 
%     (rows)
%    - cl: (cell array of strings) identifier for the 6 places of 
%     articulation
%  - err_tab: (table) table of residual error terms
%  - stds: (double) standard deviation of the residuals for the indirect 
%   kinematics by constriction location
%  - stds_d: (double) standard deviation of the residuals for the direct 
%   kinematics by constriction location
%
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 05/15/2018

    dest_contour_data_file_name = fullfile(config_struct.out_path,...
        sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
        config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f)));

    if exist(dest_contour_data_file_name,'file') ~= 2
        if ~strcmp(init_contour_data_file_name,dest_contour_data_file_name)
            copyfile(init_contour_data_file_name,dest_contour_data_file_name);
        end
        get_Ugfa(config_struct,variant_switch)
        get_strategies(config_struct)
        get_fwd_map_err(config_struct);
    else
        load(dest_contour_data_file_name,'contour_data')
        if ~isfield(contour_data,'U')
            get_Ugfa(config_struct,variant_switch)
            get_strategies(config_struct)
            get_fwd_map_err(config_struct);
        end
    end
end
