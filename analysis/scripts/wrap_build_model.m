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

% set the constant parameters of the analysis
config_struct = config;

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
f = 0.05:0.05:0.95;

for i=1:length(subject_list)
    disp(subject_list{i})
    disp(['subject ' num2str(i) '/' num2str(length(subject_list))])
    
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
    
    % the call to make_contour_data below generates the file 
    % 'contourdata.mat' in the directory config_struct.out_path
    config_struct.q = q_init;
    init_contour_data_file_name = fullfile(config_struct.out_path,...
        sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
        config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f));
    make_contour_data(config_struct)

    % obtain manual annotations for pharynx location
    if exist(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'file') == 0
        make_manual_annotations(config_struct,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
            config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f));
    end
    load(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'phar_idx')
    
    tv_key_path_name = strrep(master_manual_annotations_path,'%s',subject_list{i});
    if ~exist(tv_key_path_name,'dir')
        mkdir(tv_key_path_name)
    end
    writetable(tv_key_tab,fullfile(tv_key_path_name,'tv_key'))
    
    % measure task variables
    get_tv(config_struct,false,phar_idx)
    
    % obtain models with different factor analysis parameterizations
    for j=1:length(jaw_fac)
        for k=1:length(tng_fac)
            config_struct.q = struct('jaw',jaw_fac(j),'tng',tng_fac(k),'lip',2,'vel',1,'lar',2);
            dest_contour_data_file_name = fullfile(config_struct.out_path,...
                sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
                config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f));
            if ~strcmp(init_contour_data_file_name,dest_contour_data_file_name)
                copyfile(init_contour_data_file_name,dest_contour_data_file_name);
            end
            get_Ugfa(config_struct,variant_switch)
            get_strategies(config_struct)
        end
        for k=1:length(lip_fac)
            config_struct.q = struct('jaw',jaw_fac(j),'tng',4,'lip',lip_fac(k),'vel',1,'lar',2);
            dest_contour_data_file_name = fullfile(config_struct.out_path,...
                sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
                config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f));
            if ~strcmp(init_contour_data_file_name,dest_contour_data_file_name)
                copyfile(init_contour_data_file_name,dest_contour_data_file_name);
            end
            get_Ugfa(config_struct,variant_switch)
            get_strategies(config_struct)
        end
    end
    
    % obtain models for different f parameter values
    config_struct.q = struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2);
    for j=1:length(f)
        config_struct.f = f(j);
        dest_contour_data_file_name = fullfile(config_struct.out_path,...
            sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
            config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f)));
        if ~strcmp(init_contour_data_file_name,dest_contour_data_file_name)
            copyfile(init_contour_data_file_name,dest_contour_data_file_name);
        end
        get_fwd_map_err(config_struct);
    end
    
    % reset the f value to 0.75
    config_struct.f = 0.75;
    
    % substitute the participant string identifier into the path. 
    config_struct.track_path = strrep(master_track_path,subject_list{i},'%s');
    config_struct.out_path = strrep(master_out_path,subject_list{i},'%s');
    config_struct.manual_annotations_path = strrep(master_manual_annotations_path,subject_list{i},'%s');
end

% write table for biomarker values with different factor analysis
% parameters
bm_tab = get_biomarker_table(config_struct,subject_list);
writetable(bm_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'bm_tab.csv'))

% write table for residual values with different f parameter values
[err_tab,stds_tab] = get_error_table(config_struct,subject_list);
writetable(err_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'err_tab.csv'))
writetable(stds_tab,fullfile(strrep(config_struct.out_path,'/%s',''),'stds_tab.csv'))
