
addpath(fullfile(pwd,'..','simulation'))

config_struct = config;
config_struct.f = 70;

% right now, because of phiZRel it only works with 1,4,2,1,2 factors, with
% lar hacked off
load(sprintf('../mat/ac2_var/contour_data_jaw1_tng4_lip2_vel1_lar2_f%02d.mat',config_struct.f))

contour_data.weights = contour_data.weights(:,1:end-2);
contour_data.U_gfa = contour_data.U_gfa(:,1:end-2);

% MRI parameters
frameRate = config_struct.frames_per_sec; % frame rate

% parameters of the simulation
n_tv = size(contour_data.tv,2);
n_factor = size(contour_data.U_gfa,2);
omega = zeros(n_tv,1); % natural frequencies of task variables
z0 = zeros(n_tv,1);    % targets for LA, alvCD, palCD, velCD, pharCD, VEL
W = eye(n_factor);
time = 0.6;            % time in sec
n_frames = 10;         % No. frames in which to linearize ODE
h2 = time./n_frames;
h1 = (1/n_frames)*h2;           % time step
phiInit = zeros(2*n_factor,1);
f = config_struct.f;

z = zeros(length(contour_data.tv{1}.cd),n_tv);
for j=1:n_tv
    z(:,j) = contour_data.tv{j}.cd;
end
w = contour_data.weights;
[dzdt,dwdt] = getGrad(z,w,contour_data.files);

omega(1) = 10;
W(1,1) = 4;


%%

[t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,f);
c = linspecer(8);
for ii=1:8
    plot(t,phiOut(ii,:),'color',c(ii,:),'LineWidth',2), hold on
end
legend({'jaw','tongue 1','tongue 2','tongue 3','tongue 4','lips 1','lips2','velum'},'Location','NorthWest')
hold off

%%

plot(t,zOut)

%%

addpath(genpath(fullfile(pwd,'..','span_contour_processing')))

W(1,1) = 0.25;
[t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,f);
init_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,1);
end_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,end);
plot_from_xy(end_vt_shape,contour_data.sections_id,'r'), hold on

W(1,1) = 4;
[t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,phiInit,W,n_tv,n_factor,z,w,dzdt,dwdt,f);
init_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,1);
end_vt_shape = contour_data.mean_vt_shape' + contour_data.U_gfa*phiOut(1:8,end);
plot_from_xy(end_vt_shape,contour_data.sections_id,'b')

plot_from_xy(init_vt_shape,contour_data.sections_id,'--k'), hold off

