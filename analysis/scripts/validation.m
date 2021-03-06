
% add folder containing simulation scripts to path
addpath(fullfile(pwd,'..','simulation'))

% add folder containing articulatory strategies script to path
addpath(genpath(fullfile(pwd,'..','span_contour_processing')))

% set RNG seed for reproducibility
seed = 189;
rng(seed);

% create a folder for the synthesized articulatory data
synth_dir = fullfile('..','mat_synth');
mkdir(synth_dir)

% set which participant to use (from folder ../mat/)
real_participant_name = 'm5_rep1';

% declare array of jaw weights from 10^-3 to 10^2 in 10 steps
% (the point of validation.m is to evaluate agreement between articulator
% synergy biomarker and known jaw weights)
jaw_weight_parameters = logspace(-3,2,15);

% declare gestural parameters for the consonants [p], [t], [j], [k]
target_parameters_clo = [0 0 1 0];
target_parameters_rel = [1 1 1 1];
file_names = {'apa','ata','aia','aka'};
constriction_location_clo_idx = [1 2 3 4];
constriction_location_rel_idx = [5 5 5 5];
omega_parameters = [10 10 10 10];

% set parameters of the simulation
time = 1.0;                   % time in sec
n_frames = 10;                % no. frames in which to linearize ODE
h2 = time/n_frames;           % duration of frame
timepoints_per_frame = 5;     % number of time-steps within frame
h1 = h2/timepoints_per_frame; % duration of time step

% declare an integer number of repetitions, along with a standard deviation
% that controls variance in initial vocal tract shape (random vocal tract
% shape to start each file)
n_rep = 10;
sigma = 0.25;

