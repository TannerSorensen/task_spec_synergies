
addpath(fullfile(pwd,'..','simulation'))
addpath(genpath(fullfile(pwd,'..','span_contour_processing')))

mkdir(fullfile('..','mat_synth'))

jaw_weight_parameters = [0.1 1 10 100];
target_parameters = [0 0 1 0];
constriction_locations = [1 2 3 4];
constriction_location_names = {'apa','ata','aia','aka'};
omega_parameters = [20 20 20 20];
n_rep = 10;

for i=1:length(jaw_weight_parameters)
    
    % set participant name
    real_participant_name = 'f1_rep1';
    synth_participant_name = [real_participant_name '_' num2str(i)];
    
    mkdir(fullfile('..','mat_synth',synth_participant_name))
    
    % configure
    config_struct = config;
    config_struct.manual_annotations_path = sprintf(config_struct.manual_annotations_path,real_participant_name);
    config_struct.out_path = strrep(sprintf(config_struct.out_path,synth_participant_name),'mat','mat_synth');
    
    contour_data_filename = sprintf('contour_data_jaw1_tng4_lip2_vel1_lar2_f%02d.mat',round(100*config_struct.f));
    synth_contour_data_path_filename = fullfile(config_struct.out_path,contour_data_filename);
    
    % load real contour_data
    load(fullfile('..','mat',real_participant_name,contour_data_filename))
    
    % remove larynx factors
    contour_data.weights = contour_data.weights(:,1:end-2);
    contour_data.U_gfa = contour_data.U_gfa(:,1:end-2);

    % MRI parameters
    frameRate = config_struct.frames_per_sec; % frame rate

    % parameters of the simulation
    n_tv = size(contour_data.tv,2);
    n_factor = size(contour_data.U_gfa,2);
    time = 0.6;            % time in sec
    n_frames = 10;         % No. frames in which to linearize ODE
    h2 = time./n_frames;
    timepoints_per_frame = 10;
    h1 = (1/timepoints_per_frame)*h2;           % time step

    % get constriction degrees
    z = zeros(length(contour_data.tv{1}.cd),n_tv);
    for j=1:n_tv
        z(:,j) = contour_data.tv{j}.cd;
    end

    % get factor weights
    w = contour_data.weights;

    % get time derivatives of constriction degrees and factor weights
    [dzdt,dwdt] = getGrad(z,w,contour_data.files);
    
    W = eye(n_factor);
    W(1,1) = jaw_weight_parameters(i);
    
    w_container = [];
    z_container = [];
    files = [];
    frames = [];
    file_list = {};
    
    file_no = 1;
    for k=1:n_rep
        phiInit = zeros(2*n_factor,1) + 0.1*[ std(w) std(dwdt) ]' .* randn(2*n_factor,1);
        for j=1:length(constriction_locations)
            omega = zeros(n_tv,1); % natural frequencies of task variables
            omega(constriction_locations(j)) = omega_parameters(j);

            z0 = zeros(n_tv,1);    % targets for LA, alvCD, palCD, velCD, pharCD, VEL
            z0(constriction_locations(j)) = target_parameters(j);

            [t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,timepoints_per_frame,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,config_struct.f);

            w_container = cat(1,w_container,phiOut');
            z_container = cat(1,z_container,zOut');
            frames = cat(2,frames,t);
            
            file_list = cat(2,file_list,[constriction_location_names{j} '_' num2str(k)]);
            files = cat(1,files,file_no*ones(length(t),1));
            file_no = file_no+1;
        end
    end
    
    % replace variables in contour_data
    for j=1:n_tv
        contour_data.tv{j}.cd = z_container(:,j);
    end
    contour_data.frames = frames;
    contour_data.video_frames = frames;
    contour_data.weights = w_container(:,1:n_factor);
    contour_data.files = files;
    contour_data.file_list = file_list;
    xy = contour_data.mean_vt_shape' + contour_data.U_gfa(:,1:n_factor) * contour_data.weights';
    contour_data.X = xy(1:200,:)';
    contour_data.Y = xy(201:end,:)';
    contour_data.U_gfa = contour_data.U_gfa(:,1:n_factor);
    
    % remove some fields
    contour_data = rmfield(contour_data,'strategies');
    contour_data = rmfield(contour_data,'err_tab');
    contour_data = rmfield(contour_data,'stds');
    contour_data = rmfield(contour_data,'stds_d');
    
    % save contour_data
    save(synth_contour_data_path_filename,'contour_data')
    
    get_strategies(config_struct);
end

%%

%%

% plot(t,zOut)
% legend({'bilabial','alveolar','palatal','velar'})

%%

% W(1,1) = 0.25;
% [t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,config_struct.f);
% init_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,1);
% end_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,end);
% plot_from_xy(end_vt_shape,contour_data.sections_id,'r'), hold on
% 
% W(1,1) = 4;
% [t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,config_struct.f);
% init_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,1);
% end_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,end);
% plot_from_xy(end_vt_shape,contour_data.sections_id,'b')
% 
% plot_from_xy(init_vt_shape,contour_data.sections_id,'--k'), hold off
