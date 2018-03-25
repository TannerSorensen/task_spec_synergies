addpath('util')

colr = hex2rgb({'#E41A1C','#377EB8','#4DAF4A','#984EA3','#FF7F00','#A65628'});

load(fullfile('.','data','contour_data_jaw1_tng4_lip2_vel1_lar2.mat'),'contour_data')
frames = contour_data.frames(contour_data.files==1);
idx = round(linspace(frames(1),frames(end),6));

vr = VideoReader(fullfile('.','data','4f_1_01.avi'));

% -----
% real-time MRI image
mkdir mri
for i=1:length(idx)
    figure
    currAxes = axes;
    colormap gray;
    vr.CurrentTime = contour_data.video_frames(idx(i))/vr.FrameRate;
    vidFrame = readFrame(vr);
    imagesc(vidFrame, 'Parent', currAxes);
    axis equal
    currAxes.Visible = 'off';
    print(sprintf('./mri/%d.pdf',i),'-dpdf')
end
close all
% -----

% -----
% segmentation results
mkdir segmentation
for i=1:length(idx)
    figure
    currAxes = axes;
    vr.CurrentTime = contour_data.video_frames(idx(i))/vr.FrameRate;
    vidFrame = readFrame(vr);
    imagesc(vidFrame, 'Parent', currAxes);
    colormap gray;
    
    hold on
    set(gca,'ColorOrder',colr)
    u_sec_id = unique(contour_data.sections_id);
    sections_id = contour_data.sections_id;
    for j=1:length(unique(contour_data.sections_id))
        vertex_idx = sections_id == j;
        plot(contour_data.X(idx(i),vertex_idx)+42.5, ...
            -(contour_data.Y(idx(i),vertex_idx)-42.5), 'LineWidth',2)
    end
    hold off
    
    axis equal
    currAxes.Visible = 'off';
    print(sprintf('./segmentation/%d.pdf',i),'-dpdf')
end
close all
% -----

% % -----
% % templates for [a i p t k]
% mkdir templates
% ttls = {'[a]','[i]','[p]','[t]','[k]'};
% load('template_struct.mat')
% for j=1:length(template_struct)
%     figure
%     set(gca,'ColorOrder',colr)
%     hold on
%     for i=1:length(template_struct(j).template.curves)
%         X = template_struct(j).template.curves(i).position;
%         plot(X(:,1),-X(:,2),'LineWidth',2)
%     end
%     hold off
%     currAxes = gca;
%     set(currAxes,'XColor','none','YColor','none')
%     axis equal
%     axis tight
%     title(ttls{j},'FontSize',20)
%     print(sprintf('./templates/%d.pdf',j),'-dpdf')
% end
% % -----


% -----
% constriction degree results
mkdir constrictions
for i=1:length(idx)
    figure
    currAxes = axes;
    colormap gray;
    vr.CurrentTime = contour_data.video_frames(idx(i))/vr.FrameRate;
    vidFrame = readFrame(vr);
    imagesc(vidFrame, 'Parent', currAxes);
    currAxes.Visible = 'off';
    
    hold on
    
    plot_from_xy([contour_data.X(idx(i),:)+42.5,  -(contour_data.Y(idx(i),:)-42.5)], contour_data.sections_id, colr(1,:))
    
    for j=1:(length(contour_data.tv)-1)
        in = contour_data.tv{j}.in;
        in = [in(1:(end/2)); in((end/2)+1:end)]';
        out = contour_data.tv{j}.out;
        out = [out(1:(end/2)); out((end/2)+1:end)]';
        in = in(idx(i),:);
        out = out(idx(i),:);
        scatter([in(1)+42.5 out(1)+42.5],[-in(2)+42.5 -out(2)+42.5],[],colr(2,:),'filled')
        plot([in(1)+42.5 out(1)+42.5],[-in(2)+42.5 -out(2)+42.5],'LineWidth',2,'Color',colr(2,:))
    end
    
    hold off
    print(sprintf('./constrictions/%d.pdf',i),'-dpdf')
end
% -----


