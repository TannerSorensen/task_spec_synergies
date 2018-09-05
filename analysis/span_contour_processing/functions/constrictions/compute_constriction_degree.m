function [d,x1,y1,x2,y2] = compute_constriction_degree(Xin,Yin,Xout,Yout)
%COMPUTE_CONSTRICTION_DEGREE - compute the constriction degree and
%constriction location between two structures.
% 
% INPUT:
%  Variable name: Xin
%  Size: 1x1
%  Class: double
%  Description: x-coordinate of inner vocal tract structure
% 
%  Variable name: Yin
%  Size: 1x1
%  Class: double
%  Description: y-coordinate of inner vocal tract structure
% 
%  Variable name: Xout
%  Size: 1x1
%  Class: double
%  Description: x-coordinate of outer vocal tract structure
% 
%  Variable name: Yout
%  Size: 1x1
%  Class: double
%  Description: y-coordinate of outer vocal tract structure
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
% 
% SAVED OUTPUT: 
%  none
% 
% EXAMPLE USAGE: 
%  >> [la(k),ul_x(k),ul_y(k),ll_x(k),ll_y(k)] = compute_constriction_degree(Xul,Yul,Xll,Yll);
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

    [d,x1,y1,x2,y2] = spanPolyPolyDist_modified(Xin,Yin,Xout,Yout);
    d = min(d);
    x1=x1(1); x2=x2(1); y1=y1(1); y2=y2(1);
end

