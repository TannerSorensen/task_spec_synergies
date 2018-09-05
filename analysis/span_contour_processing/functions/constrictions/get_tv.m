function get_tv(config_struct,varargin)
% GET_TV - compute constriction degrees at the phonetic places of articulation
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
% OPTIONAL INPUT:
%  Variable name: sim_switch
%  Size: 1x1
%  Class: logical
%  Default value: false
%  Description: logical flag that indicates whether to compute constriction
%    degrees using original (x,y)-coordinates of articulator contours
%    (false) or using the (x,y)-coordinates of articulator contours that
%    have been projected onto the column space of the factors (true).
% 
%  Variable name: q
%  Size: 1x1
%  Class: struct
%  Default value: struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2)
%  Description: struct array that indicates the number of factors for the
%    jaw, tongue, lips, velum, and larynx.
% 
%  Variable name: phar_idx
%  Size: 0x0 or 1x2
%  Class: double
%  Defailt value: []
%  Description: either empty array or array of two pharynx contour indices,
%    one specifying the first and the other specifying the last index of
%    the contour vertices of the nasopharynx and hypopharynx. If empty, all
%    contour vertices after 15 are used, a trick which removes most of the
%    trachea and larynx contour vertices. See 'make_manual_annotations.m'
%    for details of how to obtain phar_idx by manual annotation.
% 
% FUNCTION OUTPUT:
%  none
% 
% SAVED OUTPUT: 
%  File name: given by the string value of 
%    sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)
%  Variable name: contour_data
%  Size: 1x1
%  Class: struct
%  Description: Contains the contour data, along with the constriction
%    degrees computed by this function. Other fields are possible, but the
%    fields added are listed below. 
%  Fields: 
%  - tv: (cell array) cell array of length 6 with the fields corresponding
%     to the phonetic places of articulation: 
%       (1) LA - lip aperture; 
%       (2) ALV - alveolar constriction degree; 
%       (3) PAL - palatal constriction degree; 
%       (4) VEL - velar constriction degree;
%       (5) PHAR - pharyngeal constriction degree; 
%       (6) VP - velopharyngeal port. 
%      Each field is a structured array with fields corresponding to
%      consriction degree, index of inner structure used to compute the
%      constriction degree, and index of the outer structure used to
%      compute the constriction degree.
%       cd - (Nx1) double array containing constriction degrees
%       in - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of inner structure used to compute the
%       constriction degree.
%       out - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of outer structure used to compute the
%       constriction degree.
%     This field is added if sim_switch is false. 
% 
%  - tvsim: (cell array) cell array of length 6 with the fields 
%     corresponding to the phonetic places of articulation: 
%       (1) LA - lip aperture; 
%       (2) ALV - alveolar constriction degree; 
%       (3) PAL - palatal constriction degree; 
%       (4) VEL - velar constriction degree;
%       (5) PHAR - pharyngeal constriction degree; 
%       (6) VP - velopharyngeal port. 
%      Each field is a structured array with fields corresponding to
%      consriction degree, index of inner structure used to compute the
%      constriction degree, and index of the outer structure used to
%      compute the constriction degree.
%       cd - (Nx1) double array containing constriction degrees
%       in - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of inner structure used to compute the
%       constriction degree.
%       out - (Nx2) double array containing x (1st column) and y (2nd
%       column) of index of outer structure used to compute the
%       constriction degree.
%     This field is added if sim_switch is true.
% 
% EXAMPLE USAGE: 
%  >> get_tv(config_struct,false,q,phar_idx)
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

if nargin < 2
    sim_switch = false;
    phar_idx = [];
elseif nargin == 2
    sim_switch = varargin{1};
    phar_idx = [];
elseif nargin == 3
    sim_switch = varargin{1};
    phar_idx = varargin{2};
else
    sim_switch = false;
    phar_idx = [];
    warning(['Function get_tv.m was called with %d input arguments,' ...
        ' but requires 1 (optionally 2 or 3)'],nargin)
end

% load articulator contours in the structured array contour_data
load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
    config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f)),'contour_data')

% make articulator contours denser by a factor of six
ds = 1/6;

