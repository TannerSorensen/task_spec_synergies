% VALIDATION This script generates contour data, factors, and
% constriction degrees for the synthesized participant data
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 09/06/2018

% add span_contour_processing to path
addpath(genpath(fullfile('..','span_contour_processing','functions')))

synthesis_dir = 'mat_synth';
mkdir(fullfile('..'), fullfile(synthesis_dir))

for weight_idx = 1:5
    participant_name = ['synth_participant' num2str(weight_idx)];
    participant_folder = fullfile('..','mat_synth',participant_name);
    mkdir(fullfile('..',synthesis_dir), participant_folder);

    % set the output path where mat files will be saved
    config_struct = config_validation;
    config_struct.out_path = sprintf(config_struct.out_path,participant_name);
    mat_file_name = [strrep(participant_name, num2str(weight_idx), ['_' num2str(weight_idx)]) '.mat'];
    new_mat_file_name = sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f));
    system(['cp ' fullfile(pwd,mat_file_name) ' ' fullfile(participant_folder,new_mat_file_name) ])

    % guided factor analysis
    get_Ugfa(config_struct,'sorensen2018')
    
    % task variables
    get_tv(config_struct)
    
    % articulator strategies
    get_strategies(config_struct)
    
    % forward map error analysis
    get_fwd_map_err(config_struct);
end
