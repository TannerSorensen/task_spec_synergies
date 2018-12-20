addpath(genpath(fullfile('..','..','analysis','span_contour_processing','functions')))
addpath(fullfile('..','..','analysis','scripts'))

q = struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2);
f = 0.2;
load(fullfile('..','..','analysis','mat','f1_rep1',sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d_f%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar,round(100*f))),'contour_data')

config_struct = config;
config_struct.out_path = fullfile(pwd,'gfa');

if ~exist(config_struct.out_path,'dir')
    mkdir(config_struct.out_path)
end
plot_components(config_struct, contour_data, 'sorensen2018', q);

% legend
figure, hold on
h = zeros(3, 1);
h(1) = plot(NaN,NaN,'r','LineWidth',2);
h(2) = plot(NaN,NaN,'k','LineWidth',2);
h(3) = plot(NaN,NaN,'b','LineWidth',2);
legend(h, {'mean +2 S.D.','mean','mean -2 S.D.'},'FontName','Arial');
legend boxoff
axis off
hold off
print(fullfile(config_struct.out_path,'factor_legend.pdf'),'-dpdf')
