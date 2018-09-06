% VALIDATION This script generates contour data, factors, and
% constriction degrees for the synthesized participant data
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 09/06/2018

% add to path the functions called during the analysis
addpath(genpath(fullfile('..','span_contour_processing','functions')))

for weight_idx = 1:5
    participant_name = ['synth_participant' num2str(weight_idx)];
    participant_folder = fullfile('..','mat_synth',participant_name);

    % set the constant parameters of the analysis
    config_struct = config_validation;
    config_struct.out_path = sprintf(config_struct.out_path,participant_name);
    
    mkdir(fullfile('..'), fullfile('mat_synth'))
    mkdir(fullfile('..','mat_synth'), participant_folder)
    system(['cp ' fullfile(pwd,'tada','synth_data',[strrep(participant_name, num2str(weight_idx), ['_' num2str(weight_idx)]) '.mat']) ' ' participant_folder '/' sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f))])

    get_Ugfa(config_struct,'sorensen2018')
    
    get_tv(config_struct)
    
    get_strategies(config_struct)
    
    get_fwd_map_err(config_struct);
end
