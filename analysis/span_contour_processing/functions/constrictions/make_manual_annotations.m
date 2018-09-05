function make_manual_annotations(config_struct,file_name)
%MAKE_MANUAL_ANNOTATIONS Create a .mat file FILE_NAME containing two
%indices of the pharynx contour vertices marking the inferior and superior
%edges of the naso and hypopharynx. The path to FILE_NAME is provided in
%the field 'manual_annotations_path' of the structured array CONFIG_STRUCT.
% 
% INPUT:
%  Variable name: config_struct
%  Size: 1x1
%  Class: struct
%  Description: Fields correspond to constants and hyperparameters. 
%  Fields: 
%  - out_path: (string) path for saving MATLAB output
%  - track_path: (string) path to segmentation results
%  - manual_annotations_path: (string) path to manual annotations
%  - fov: (double) size of field of view in mm^2
%  - n_pix: (double) number of pixels per row/column in the imaging plane
%  - frames_per_sec: (double) frame rate of reconstructed real-time
%      magnetic resonance imaging videos in frames per second
% 
%  Variable name: file_name
%  Size: 1xN, N undetermined
%  Class: char
%  Description: string file name of file containing contour_data struct
%   array at the path config_struct.out_path.
% 
% FUNCTION OUTPUT:
%  none
% 
% SAVED OUTPUT:
%  File name: phar_idx.mat
%  Variable name: phar_idx
%  Size: 1x2
%  Class: double
%  Description: array of two pharynx contour indices, one specifying the 
%    first and the other specifying the last index of the contour vertices 
%    of the nasopharynx and hypopharynx. 
% EXAMPLE USAGE: 
%  >> make_manual_annotations(config_struct,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2.mat',q.jaw,q.tng,q.lip));
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

    % load contour data
    load(fullfile(config_struct.out_path,file_name),'contour_data');
    
    % break contours down into parts
    [~,~,~,~,Xtongue,Ytongue,~,~,~,~,Xvelum,Yvelum,~,~,Xphar,Yphar,Xepig,Yepig] = vt_seg(contour_data,contour_data.files(1),contour_data.frames(1),1,false,[1 50]);
    
    accept_state = false;
    while accept_state==false
        % plot contours
        figure(1)
        plot(Xtongue,Ytongue), hold on
        plot(Xepig,Yepig)
        plot(Xphar,Yphar)
        plot(Xvelum,Yvelum)
        axis equal
        
        % obtain manual annotations
        disp('Click on the boundaries of the rear pharyngeal wall. Include the nasopharynx and hypopharynx, but no larynx.')
        [x_click,y_click] = ginput(2);
        
        % find closest points to user input
        dists = pdist2([Xphar' Yphar'],[x_click y_click]);
        [~,phar_idx] = min(dists);
        phar_idx = sort(phar_idx);
        
        % plot user input
        plot(Xphar(phar_idx(1):phar_idx(2)),Yphar(phar_idx(1):phar_idx(2)),'LineWidth',2), hold off
        
        % obtain feedback (iterate or accept?)
        kb_input = input('Accept? [Y/n]','s');
        if strcmpi(kb_input,'n')
            accept_state = false;
        else
            accept_state = true;
            close all
        end
    end
    
    % save manual annotations
    if exist(config_struct.manual_annotations_path,'dir')==0
        mkdir(config_struct.manual_annotations_path)
    end
    save(fullfile(config_struct.manual_annotations_path,'phar_idx.mat'),'phar_idx');
    
end