% initialize tv containers
la=zeros(size(contour_data.X,1),1); ulx=la; uly=la; llx=la; lly=la;
vp=la; velumx1=la; velumy1=la; pharynxx1=la; pharynxy1=la;
alv=la; alveolarx=la; alveolary=la; tonguex2=la; tonguey2=la;
pal=la; palatalx=la; palataly=la; tonguex3=la; tonguey3=la;
vel=la; velumx2=la; velumy2=la; tonguex1=la; tonguey1=la;
phar=la; pharynxx2=la; pharynxy2=la; tonguex4=la; tonguey4=la; 

% initialize index for tv containers
k=1;

files = unique(contour_data.files);
nFiles = length(files);

for i=1:nFiles
    % display progress
    if ~sim_switch
        disp(['Getting (original) TVs file ' num2str(i) ' of ' num2str(nFiles)])
    else
        disp(['Getting (simulated) TVs file ' num2str(i) ' of ' num2str(nFiles)])
    end
    
    % obtain frame numbers for the i-th file
    frames=contour_data.frames(contour_data.files==i);
    
    for j=1:length(frames)
        % OPTIONAL: keep hard palate at its mean value by un-commenting
        %   contour_data.weights(contour_data.File == files(i),11:12)=0; 

        % segment the vocal tract into pieces
        [Xul,Yul,Xll,Yll,Xtongue,Ytongue,Xalveolar,...
            Yalveolar,Xpalatal,Ypalatal,Xvelum,Yvelum,...
            Xvelar,Yvelar,Xphar,Yphar,Xepig,Yepig] = vt_seg(contour_data,...
            i,frames(j),ds,sim_switch,phar_idx);
        
        % obtain task variables
        %   (1) LA - lip aperture
        %   (2) ALV - alveolar constriction degree
        %   (3) PAL - palatal constriction degree
        %   (4) VEL - velar constriction degree
        %   (5) PHAR - pharyngeal constriction degree
        %   (6) VP - velopharyngeal port
        [la(k),ul_x(k),ul_y(k),ll_x(k),ll_y(k)] = compute_constriction_degree(Xul,Yul,Xll,Yll);
        [alv(k),alv_x(k),alv_y(k),tng1_x(k),tng1_y(k)] = compute_constriction_degree(Xalveolar,Yalveolar,Xtongue,Ytongue);
        [pal(k),pal_x(k),pal_y(k),tng2_x(k),tng2_y(k)] = compute_constriction_degree(Xpalatal,Ypalatal,Xtongue,Ytongue);
        [vel(k),vel1_x(k),vel1_y(k),tng3_x(k),tng3_y(k)] = compute_constriction_degree(Xvelar,Yvelar,Xtongue,Ytongue);
        [phar(k),phar1_x(k),phar1_y(k),tng4_x(k),tng4_y(k)] = compute_constriction_degree(Xphar,Yphar,[Xtongue Xepig],[Ytongue Yepig]);
        [vp(k),vel2_x(k),vel2_y(k),phar2_x(k),phar2_y(k)] = compute_constriction_degree(Xvelum,Yvelum,Xphar,Yphar);
        
        % incrememnt index for tv containers
        k=k+1;
    end
end

% save tv containers to contour_data
if ~sim_switch
    tv_label = 'tv';
else
    tv_label = 'tvsim';
end
contour_data.(tv_label){1}.cd=la;   contour_data.(tv_label){1}.in=[ll_x; ll_y]';     contour_data.(tv_label){1}.out=[ul_x; ul_y]';
contour_data.(tv_label){2}.cd=alv;  contour_data.(tv_label){2}.in=[tng1_x; tng1_y]'; contour_data.(tv_label){2}.out=[alv_x; alv_y]';
contour_data.(tv_label){3}.cd=pal;  contour_data.(tv_label){3}.in=[tng2_x; tng2_y]'; contour_data.(tv_label){3}.out=[pal_x; pal_y]';
contour_data.(tv_label){4}.cd=vel;  contour_data.(tv_label){4}.in=[tng3_x; tng3_y]'; contour_data.(tv_label){4}.out=[vel1_x; vel1_y]';
contour_data.(tv_label){5}.cd=phar; contour_data.(tv_label){5}.in=[tng4_x; tng4_y]'; contour_data.(tv_label){5}.out=[phar1_x; phar1_y]';
contour_data.(tv_label){6}.cd=vp;   contour_data.(tv_label){6}.in=[vel2_x; vel2_y]'; contour_data.(tv_label){6}.out=[phar2_x; phar2_y]';

% update contour_data to contain TV
save(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
    config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f)),'contour_data')