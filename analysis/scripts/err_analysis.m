config_struct = artstrat_config;

% get folder list ({'ac2_var','ak3_var',...}) 
folder_list = dir(fullfile('..','segmentation_results'));
folder_list = {folder_list.name};
folder_list = folder_list(cellfun(@(x) ~startsWith(x,'.') && ~contains(x,'rep2'),folder_list));

% get subject list ({'ac2','ak3',...})
subject_list = cellfun(@(x) x(1:strfind(x,'_')-1), folder_list,'UniformOutput',false);
u_subject_list = unique(subject_list);

% save subject-id key
writetable(table(u_subject_list(:),cellfun(@(x) length(x)<3, u_subject_list)',(1:length(u_subject_list))','VariableNames',{'subject_name','repeatability_dataset','subject_id'}),...
    fullfile(strrep(config_struct.out_path,'%s',''),'err_subjects.csv'))

% make output path
output_path = fullfile('.','mat');
if ~exist(output_path,'dir')
    mkdir(output_path)
end

% set optimization parameters
n_optim_param = 20;
n_fold = 10;

% set regularization parameter for robust estimation of the forward
% kinematic map
g = 1e-10;

% open writeable file for outputs
fid = fopen(fullfile(output_path,'err.csv'), 'w');
fprintf(fid,'participant,fold,f_param,bilabial,alveolar,palatal,velar,velopharyngeal,pharyngeal,bilabial_d,alveolar_d,palatal_d,velar_d,velopharyngeal_d,pharyngeal_d\n');
fclose(fid);

% open writeable file for standard deviations of observed constriction degrees
fid = fopen(fullfile(output_path,'stds.csv'), 'w');
fprintf(fid,'participant,bilabial,alveolar,palatal,velar,pharyngeal,velopharyngeal,bilabial_d,alveolar_d,palatal_d,velar_d,pharyngeal_d,velopharyngeal_d\n');
fclose(fid);

% optimize each speaker separately
for i = 1:length(folder_list)
    fprintf('speaker %d/%d: ',i,length(folder_list))

    % set number of jaw, tongue, and lip factors
    q = struct('jaw',1,'tng',4,'lip',2);

    % obtain errors
    fprintf('obtaining errors [')
    [err,err_d,fold,f_param,stds,stds_d] = obtain_errs(folder_list{i},...
        q.jaw,q.tng,q.lip,n_optim_param,n_fold,g,output_path);

    % save errors to file
    fprintf('], saving errors to file ')
    participant_id = find(cellfun(@(x) strcmp(x,subject_list{i}), u_subject_list));
    dlmwrite(fullfile(output_path,'err.csv'),[participant_id*ones(size(err,1),1) ...
       fold f_param err err_d],'-append');
    dlmwrite(fullfile(output_path,'stds.csv'),[participant_id stds stds_d],'-append');
    fprintf('[complete]\n')
end


function [err,err_d,fold,f_param,stds,stds_d]=obtain_errs(subj,jaw_fac,tng_fac,lip_fac,n_optim_param,n_fold,g,output_path)
    % load contour_data
    load(sprintf(fullfile(output_path,'%s','contour_data_jaw%d_tng%d_lip%d_vel1_lar2.mat'),subj,jaw_fac,tng_fac,lip_fac),'contour_data')

    % center contours X
    X = [contour_data.X contour_data.Y];
    m = mean(X);
    X = X - m;

    % get factor scores W
    F = contour_data.U_gfa;
    W = X*pinv(F');

    % get constriction degrees Z
    Z = zeros(length(contour_data.tv{1}.cd),6);
    for j = 1:length(contour_data.tv)
        Z(:,j) = contour_data.tv{j}.cd;
    end
    
    % initialize containers for the time derivatives dW, dZ of W and Z
    dW = zeros(size(W));
    dZ = zeros(size(Z));
    
    % within each file, obtain the time derivatives dW, dZ of W and Z
    files = contour_data.files;
    u_files = unique(files);
    for j=1:length(u_files)
        [~,dW(files==u_files(j),:)] = gradient(W(files==u_files(j),:));
        [~,dZ(files==u_files(j),:)] = gradient(Z(files==u_files(j),:));
    end
    
    % compute standard deviations
    stds = std(Z);
    stds_d = std(dZ);

    % generate cross validation splits
    idx = crossvalind('Kfold', size(X,1), n_fold);

    % set range for neighborhood size optimization
    optim_lb = 0.05; % 5 percent of data points
    optim_ub = 0.95; % 95 percent of data points
    optim_param = linspace(optim_lb,optim_ub,n_optim_param);

    % initialize container for prediction errors
    err = zeros(n_optim_param*size(X,1),size(Z,2));
    err_d = zeros(n_optim_param*size(X,1),size(Z,2));
    fold = zeros(n_optim_param*size(X,1),1);
    f_param = zeros(n_optim_param*size(X,1),1);

    inner_idx = 1;
    for j=1:n_optim_param
        fprintf('=')
        for k=1:n_fold
            % get the kth train-test split
            train_idx = find(idx ~= k);
            test_idx = find(idx == k);

            for ell=1:length(test_idx)
                % get distances from test point W(ell,:) to each data-point
                d = pdist2(W,W(test_idx(ell),:));
                dsort = sort(d);

                % get weights
                h = dsort(round(optim_param(j)*size(X,1)));
                w = (1-(d./h).^3).^3;
                w(d./h > 1) = 0;

                % get error for the ellth observation
                Wtrain = [ones(length(train_idx),1) W(train_idx,:)];
                G = (Wtrain'*diag(w(train_idx))*Wtrain ...
                    + g*eye(size(W,2)+1)) ...
                    \ Wtrain'*diag(w(train_idx))*Z(train_idx,:);

                Zhat = [1 W(test_idx(ell),:)]*G;
                err(inner_idx,:) = Z(test_idx(ell),:) - Zhat;

                dZhat = dW(test_idx(ell),:)*G(2:end,:);
                err_d(inner_idx,:) = dZ(test_idx(ell),:) - dZhat;

                fold(inner_idx) = k;
                f_param(inner_idx) = optim_param(j);

                inner_idx = inner_idx+1;
            end
        end
    end
end
