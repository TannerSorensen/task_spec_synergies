addpath(genpath(fullfile('..','..','analysis','span_contour_processing','functions')))
addpath(fullfile('..','..','analysis','scripts'))

q = struct('jaw',1,'tng',4,'lip',3,'vel',1,'lar',2);
f = 0.2;
load(fullfile('..','..','analysis','mat','f1_rep1',sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d_f%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar,round(100*f))),'contour_data')

config_struct = config;
config_struct.out_path = fullfile(pwd,'gfa');

if ~exist(config_struct.out_path,'dir')
    mkdir(config_struct.out_path)
end
plot_components(config_struct, contour_data, 'sorensen2018', q);