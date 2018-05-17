function [err_tab,stds_tab] = get_error_table(config_struct,subject_list)
%GET_BIOMARKER_TABLE - returns a table of biomarkers for statistical
%analysis or export

participant_list = cellfun(@(x) x(1:strfind(x,'_')-1), subject_list,'UniformOutput',false);
repetition_list = cellfun(@(x) str2double(x(end)), subject_list);

% set regex expression into which the string subject identifiers will be
% substituted in to obtain paths to segmentation results
% (master_track_path), outputs of the analysis (master_out_path), and 
% manual annotations for the analysis (master_manual_annotations_path)
master_out_path = config_struct.out_path;

% set the f parameter values
f = 0.2:0.1:0.9;

% set the parameters of the factor analysis
q = config_struct.q;

% initialize output tables
err_tab = table;
stds_tab = [];

for i=1:length(subject_list)
    fprintf('Participant %d of %d\n',i,length(subject_list))
    
    % substitute participant name into path
    config_struct.out_path = strrep(master_out_path,'%s',subject_list{i});
    
    % load contour_data and concatenate the biomarkers onto the table, for
    % each factor analysis specification and for each f-value
    for j=1:length(f)
        load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d',q.jaw,q.tng,q.lip,round(100*f(j)))),'contour_data');
        tmp_err_tab = contour_data.err_tab;
        tmp_err_tab.participant = repmat(participant_list(i),size(tmp_err_tab,1),1);
        tmp_err_tab.repetition = repmat(repetition_list(i),size(tmp_err_tab,1),1);
        tmp_err_tab.f = repmat(f(j),size(tmp_err_tab,1),1);
        err_tab = cat(1,err_tab,tmp_err_tab);
    end
    
    stds_tab = cat(1,stds_tab,[contour_data.stds contour_data.stds_d]);
	
    % reset path
    config_struct.out_path = strrep(master_out_path,subject_list{i},'%s');
end

var_names = {'bilabial','alveolar','palatal','velar','pharyngeal','velopharyngeal',...
    'bilabial_d','alveolar_d','palatal_d','velar_d','pharyngeal_d','velopharyngeal_d'};
stds_tab = array2table(stds_tab,'VariableNames',var_names);
stds_tab.participant = participant_list';
stds_tab.repetition = repetition_list';

end