for i=1:length(jaw_weight_parameters)
    % set participant name and create a folder for the synthesized data
    synth_participant_name = [real_participant_name '_' num2str(i)];
    mkdir(fullfile('..','mat_synth',synth_participant_name))
    
    % configure and then load real contour_data
    config_struct = config;
    config_struct.manual_annotations_path = sprintf(config_struct.manual_annotations_path,real_participant_name);
    contour_data_filename = sprintf('contour_data_jaw1_tng4_lip2_vel1_lar2_f%02d.mat',round(100*config_struct.f));
    config_struct.out_path = sprintf(config_struct.out_path,real_participant_name);
    load(fullfile(config_struct.out_path,contour_data_filename))
    
    % remove larynx factors (not used)
    contour_data.weights = contour_data.weights(:,1:8);
    contour_data.U_gfa = contour_data.U_gfa(:,1:8);

    n_cd = size(contour_data.tv,2);        % number of constriction degrees
    n_factor = size(contour_data.U_gfa,2); % number of factors

    % reconfigure for synthesized data
    config_struct = config;
    config_struct.manual_annotations_path = sprintf(config_struct.manual_annotations_path,real_participant_name);
    config_struct.f = 1.0;
    config_struct.out_path = strrep(sprintf(config_struct.out_path,synth_participant_name),'mat','mat_synth');
    contour_data_filename = sprintf('contour_data_jaw1_tng4_lip2_vel1_lar2_f%02d.mat',round(100*config_struct.f));
    synth_contour_data_path_filename = fullfile(config_struct.out_path,contour_data_filename);
    
    % get constriction degrees
    z = zeros(length(contour_data.tv{1}.cd),n_cd);
    for j=1:n_cd
        z(:,j) = contour_data.tv{j}.cd;
    end

    % get factor scores (i.e. "weights", not same as jaw weight in the 
    % weighted pseudoinverse of the jacobian)
    w = contour_data.weights;

    % get time derivatives of constriction degrees and factor weights
    [dzdt,dwdt] = getGrad(z,w,contour_data.files);
    
    % set articulator weights in the weighted pseudoinverse of the jacobian
    W = eye(n_factor);
    W(1,1) = jaw_weight_parameters(i);
    
    % initialize containers for synthesized data
    w_container = [];
    z_container = [];
    files = [];
    frames = [];
    file_list = {};
    true_bm = [];
    true_bm_labels = {};
    
    % a unique file number for each synthetic utterance
    file_no = 1;
    for k=1:n_rep
        
        % start from a random (but plausible) initial position
        phiInit = zeros(2*n_factor,1) + sigma*[ std(w) zeros(1,n_factor) ]' .* randn(2*n_factor,1);
        
        for j=1:length(file_names)
            
            % set gestural parameters for stop closure
            omega = zeros(n_cd,1);
            omega(constriction_location_clo_idx(j)) = omega_parameters(j);
            z0 = zeros(n_cd,1);
            z0(constriction_location_clo_idx(j)) = target_parameters_clo(j);
            
            % synthesize stop closure
            [t_clo,phi_clo,z_clo,jaw_clo,tng_clo,lip_clo] = task_dynamics(omega,z0,h1,h2,...
                n_frames,timepoints_per_frame,phiInit,W,z,w,config_struct);
            
            % modify gestural parameters for stop release
            omega = zeros(n_cd,1);
            omega(constriction_location_rel_idx(j)) = omega_parameters(j);
            z0 = zeros(n_cd,1);
            z0(constriction_location_rel_idx(j)) = target_parameters_rel(j);
            
            % synthesize stop release
            [t_rel,phi_rel,z_rel,jaw_rel,tng_rel,lip_rel] = task_dynamics(omega,z0,h1,h2,...
                n_frames,timepoints_per_frame,phi_clo(:,end),W,z,w,config_struct);
            
            % add synthesized data to containers
            w_container = cat(1,w_container,phi_clo');
            w_container = cat(1,w_container,phi_rel');
            z_container = cat(1,z_container,z_clo');
            z_container = cat(1,z_container,z_rel');
            frames = cat(1,frames,(1:2*length(t_clo))');
            file_list = cat(2,file_list,[file_names{j} '_' num2str(k)]);
            files = cat(1,files,file_no*ones(2*length(t_clo),1));
            
            % compute the true biomarker values
            % (note: different articulators and label for each place of
            % articulation)
            if strcmp(file_names{j},'apa')
                jaw = [jaw_clo(1,:) jaw_rel(1,:)];
                lip = [lip_clo(1,:) lip_rel(1,:)];
                true_bm_labels = cat(1,true_bm_labels,'bilabial');
                true_bm = cat(1,true_bm,diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                            / (diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                            + diff(quantile(cumsum(lip),[0.1 0.9]))));
            else
                switch file_names{j}
                    case 'ata'
                        jaw = [jaw_clo(2,:) jaw_rel(2,:)];
                        tng = [tng_clo(2,:) tng_rel(2,:)];
                        true_bm_labels = cat(1,true_bm_labels,'alveolar');
                        true_bm = cat(1,true_bm,diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    / (diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    + diff(quantile(cumsum(tng),[0.1 0.9]))));
                    case 'aia'
                        jaw = [jaw_clo(3,:) jaw_rel(3,:)];
                        tng = [tng_clo(3,:) tng_rel(3,:)];
                        true_bm_labels = cat(1,true_bm_labels,'palatal');
                        true_bm = cat(1,true_bm,diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    / (diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    + diff(quantile(cumsum(tng),[0.1 0.9]))));
                                
                        jaw = [jaw_clo(5,:) jaw_rel(5,:)];
                        tng = [tng_clo(5,:) tng_rel(5,:)];
                        true_bm_labels = cat(1,true_bm_labels,'pharyngeal');
                        true_bm = cat(1,true_bm,diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    / (diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    + diff(quantile(cumsum(tng),[0.1 0.9]))));
                    case 'aka'
                        jaw = [jaw_clo(4,:) jaw_rel(4,:)];
                        tng = [tng_clo(4,:) tng_rel(4,:)];
                        true_bm_labels = cat(1,true_bm_labels,'velar');
                        true_bm = cat(1,true_bm,diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    / (diff(quantile(cumsum(jaw),[0.1 0.9])) ...
                                    + diff(quantile(cumsum(tng),[0.1 0.9]))));
                end
            end
            
            % increment to next file number
            file_no = file_no+1;
        end
    end
    
    % estimate the factors using synthetic data
    % (here, we use an active shape model to retain covariances that are actually present in the data)
    xy = contour_data.mean_vt_shape' ...
        + contour_data.U_gfa(:,1:n_factor) * mvnrnd(zeros(1,size(contour_data.weights,2)), cov(contour_data.weights), 2*size(w_container,1))';
    contour_data.X = xy(1:size(contour_data.X,2),:)';
    contour_data.Y = xy(size(contour_data.X,2)+1:end,:)';
    save(synth_contour_data_path_filename,'contour_data')
    config_struct.q.lar = 0;
    get_Ugfa(config_struct,'sorensen2018')
    
    % replace the real data in contour_data with the data synthesized from
    % the dynamical system
    for j=1:n_cd
        contour_data.tv{j}.cd = z_container(:,j);
    end
    contour_data.frames = frames;
    contour_data.video_frames = frames;
    contour_data.files = files;
    contour_data.file_list = file_list;
    contour_data.weights = w_container(:,1:n_factor);
    xy = contour_data.mean_vt_shape' + contour_data.U_gfa(:,1:n_factor) * contour_data.weights';
    contour_data.X = xy(1:size(contour_data.X,2),:)';
    contour_data.Y = xy(size(contour_data.X,2)+1:end,:)';
    
    % save true biomarker values
    contour_data.true_bm = true_bm;
    contour_data.true_bm_labels = true_bm_labels;
    
    % save contour_data
    save(synth_contour_data_path_filename,'contour_data')
    
%     % compute the constriction degrees
%     tmp_struct = load(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'phar_idx');
%     phar_idx = tmp_struct.phar_idx;
%     get_tv(config_struct,false,phar_idx)
    
    % compute the articulatory strategies for the synthesized data
    get_strategies(config_struct);
    
    % load contour_data (now containing articulatory strategies)
    load(synth_contour_data_path_filename,'contour_data')
end
