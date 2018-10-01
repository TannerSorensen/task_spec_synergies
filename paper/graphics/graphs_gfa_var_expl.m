
% add folder containing articulatory strategies script to path
addpath(genpath(fullfile(pwd,'..','span_contour_processing')))

mkdir(fullfile(pwd,'gfa_var_expl'))

mat_path = fullfile('..','..','analysis','mat');
participant_list = dir(mat_path);
participant_list = {participant_list(arrayfun(@(x) x.isdir && ~startsWith(x.name,'.') && contains(x.name,'rep1'), participant_list)).name};

q_jaw = [0 1 2 3];
q_tng = [0 4 6 8];
q_lip = [0 2 3];

spat_res = 200/84;

for i=1:length(participant_list)

    file_name = dir(fullfile(mat_path,participant_list{i}));
    file_name = file_name(arrayfun(@(x) contains(x.name,'contour_data_jaw3_tng8_lip2_vel1_lar2_f90.mat'), file_name)).name;
    load(fullfile(mat_path,participant_list{i},file_name))

    % compute jaw variance explained
    w = contour_data.weights;
    U = contour_data.U_gfa;
    D = [contour_data.X,contour_data.Y];
    sec_id = contour_data.sections_id;
    n = size(w,1);

    for j=1:length(q_jaw)
        xy = D;
        jaw_idx = 1:q_jaw(j);
        xy_mean = repmat(contour_data.mean_vt_shape,n,1);
        xy_hat = xy_mean + w(:,jaw_idx)*U(:,jaw_idx)';
        xy_hat(:,~ismember([sec_id,sec_id],[3 5])) = [];
        xy(:,~ismember([sec_id,sec_id],[3 5])) = [];
        xy_mean(:,~ismember([sec_id,sec_id],[3 5])) = [];
        err = sqrt((xy - xy_hat).^2);
        err = err * spat_res;
        jaw_var_expl(i,j) = 1 - sum((xy_hat(:)-xy(:)).^2) / sum((xy(:)-xy_mean(:)).^2);
        jaw_err_med(i,j) = median(err(:));
        jaw_err_rng(i,j,:) = quantile(err(:),[0.1,0.9]);
        for k=1:length(q_tng)
            xy = D;
            tng_idx = [jaw_idx, (max(q_jaw)+1):(max(q_jaw)+q_tng(k))];
            xy_mean = repmat(contour_data.mean_vt_shape,n,1);
            xy_hat = xy_mean + w(:,tng_idx)*U(:,tng_idx)';
            xy_hat(:,~ismember([sec_id,sec_id],2)) = [];
            xy(:,~ismember([sec_id,sec_id],2)) = [];
            xy_mean(:,~ismember([sec_id,sec_id],2)) = [];
            err = sqrt((xy - xy_hat).^2);
            err = err * spat_res;
            tng_var_expl(i,j,k) = 1 - sum((xy_hat(:)-xy(:)).^2) / sum((xy(:)-xy_mean(:)).^2);
            tng_err_med(i,j,k) = median(err(:));
            tng_err_rng(i,j,k,:) = quantile(err(:),[0.1,0.9]);
        end
        for k=1:length(q_lip)
            xy = D;
            lip_idx = [jaw_idx, (max(q_jaw)+max(q_tng)+1):(max(q_jaw)+max(q_tng)+q_lip(k))];
            xy_mean = repmat(contour_data.mean_vt_shape,n,1);
            xy_hat = xy_mean + w(:,lip_idx)*U(:,lip_idx)';
            xy_hat(:,~ismember([sec_id,sec_id],[4 15])) = [];
            xy(:,~ismember([sec_id,sec_id],[4 15])) = [];
            xy_mean(:,~ismember([sec_id,sec_id],[4 15])) = [];
            err = sqrt((xy - xy_hat).^2);
            err = err * spat_res;
            lip_var_expl(i,j,k) = 1 - sum((xy_hat(:)-xy(:)).^2) / sum((xy(:)-xy_mean(:)).^2);
            lip_err_med(i,j,k) = median(err(:));
            lip_err_rng(i,j,k,:) = quantile(err(:),[0.1,0.9]);
        end
    end
end

cm = colormap('lines');

% jaw explained variance
figure
hold on
plot(q_jaw, mean(jaw_var_expl,1), '-o', 'Color', cm(1,:), 'LineWidth', 2)
plot([min(q_jaw) max(q_jaw)],[0 0], '--k')
plot([min(q_jaw) max(q_jaw)],[1 1], '--k')
xlim([min(q_jaw)-0.1 max(q_jaw)+0.1])
ylim([-0.05 1.05])
set(gca,'box','off')
set(gca,'YGrid','on')
set(gca,'XGrid','off')
set(gca,'XTick',q_jaw)
set(gca,'YTick',linspace(0,1,11),'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
ylabel('explained variance (%)')
xlabel('number of jaw factors')
set(gca,'FontSize',18), hold off
print(fullfile(pwd,'gfa_var_expl','jaw_var_expl.pdf'),'-dpdf')

% tongue explained variance
figure
hold on
h=[];
for j=1:length(q_jaw)
    h(j) = plot(1:length(q_tng), squeeze(mean(tng_var_expl(:,j,:),1)), '-o', 'Color', cm(j,:), 'LineWidth', 2);
end
plot([min(q_tng) max(q_tng)],[0 0], '--k')
plot([min(q_tng) max(q_tng)],[1 1], '--k'), hold off
xlim([0.9 length(q_tng)+0.1])
ylim([-0.05 1.05])
set(gca,'box','off')
set(gca,'YGrid','on')
set(gca,'XGrid','off')
set(gca,'XTick',1:length(q_tng),'XTickLabel',q_tng)
ylabel('explained variance (%)')
set(gca,'YTick',linspace(0,1,11),'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
xlabel('number of tongue factors')
legend(h,{'0 jaw factors','1 jaw factor','2 jaw factors','3 jaw factors'},'Location','SouthEast')
set(gca,'FontSize',18)
print(fullfile(pwd,'gfa_var_expl','tongue_var_expl.pdf'),'-dpdf')

% lips explained variance
figure
hold on
h=[];
for j=1:length(q_jaw)
    h(j) = plot(1:length(q_lip), squeeze(mean(lip_var_expl(:,j,:),1)), '-o', 'Color', cm(j,:), 'LineWidth', 2);
end
plot([min(q_lip) max(q_lip)],[0 0], '--k')
plot([min(q_lip) max(q_lip)],[1 1], '--k'), hold off
xlim([0.9 length(q_lip)+0.25])
ylim([-0.05 1.05])
set(gca,'box','off')
set(gca,'YGrid','on')
set(gca,'XGrid','off')
set(gca,'XTick',1:length(q_lip),'XTickLabel',q_lip)
set(gca,'YTick',linspace(0,1,11),'YTickLabel',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'})
ylabel('explained variance (%)')
xlabel('number of lip factors')
set(gca,'FontSize',18)
print(fullfile(pwd,'gfa_var_expl','lips_var_expl.pdf'),'-dpdf')

close all
