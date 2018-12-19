graphics_path = fullfile(pwd,'validation');
graph_file_name = 'validation_graphic';
if ~exist(graphics_path,'dir')
    mkdir(graphics_path)
end
tv_names = {'bilabial','alveolar','palatal','velar','pharyngeal'};

real_participant_name = 'm5_rep1';
contour_data_filename = 'contour_data_jaw1_tng4_lip2_vel1_lar2_f100.mat';
for i=1:15
    load(fullfile('..','..','analysis','mat_synth',[real_participant_name '_' num2str(i)],contour_data_filename))
    contour_data.strategies.biomarker.Properties.VariableNames = {'file' 'tv' ['bm' num2str(i)]};
    if i==1
        bm_tab = contour_data.strategies.biomarker;
        true_bm_tab = table(contour_data.true_bm_labels,contour_data.true_bm,'VariableNames',{'filename',['bm' num2str(i)]});
    else
        bm_tab = [bm_tab contour_data.strategies.biomarker(:,3)];
        true_bm_tab = [true_bm_tab table(contour_data.true_bm,'VariableNames',{['bm' num2str(i)]})];
    end
end

% declare array of jaw weights from 10^-2 to 10^2 in 10 steps
% (the point of validation.m is to evaluate agreement between articulator
% synergy biomarker and known jaw weights)
jaw_weight_parameters = logspace(-3,2,15);

% make plot for each task variable
figure(1)
set(0,'defaultAxesFontSize',18)
cm = lines;
lgd_lines = zeros(1,5);
for tv = 1:5
    true_subtab = true_bm_tab(cellfun(@(x) contains(x,tv_names(tv)), true_bm_tab.filename), 2:end);
    lgd_lines(tv) = semilogx(jaw_weight_parameters,mean(table2array(true_subtab),1), 'Color', cm(tv,:), 'LineWidth', 2);
    hold on
    for j=1:15
        scatter(jaw_weight_parameters(j).*ones(size(true_subtab,1),1), ...
            table2array(true_subtab(:,j)), 50, cm(tv,:))
    end
end
set(gca,'TickLength',[0.025, 0.01],...
    'XLim',[10e-5 10e2],...
    'YLim',[-0.05 1.05],...
    'XTick',[10e-5 10e-4 10e-3 10e-2 10e-1 10e0 10e1 10e2], ...
    'YTick',0:0.2:1, ...
    'YTickLabel',{'(no jaw) 0%','20%','40%','60%','80%','(all jaw) 100%'},...
    'YMinorTick','on')
ylabel('articulator synergy biomarker')
xlabel('theoretical jaw weight parameter')
plot([10e-4 10e2],[1 1],'--k')
plot([10e-4 10e2],[0 0],'--k')
grid on
axis square
hold off
legend(lgd_lines,{'bilabial','alveolar','palatal','velar','pharyngeal'})
print(fullfile(graphics_path,[graph_file_name num2str(1)]),'-dpdf')








% 
% make plot for each task variable
figure(2)
set(0,'defaultAxesFontSize',18)
cm = lines;
lgd_lines = zeros(1,5);
plot([0 1],[0 1],'--k')
hold on
for tv = 1:5
    subtab = bm_tab(bm_tab.tv == tv,:);
    true_subtab = true_bm_tab(cellfun(@(x) contains(x,tv_names(tv)), true_bm_tab.filename), 2:end);
    x = mean(table2array(true_subtab(:,1:end)));
    y = mean(table2array(subtab(:,3:end)),1);
    lgd_lines(tv) = scatter(x, y, 10^2, cm(tv,:), 'filled');
end
set(gca,'XLim',[-0.05 1.05],...
    'YLim',[-0.05 1.05],...
    'XTick',0:0.2:1, ...
    'YTick',0:0.2:1, ...
    'XTickLabel',{'(no jaw) 0%','20%','40%','60%','80%','(all jaw) 100%'},...
    'YTickLabel',{'(no jaw) 0%','20%','40%','60%','80%','(all jaw) 100%'},...
    'XTickLabelRotation',30)
ylabel('measured biomarker')
xlabel('true biomarker')
grid on
hold off
legend(lgd_lines,{'bilabial','alveolar','palatal','velar','pharyngeal'},'Location','NorthWest')
print(fullfile(graphics_path,[graph_file_name num2str(2)]),'-dpdf')









% make plot for each task variable
figure(3)
set(0,'defaultAxesFontSize',18)
cm = lines;
hold on
plot([0 1],mean(x-y)*ones(1,2),'-k','LineWidth',2)
plot([0 1],mean(x-y)+1.96*std(x-y)*ones(1,2),'--k','LineWidth',2)
plot([0 1],mean(x-y)-1.96*std(x-y)*ones(1,2),'--k','LineWidth',2)
for tv = 1:5
    subtab = bm_tab(bm_tab.tv == tv,:);
    true_subtab = true_bm_tab(cellfun(@(x) contains(x,tv_names(tv)), true_bm_tab.filename), 2:end);
    x = mean(table2array(true_subtab(:,1:end)));
    y = mean(table2array(subtab(:,3:end)),1);
    scatter(mean([x;y],1), x-y, 10^2, cm(tv,:), 'filled');
end

set(gca,'XLim',[-0.05 1.05],...
    'YLim',[-0.035 0.035],...
    'XTick',0:0.2:1, ...
    'YTick',-0.03:0.005:0.03, ...
    'XTickLabel',{'(no jaw) 0%','20%','40%','60%','80%','(all jaw) 100%'}, ...
    'YTickLabel',arrayfun(@(x) [num2str(x) '%'], 100*[-0.03:0.005:0.03], 'UniformOutput', false), ...
    'XTickLabelRotation',30)
ylabel('difference')
xlabel('average')
grid on
hold off

text(0.65,mean(x-y)-0.002,sprintf('bias: %.2f%%',100*mean(x-y)), 'FontSize', 18)
text(0.65,mean(x-y)+1.96*std(x-y)+0.0025,sprintf('+1.96 SD: %.2f%%',100*(mean(x-y)+1.96*std(x-y))), 'FontSize', 18)
text(0.65,mean(x-y)-1.96*std(x-y)-0.0025,sprintf('-1.96 SD: %.2f%%',100*(mean(x-y)-1.96*std(x-y))), 'FontSize', 18)

print(fullfile(graphics_path,[graph_file_name num2str(3)]),'-dpdf')
