function configStruct = build_model_config
% BUILD_MODEL_CONFIG - set constants and parameters of the analysis
% 
% INPUT:
%  none
% 
% FUNCTION OUTPUT:
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
%  - verbose: (logical) if true, plot graphics; otherwise, do not plot.
% 
% SAVED OUTPUT: 
%  none
% 
% EXAMPLE USAGE: 
%  >> config_struct = config;
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

% paths
out_path = fullfile('..','mat','%s');
track_path = fullfile('..','segmentation_results','%s','track_files');
manual_annotations_path = fullfile('..','manual_annotations','%s');

% spatial parameters
fov = 200;  % 200 mm^2 field of view 
n_pix = 84; % 68^2 total pixels 
            % in-plane spatial resolution is FOV/Npix

% temporal parameters
tr_per_image = 2;
tr = 0.006004;
frames_per_sec = 1/(tr_per_image*tr);

% free parameters
f = 0.75;

verbose = false;

% make the struct object
configStruct = struct('out_path',out_path,...
    'track_path',track_path,...
    'manual_annotations_path',manual_annotations_path,...
    'fov',fov,'n_pix',n_pix,...
    'frames_per_sec',frames_per_sec,...
    'f',f,'verbose',verbose);

end
