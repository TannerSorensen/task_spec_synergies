function plotTaskDemo(pathOut,graphicsPath,nf)
% PLOTTASKDEMO - run simulations of constrictions using the critically
% damped spring model of constrictions using the forward kinematic map as
% a parameter
% 
% input:
%  PATHOUT - path to save output
%  GRAPHICSPATH - path to save graphics
% 
% Last Updated: Oct. 13, 2016
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California

load(fullfile(pathOut, 'clusters.mat'))
load(fullfile(pathOut, 'gfa.mat'))
subj = fields(clusters);
nDir = length(subj);

[Nz,Nphi] = size(clusters.(subj{1}).jac{1});   % No. task variables z 
                                               % No. model articulators phi

% parameters of flow on task mass Z
omega = zeros(Nz,1);   % natural frequencies of task variables
z0 = [0 0 0 0 6]';   % targets for LA, alvCD, palCD, velCD, pharCD, VEL
W = eye(Nphi);

% parameters of the simulation
time = 0.2;            % time in sec
n_frames = 10;        % No. frames in which to linearize ODE
deltat = time./n_frames;
dt = 0.1*deltat;        % time step

total_nf = nf.nJaw + nf.nTng + nf.nLip + nf.nVel;

for h=1:nDir
    
    mu = mean(gfa.(subj{h}).parameters,1)';
    centers = clusters.(subj{h}).centers;
    fwd = clusters.(subj{h}).fwd;
    jac = clusters.(subj{h}).jac;
    jacDot = clusters.(subj{h}).jacDot;
    
    % initial conditions in weight space
    phiInit = [mu(1:Nphi); zeros(Nphi,1)];
    
    mean_vtshape = gfa.(subj{h}).mean_vtshape;
    U = gfa.(subj{h}).U_gfa;
    sigma = std(gfa.(subj{h}).weights(:,1:Nphi),1);

    for i=1:Nz
        
        omega(i) = 35;

        % solve the task dynamics
        [t,phi] = task_dynamics(omega,z0,dt,deltat,n_frames,phiInit,W,centers,fwd,jac,jacDot,Nz,Nphi,total_nf);
        
        omega(i) = 0;
        
        phi = cat(1,phi(1:Nphi,:),zeros(2,size(phi,2)));

        figID = figure('Color','w');
        axis([-40 40 -40 40]);
        for j=round(linspace(1,length(t),3))
            xy_data = weights_to_vtshape(([sigma'; zeros(2,1)].*phi(:,j))', mean_vtshape, U);
            hold on
            plot_from_xy(xy_data,gfa.(subj{h}).SectionsID,'k');
        end
        hold off
        
        axis tight
        %v=axis;
        %text(v(1),v(3)-0.1.*(v(4)-v(3)),sprintf(tvName{i}),'FontSize',28);
        axis off
        
        % create a PDF file
        fnam=[subj{h} '_task_demo_' num2str(i) '.png'];
        print(fullfile(graphicsPath, fnam),'-dpng');
        close(figID)
%         
%         % create video
%         fnam=[subj{h} '_simulation_video_' num2str(i) '.avi'];
%         v = VideoWriter(fullfile(graphicsPath, fnam));
%         v.FrameRate = 24;
%         open(v)
% 
%         figID = figure('Color','w');
%         for j=round(linspace(1,size(phi,2),2*24))
% 
%             xy_data = weights_to_vtshape(([sigma'; zeros(2,1)].*phi(:,j))', mean_vtshape, U);
%             plot_from_xy(xy_data,gfa.(subj{h}).SectionsID,'k');
%             axis square, axis tight, axis off
% 
%             frame = getframe(figID,[0 0 560 420]);
%             writeVideo(v,frame)
%             clf
%         end
%         close(v)
%         close(figID)
%     end
end

end