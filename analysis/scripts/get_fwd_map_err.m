function get_fwd_map_err(config_struct)

    disp('Quantifying error of direct and differential kinematics')
    
    % set the number of folds
    n_fold = 10;

    % load contour_data
    load(sprintf(fullfile(config_struct.out_path,'contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat'),config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f)),'contour_data')

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

    % generate cross validation splits
    cv_idx = crossvalind('Kfold', size(X,1), n_fold);

    % initialize container for prediction errors
    err = zeros(size(X,1),size(Z,2));
    err_d = zeros(size(X,1),size(Z,2));
    fold = zeros(size(X,1),1);
    
    inner_idx = 1;
    for k=1:n_fold
        % get the kth train-test split
        train_idx = find(cv_idx ~= k);
        test_idx = find(cv_idx == k);
        
        % split the factor scores W, constriction degrees Z, and
        % time-derivatives dW and dZ according to the train-test split
        Wtrain = [ones(length(train_idx),1) W(train_idx,:)];
        Ztrain = Z(train_idx,:);
        Wtest = W(test_idx,:);
        Ztest = Z(test_idx,:);
        dWtest = dW(test_idx,:);
        dZtest = dZ(test_idx,:);
        
        % Get q nearest neighbors of each articulator parameter value.
        fn = round(config_struct.f*size(X,1));
        [knn_idx, dist] = knnsearch(Wtrain(:,2:end),Wtest,'dist','euclidean','K',fn);

        for ell=1:length(test_idx)
            % get distances from test point W(ell,:) to each data-point
            %d = pdist2(W,Wtest(ell,:));
            %dsort = sort(d);

            % get weights
            %h = dsort(round(config_struct.f*size(X,1)));
            %w = (1-(d./h).^3).^3;
            %w(d./h > 1) = 0;

            % get error for the ellth observation
            %G = lscov(Wtrain, Ztrain, w(train_idx));
            
            w = zeros(size(Wtrain,1),1);
            w(knn_idx(ell,:)) = arrayfun(@(u) weight_fun(u), dist(ell,:)./dist(ell,end));
            G = lscov(Wtrain, Ztrain, w);

            Zhat = [1 Wtest(ell,:)]*G;
            err(inner_idx,:) = Ztest(ell,:) - Zhat;

            dZhat = dWtest(ell,:)*G(2:end,:);
            err_d(inner_idx,:) = dZtest(ell,:) - dZhat;

            fold(inner_idx) = k;

            inner_idx = inner_idx+1;
        end
    end
    
    contour_data.err_tab = array2table([fold err err_d],'VariableNames',...
        {'fold','bilabial','alveolar','palatal','velar','pharyngeal','velopharyngeal',...
        'bilabial_d','alveolar_d','palatal_d','velar_d','pharyngeal_d','velopharyngeal_d'});
    contour_data.stds = std(Z);
    contour_data.stds_d = std(dZ);
    
    save(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,round(100*config_struct.f))),'contour_data')
end
