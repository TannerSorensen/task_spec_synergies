%% Add path to MATLAB scripts for factor analysis

addpath(genpath(fullfile('..','..','analysis','span_contour_processing','functions')))
addpath(fullfile('..','..','analysis','scripts'))
addpath('util')

%% Load data-set

q = struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2);
f = 0.2;
load(fullfile('..','..','analysis','mat','f1_rep1',sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d_f%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar,round(100*f))),'contour_data')

config_struct = config;
config_struct.out_path = fullfile(pwd,'extensions');

if ~exist(config_struct.out_path,'dir')
    mkdir(config_struct.out_path)
end

% center the data-set
D = [contour_data.X,contour_data.Y];
n = size(D,1);
mean_data = mean(D);
Dnorm = D - mean_data;

%% Get jaw factor
U_jaw = get_Ujaw(contour_data,'sorensen2018');
U_jaw = U_jaw(:,1);

%% Manually specify what is tongue body and tongue tip
jaw_idx = ismember(contour_data.sections_id,5);
tongue_body_idx = [1:23, 28:30];
tongue_tip_idx = 24:27;

%% Subtract jaw factor from the dataset
Dnorm=Dnorm-Dnorm*U_jaw*pinv(U_jaw);

%% Get tongue body factor
% subset data to tongue body
Dnorm_zero = Dnorm;
Dnorm_zero(:,~ismember(1:size(Dnorm,2), tongue_body_idx))=0; % tongue body and tongue tip

% principal components analysis of the tongue, minus the jaw component
[U_tngraw,~,latent]=pca(Dnorm_zero);

% subset data to whole tongue
tongue_idx = 1:30;
Dnorm_zero = Dnorm;
Dnorm_zero(:,~ismember(1:size(Dnorm,2), tongue_idx))=0; % tongue body and tongue tip

% covariance matrix
R = Dnorm_zero'*Dnorm_zero/(n-1);

q_max = 2;
U_bdy = R*U_tngraw(:,1:q_max)/chol(diag(latent(1:q_max)));

%% Subtract jaw factor from the dataset
Dnorm=Dnorm-Dnorm*U_bdy*pinv(U_bdy);

%% Get tongue tip factor
% subset data to tongue
Dnorm_zero = Dnorm;
Dnorm_zero(:,~ismember(1:size(Dnorm,2), tongue_tip_idx))=0; % tongue body and tongue tip

% principal components analysis of the tongue, minus the jaw component
[U_tngraw,~,latent]=pca(Dnorm_zero);

% covariance matrix
R = Dnorm_zero'*Dnorm_zero/(n-1);

q_max = 1;
U_tip = R*U_tngraw(:,1:q_max)/chol(diag(latent(1:q_max)));

%% Subtract jaw factor from the dataset
Dnorm=Dnorm-Dnorm*U_tip*pinv(U_tip);

%% Get weights
D = [contour_data.X,contour_data.Y];
mean_data=ones(size(D,1),1)*mean(D);
Dnorm=D-mean_data;
mean_vt_shape = mean(D);
contour_data.mean_vt_shape = mean_vt_shape;
contour_data.U_gfa = [U_jaw, U_bdy, U_tip];
weights = Dnorm*pinv(contour_data.U_gfa');
contour_data.weights = weights;

%% Plot factors

std_weights = std(contour_data.weights);
for j=1:size(contour_data.U_gfa,2)  % component under examination
    parameters=zeros(1,size(std_weights,2));
    parameters(j)=-2*std_weights(j);
    plot_from_xy(weights_to_vtshape(parameters, mean_vt_shape, contour_data.U_gfa, 'sorensen2018'),contour_data.sections_id(1,:),'b'); hold on
    
    parameters=zeros(1,size(std_weights,2));
    parameters(j)=2*std_weights(j);
    plot_from_xy(weights_to_vtshape(parameters, mean_vt_shape, contour_data.U_gfa, 'sorensen2018'),contour_data.sections_id(1,:),'r'); 
    
    plot_from_xy(mean(D),contour_data.sections_id(1,:),'k'); hold off
        
    axis([-40 20 -30 30]); axis off;

    print(fullfile(config_struct.out_path,sprintf('factor_%d',j)),'-dpdf')
    
    close all
end

%% Plot parcellation into jaw, tongue body, and tongue tip
colr = hex2rgb({'#E41A1C','#377EB8','#4DAF4A','#984EA3','#FF7F00','#A65628'});
plot_from_xy(mean_vt_shape,contour_data.sections_id(1,:),'k'); hold on
xy = mean_vt_shape(1,[jaw_idx jaw_idx]);
plot(xy(1:end/2),xy(end/2+1:end),'Color',colr(1,:),'LineWidth',4)

tongue_body_idx = 1:23;
xy = mean_vt_shape(1,[ismember(1:length(contour_data.sections_id), tongue_body_idx), ismember(1:length(contour_data.sections_id), tongue_body_idx)]);
plot(xy(1:end/2),xy(end/2+1:end),'Color',colr(2,:),'LineWidth',4)

tongue_body_idx = 28:30;
xy = mean_vt_shape(1,[ismember(1:length(contour_data.sections_id), tongue_body_idx), ismember(1:length(contour_data.sections_id), tongue_body_idx)]);
plot(xy(1:end/2),xy(end/2+1:end),'Color',colr(2,:),'LineWidth',4)

tongue_tip_idx = 23:28;
xy = mean_vt_shape(1,[ismember(1:length(contour_data.sections_id), tongue_tip_idx), ismember(1:length(contour_data.sections_id), tongue_tip_idx)]);
plot(xy(1:end/2),xy(end/2+1:end),'Color',colr(3,:),'LineWidth',4)

h = zeros(3, 1);
for i=1:3
    h(i) = plot(NaN,NaN,'Color',colr(i,:),'LineWidth',2);
end
legend(h, {'jaw','tongue body','tongue tip'}, 'Location','SouthWest', 'FontSize', 18, 'FontName','Arial');
legend boxoff

axis off
axis([-40 20 -30 30]); hold off

print(fullfile(config_struct.out_path,'legend'),'-dpdf')
close all
