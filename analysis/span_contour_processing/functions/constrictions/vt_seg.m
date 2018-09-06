function [Xul,Yul,Xll,Yll,Xtongue,Ytongue,Xalveolar,...
    Yalveolar,Xpalatal,Ypalatal,Xvelum,Yvelum,Xvelar,...
    Yvelar,Xphar,Yphar,Xepig,Yepig] = vt_seg(contour_data, file_name, ...
    frame_number, ds, sim_switch, varargin)
% VT_SEG - break the vocal tract contours into parts
% 
% INPUT:
%  Variable name: contour_data
%  Size: 1x1
%  Class: struct
%  Description: Contains the contour data, along with the constriction
%    degrees computed by this function. Other fields are possible, but the
%    fields required are listed below. 
%  Fields: 
%  - X: (double array) array of x-coordinates for each contour vertex
%    (column) and for each real-time MR image (row). Required if sim_switch
%    is false.
%  - Y: (double array) array of y-coordinates for each contour vertex
%    (column) and for each real-time MR image (row). Required if sim_switch
%    is false.
%  - Xsim: (double array) array of x-coordinates for each contour vertex
%    (column) and for each real-time MR image (row), projected onto the
%    column space of the factors. Required if sim_switch is true.
%  - Ysim: (double array) array of y-coordinates for each contour vertex
%    (column) and for each real-time MR image (row), projected onto the
%    column space of the factors. Required if sim_switch is true.
%  - files: (double array) array of file numbers for each real-time MR
%    image.
%  - frames: (double array) array of frame numbers for each real-time MR
%    image.
%  - sections_id: (double array) array of numeric IDs for X- and Y-
%    coordinates in the columns of the variables in fields X, Y; the 
%    correspondences are as follows: 01 Epiglottis; 02 Tongue; 03 Incisor; 
%    04 Lower Lip; 05 Jaw; 06 Trachea; 07 Pharynx; 08 Upper Bound; 09 Left 
%    Bound; 10 Low Bound; 11 Palate; 12 Velum; 13 Nasal Cavity; 14 Nose; 15
%    Upper Lip.
% 
% FUNCTION OUTPUT:
%  Variable name: Xul
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the upper lip contour vertices
% 
%  Variable name: Yul
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the upper lip contour vertices
% 
%  Variable name: Xll
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the lower lip contour vertices
% 
%  Variable name: Yll
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the lower lip contour vertices
% 
%  Variable name: Xtongue
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the tongue contour vertices
% 
%  Variable name: Ytongue
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the tongue contour vertices
%  
%  Variable name: Xalveolar
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the alveolar ridge contour vertices
% 
%  Variable name: Yalveolar
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the alveolar ridge contour vertices
% 
%  Variable name: Xpalatal
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the hard palate contour vertices
% 
%  Variable name: Ypalatal
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the hard palate contour vertices
% 
%  Variable name: Xvelum
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the soft palate contour vertices
% 
%  Variable name: Yvelum
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the soft palate contour vertices
% 
%  Variable name: Xvelar
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the anteriormost soft palate contour 
%   vertices
% 
%  Variable name: Yvelar
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the anteriormost soft palate contour 
%   vertices
% 
%  Variable name: Xphar
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the pharynx contour vertices
% 
%  Variable name: Yphar
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the pharynx contour vertices
% 
%  Variable name: Xepig
%  Size: undetermined
%  Class: double
%  Description: x-coordinates of the epiglottis contour vertices
% 
%  Variable name: Yepig
%  Size: undetermined
%  Class: double
%  Description: y-coordinates of the epiglottis contour vertices
% 
% SAVED OUTPUT:
%  none
% 
% EXAMPLE USAGE:
%  >> [Xul,Yul,Xll,Yll,Xtongue,Ytongue,Xalveolar,...
%      Yalveolar,Xpalatal,Ypalatal,Xvelum,Yvelum,...
%      Xvelar,Yvelar,Xphar,Yphar,Xepig,Yepig] = vt_seg(contour_data,...
%      i,frames(j),ds,sim_switch,phar_idx);
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

    if nargin < 6
        manual_annotation_flag = false;
    elseif nargin == 6
        manual_annotation_flag = true;
        phar_idx = varargin{1};
    end
    
    if ~sim_switch
        X=contour_data.X((contour_data.files == file_name & contour_data.frames == frame_number)',:);
        Y=contour_data.Y((contour_data.files == file_name & contour_data.frames == frame_number)',:);
    else
        X=contour_data.Xsim((contour_data.files == file_name & contour_data.frames == frame_number)',:);
        Y=contour_data.Ysim((contour_data.files == file_name & contour_data.frames == frame_number)',:);
    end
    
    % upper lip
    Xul = X(ismember(contour_data.sections_id,15));
    Yul = Y(ismember(contour_data.sections_id,15));
    if ~isempty(Xul)
        Xul = interp1(Xul,1:ds:length(Xul));
        Yul = interp1(Yul,1:ds:length(Yul));
    end
    
    % lower lip
    Xll = X(ismember(contour_data.sections_id,4));
    Yll = Y(ismember(contour_data.sections_id,4));
    if ~isempty(Xul)
        Xll = interp1(Xll,1:ds:length(Xll));
        Yll = interp1(Yll,1:ds:length(Yll));
    end
    
    % tongue
    Xtongue = X(ismember(contour_data.sections_id,2));
    Ytongue = Y(ismember(contour_data.sections_id,2));
    if ~isempty(Xtongue)
        Xtongue=interp1(Xtongue,1:ds:length(Xtongue));
        Ytongue=interp1(Ytongue,1:ds:length(Ytongue));
    end
    
    % epiglottis
    Xepig = X(ismember(contour_data.sections_id,1));
    Yepig = Y(ismember(contour_data.sections_id,1));
    if ~isempty(Xepig)
        Xepig=interp1(Xepig,1:ds:length(Xepig));
        Yepig=interp1(Yepig,1:ds:length(Yepig));
    end
    
    % palate and pharynx
    Xalveolar = X(ismember(contour_data.sections_id,11));
    Yalveolar = Y(ismember(contour_data.sections_id,11));
    Xpalatal =  Xalveolar;
    Ypalatal =  Yalveolar;
    Xvelum = X(ismember(contour_data.sections_id,12));
    Yvelum = Y(ismember(contour_data.sections_id,12));
    Xalveolar = interp1(Xalveolar,1:ds:length(Xalveolar));
    Yalveolar = interp1(Yalveolar,1:ds:length(Yalveolar));
    Xpalatal = interp1(Xpalatal,1:ds:length(Xpalatal));
    Ypalatal = interp1(Ypalatal,1:ds:length(Ypalatal));
    Xvelum = interp1(Xvelum,1:ds:length(Xvelum));
    Yvelum = interp1(Yvelum,1:ds:length(Yvelum));
    Xalveolar = Xalveolar(1:3*ds^-1); 
    Yalveolar = Yalveolar(1:3*ds^-1);
    Xpalatal = Xpalatal(5*ds^-1:end-ds^-1);
    Ypalatal = Ypalatal(5*ds^-1:end-ds^-1);
    Xvelar = Xvelum(1:2*ds^-1);
    Yvelar = Yvelum(1:2*ds^-1);
    
    % pharynx
    Xphar = X(ismember(contour_data.sections_id,[7 8]));
    Yphar = Y(ismember(contour_data.sections_id,[7 8]));
    if manual_annotation_flag == true && length(phar_idx) == 2
        phar_idx(2) = min([phar_idx(2) length(Xphar)]);
        Xphar = Xphar(phar_idx(1):phar_idx(2)); 
        Yphar = Yphar(phar_idx(1):phar_idx(2));
    end
    if ~isempty(Xphar)
        Xphar = interp1(Xphar,1:ds:length(Xphar));
        Yphar = interp1(Yphar,1:ds:length(Yphar));
    end
    
end