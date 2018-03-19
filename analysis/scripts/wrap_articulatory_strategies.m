% MAIN - calculate articulatory strategies and save output files. 
%
% Calculate jaw, tongue, lip, and velum articulatory strategy 
% biomarkers
%
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Feb. 14, 2017

addpath(fullfile('..','span_articulatory_strategies','util'))
config_struct = config_artstrat;

% specify numbers of factors
jaw_fac = [1 2 3];
tng_fac = [4 6 8];
lip_fac = 3;

% get folder list ({'ac2_var','ak3_var',...}) 
folder_list = dir(fullfile('..','segmentation_results'));
folder_list = {folder_list.name};
folder_list = folder_list(cellfun(@(x) ~startsWith(x,'.') && ~contains(x,'f3_rep2'),folder_list));

% get subject list ({'ac2','ak3',...})
subject_list = cellfun(@(x) x(1:strfind(x,'_')-1), folder_list,'UniformOutput',false);
u_subject_list = unique(subject_list);

% save subject-id pairings to csv file
writetable(table(u_subject_list(:),...             % subject name (ac2,ak3,...)
    cellfun(@(x) length(x)<3, u_subject_list)',... % 1-repeatability, 2-morphology
    (1:length(u_subject_list))',...                % subject id (1,2,...)
    'VariableNames',{'subject_name','repeatability_dataset','subject_id'}),...
    fullfile(strrep(config_struct.out_path,'%s',''),'artstrat_subjects.csv'))

return

% open file to write
file_name = fullfile(strrep(config_struct.out_path,'%s',''),'strategies.csv');
fid = fopen(file_name,'w');
header = 'participant,repetition,tv,file,n_jaw,n_tng,n_lip,jaw,tng,lip,vel';
fprintf(fid,'%s\n',header);
fclose(fid);

% write strategies to file with different numbers of factors
for i=1:length(folder_list)
    disp(folder_list{i})
    config_struct.in_path = sprintf(config_struct.in_path,folder_list{i});
    for j=1:length(jaw_fac)
        for k=1:length(tng_fac)
            q = struct('jaw',jaw_fac(j),'tng',tng_fac(k),'lip',2,'vel',1,'lar',2);
            fld = sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d',q.jaw,q.tng,q.lip,q.vel,q.lar);
            write_csv_file(get_strategies(config_struct,fld,q),q,str2double(folder_list{i}(end)),file_name,find(cellfun(@(x) strcmp(x,subject_list{i}), u_subject_list)))
        end
        for k=1:length(lip_fac)
            q = struct('jaw',jaw_fac(j),'tng',4,'lip',lip_fac(k),'vel',1,'lar',2);
            fld = sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d',q.jaw,q.tng,q.lip,q.vel,q.lar);
            write_csv_file(get_strategies(config_struct,fld,q),q,str2double(folder_list{i}(end)),file_name,find(cellfun(@(x) strcmp(x,subject_list{i}), u_subject_list)))
        end
    end
    config_struct.in_path = strrep(config_struct.in_path,folder_list{i},'%s');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN USER-DEFINED FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_csv_file(strategies,q,repetition,file_name,participant_id)
    
    files = strategies.files;
    jaw = strategies.jaw;
    tng = strategies.tng;
    lip = strategies.lip;
    vel = strategies.vel;
    tv = strategies.tv;
    
    tab = zeros(0,6);
    for j=1:size(files,1)
        for k = find(~isnan(jaw(j,:)))
            tab = cat(1,tab,[tv(j) files(j) jaw(j,k) tng(j,k) lip(j,k) vel(j,k)]);
            tv(j) = 5;
        end
    end
    
    % append new file numbers for pharyngeal task variables
    % (because palatal and pharyngeal should not have same file numbers for
    % analysis, despite being from same track files)
    tab(tab(:,1)==5,2) = max(tab(tab(:,1)~=5,2)) + 1 + tab(tab(:,1)==5,2) - min(tab(tab(:,1)==5,2));
    
    % for each file, integrate biomarkers over time and compute range
    [u_files,~,ic] = unique(tab(:,2));
    n_files = length(u_files);
    tab = [repmat(participant_id,n_files,1)...     % participant id
        repmat(repetition,n_files,1)...            % repetition
        accumarray(ic,tab(:,1),[],@unique)...      % tv
        u_files...                                 % file id
        repmat(q.jaw,n_files,1)...                 % jaw factors
        repmat(q.tng,n_files,1)...                 % tongue factors
        repmat(q.lip,n_files,1)...                 % lip factors
        accumarray(ic,tab(:,3),[],@get_lambda)...  % jaw
        accumarray(ic,tab(:,4),[],@get_lambda)...  % tongue
        accumarray(ic,tab(:,5),[],@get_lambda)...  % lips
        accumarray(ic,tab(:,6),[],@get_lambda)];   % velum
    dlmwrite(file_name,tab,'-append');
end

function lambda = get_lambda(PdW)
    lambda = diff(quantile(cumsum(PdW),[0.1 0.9]));
end
