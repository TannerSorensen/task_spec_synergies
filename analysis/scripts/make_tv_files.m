% set the constant parameters of the analysis
config_struct = config_build_model;

% obtain a cell array subject_list whose entries are the string subject
% identifiers.
subject_dir = fullfile('..','segmentation_results');
subject_list = dir(subject_dir);
subject_list = {subject_list.name};
subject_list = subject_list(cellfun(@(x) ~startsWith(x,'.'), subject_list)); % omit hidden directories

% manual annotations for the analysis (master_manual_annotations_path)
master_manual_annotations_path = config_struct.manual_annotations_path;

file_name = 'tv_key.csv';
tv_tab = table({'aia','aia','apa','ata','aka'}',...
    {'palatal','pharyngeal','bilabial','alveolar','velar'}',...
    'VariableNames',{'file_name','task_variable'});

for i=1:length(subject_list)
    disp(subject_list{i})
    disp(['subject ' num2str(i) '/' num2str(length(subject_list))])
    writetable(tv_tab,fullfile(strrep(master_manual_annotations_path,'%s',subject_list{i}),file_name))
end