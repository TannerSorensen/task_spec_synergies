%CHECK_DEPENDENCIES - Check the dependencies of all user-defined functions
%in the directory 'functions'.
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% Los Angeles, CA

fprintf('\nChecking dependencies in the following folders:\n')
names = check_deps(fullfile(pwd,'functions'),{},'');
fprintf('\nDependencies:\n')
for dep_idx = 1:length(names)
    fprintf(' %s\n',names{dep_idx})
end

function names = check_deps(folder,names,prefix)
    % display progress
    fprintf('%s %s\n',prefix, folder)
    
    % get file list
    file_list = dir(folder);
    file_list = {file_list.name};
    
    % remove hidden directories
    file_list = file_list(cellfun(@(x) ~startsWith(x,'.'),file_list));
    
    file_list = cellfun(@(x) fullfile(folder,x), file_list,'UniformOutput',false);
    
    % identify dependencies for all .m files
    m_file_list = file_list(cellfun(@(x) endsWith(x,'.m'),file_list));
    if ~isempty(m_file_list)
        names_tmp = dependencies.toolboxDependencyAnalysis(m_file_list);
        names = cat(2,names,names_tmp);
    end
    
    % remove non-directories
    file_list = file_list(cellfun(@(x) isdir(x),file_list));
    
    % recursively identify dependencies
    prefix = sprintf('%s-',prefix);
    for subdir_idx = 1:length(file_list)
        names_tmp = check_deps(file_list{subdir_idx},names,prefix);
        names = cat(2,names,names_tmp);
    end
    
    % remove duplicates
    names = unique(names);
end