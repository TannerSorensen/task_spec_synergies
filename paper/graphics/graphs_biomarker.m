data_path = '/Users/tannersorensen/task_spec_synergies/analysis/mat/m5_rep1';
file_name = 'contour_data_jaw1_tng4_lip2_vel1_lar2_f20.mat';
graphics_path = fullfile(pwd,'biomarker');
if ~exist(graphics_path,'dir')
    mkdir(graphics_path)
end
graph_file_name = 'biomarker_demo.pdf';
load(fullfile(data_path,file_name))

tv_idx = 3;  % integer number from 1 to 6
rep_idx = 8; % integer number from 0 to 9

file_name = sprintf('m5_rep1_aia_%d_track.mat',rep_idx);
file_number = find(cellfun(@(x) strcmp(x,file_name),contour_data.file_list));
file_idx = contour_data.files == file_number;

jaw = contour_data.strategies.jaw(file_idx,tv_idx);
tng = contour_data.strategies.tng(file_idx,tv_idx);

jaw = cumsum(jaw);
tng = cumsum(tng);

jaw = jaw - max(jaw);
tng = tng - max(tng);

fs = 14;

figure(1)
cm = colormap('bone');
X = [jaw, jaw+tng];
b = bar(X,'stacked');
b(1).FaceColor = 'flat';
b(1).CData = repmat(cm(25,:),size(b(1).CData,1),1);
b(2).FaceColor = 'flat';
b(2).CData = repmat(cm(end-15,:),size(b(2).CData,1),1);

hold on

x0 = 3;
x1 = 0.05*83 + x0;
y0 = -12;
y1 = y0+5;
plot([x0; x1], [y0; y0], '-k',  [x0; x0], [y0; y1], '-k', 'LineWidth', 2)
text(x0-0.5,mean([y0 y1]), '5 mm', 'HorizontalAlignment','right','FontSize',fs)
text(mean([x0 x1]),y0-1, '50 ms', 'HorizontalAlignment','center','FontSize',fs)
set(gca, 'Visible', 'off')

% onset text
onset_text = text(1,1.5,{'constriction','onset'});
set(onset_text,'Rotation',60,'FontSize',fs)
plot([1 1],[0 1],'k-')

% offset text
offset_text = text(size(jaw,1),1.5,{'release','offset'});
set(offset_text,'Rotation',60,'FontSize',fs)
plot(repmat(size(jaw,1),2,1),[0 1],'k-')

% middle text
middle_text = text(21,1.5,{'maximum','constriction'});
set(middle_text,'Rotation',60,'FontSize',fs)
plot([21 21],[0 1],'k-')

ylabel({'elapsed change in palatal','constriction degree (mm)'},'FontSize',fs)
ylim([-14 1])
xlabel('time-sample','FontSize',fs)
xlim([0 size(jaw,1)+6])
lgd = legend('jaw','tongue','Location','SouthEast');
lgd.FontSize = fs;
pbaspect([3 1 1])

hold off

print(fullfile(graphics_path,graph_file_name),'-dpdf')