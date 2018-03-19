function config_struct = artstrat_config
% CONFIG - set constants and parameters of the analysis
% 
% INPUT
%  none
% 
% FUNCTION OUTPUT:
%  Variable name: configStruct
%  Size: 1x1
%  Class: struct
%  Description: Fields correspond to constants and hyperparameters. 
%  Fields: 
%  - out_path: (string) path for saving MATLAB output files
%  - in_path: (string) path to input files created by contour processing
%  - FOV: (double) size of field of view in mm^2
%  - Npix: (double) number of pixels per row/column in the imaging plane
%  - framespersec_<dataset>: (double) frame rate of reconstructed real-time
%      magnetic resonance imaging videos in frames per second for each 
%      data-set <dataset> of the analysis
%  - f: (double) hyperparameter which determines the percent of data used 
%      in locally weighted linear regression estimator of the jacobian; 
%      multiply f by 100 to obtain the percentage
% 
% SAVED OUTPUT: 
%  none
% 
% EXAMPLE USAGE: 
%  >> configStruct = config;
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Feb. 14, 2017

% paths
in_path = fullfile('..','mat','%s');
out_path = fullfile('..','mat','%s');

% fixed parameters
FOV = 200; % 200 mm^2 field of view 
Npix = 68; % 68^2 total pixels
%spatRes = FOV/Npix; % spatial resolution
frames_per_sec = 1/(2*0.006004); % compare to earlier 1/(7*6.164)*1000

% free parameters
f = 0.75;

% make the struct object
config_struct = struct('in_path',in_path,'out_path',out_path,...
    'FOV',FOV,'Npix',Npix,'frames_per_sec',frames_per_sec,'f', f);

end
