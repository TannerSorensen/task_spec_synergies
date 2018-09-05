function get_Ugfa(config_struct,varargin)
% GET_UGFA - extract factors of vocal tract shape the contours in the file
% contour_data.mat
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
%  - verbose: (logical) if true, plot graphics; otherwise, do not plot.
%
% OPTIONAL INPUTS:
%  Variable name: variant_switch
%  Size: 1xN, N undetermined
%  Class: char
%  Default value: 'toutios2015factor'
%  Description: either 'toutios2015factor' or 'sorensen2018', which
%    indicates which variant of the factor analysis to use.
% 
%  Variable name: q
%  Size: 1x1
%  Class: struct
%  Default value: struct('jaw',1,'tng',4,'lip',2,'vel',1,'lar',2)
%  Description: struct array that indicates the number of factors for the
%    jaw, tongue, lips, velum, and larynx.
% 
%  Variable name: sim_switch
%  Size: 1x1
%  Class: logical
%  Default value: false
%  Description: logical flag that indicates whether to compute constriction
%    degrees using original (x,y)-coordinates of articulator contours
%    (false) or using the (x,y)-coordinates of articulator contours that
%    have been projected onto the column space of the factors (true).
% 
% FUNCTION OUTPUT:
%  none
% 
% SAVED OUTPUT: 
%  Path: config_struct.out_path
%  File name: given by the string value of 
%    sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)
%  Variable name: contour_data
%  Size: 1x1
%  Class: struct
%  Description: Contains the contour data, along with the constriction
%    degrees computed by this function. Other fields are possible, but the
%    fields added are listed below. 
%    - U_gfa: double array of size 400xQ, where Q is the number of factors,
%      as determined by optional input q, which has the factors in the
%      columns.
%    - var_expl: double with percent variance explained (0-1). 
%    - weights: double array of size NxQ, where N is the number of
%      real-time magnetic resonance images and Q is the number of factors,
%      as determined by the optional input q. The entries are the factor
%      scores for each factor in each image. 
%    - mean_vt_shape: double array with the mean value of each contour
%      vertex
%    - Xsim: double array of size NxP, where N is the number of images and 
%      P is the number of contour vertices, with the x-coordinates of the 
%      contour vertices projected onto the column space of the factors. 
%    - Ysim: double array of size NxP, where N is the number of images and 
%      P is the number of contour vertices, with the y-coordinates of the 
%      contour vertices projected onto the column space of the factors. 
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

if nargin<2
    variant_switch = 'toutios2015factor';
    sim_switch = false;
elseif nargin==2
    variant_switch = varargin{1};
    sim_switch = false;
elseif nargin==3
    variant_switch = varargin{1};
    sim_switch = varargin{2};
else
    variant_switch = 'toutios2015factor';
    sim_switch = false;
    warning(['Function get_Ugfa.m was called with %d input arguments,' ...
        ' but requires 1 (optionally 2 or 3)'],nargin)
end

disp('Performing guided factor analysis')

load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f)),'contour_data')

d = size(contour_data.X,2);
    
U_gfa=zeros(2*d,10);

U_jaw = get_Ujaw(contour_data,variant_switch);
idx = 1:config_struct.q.jaw;
U_gfa(:,idx)=U_jaw(:,1:config_struct.q.jaw);

U_tng = get_Utng(contour_data,U_jaw(:,1:config_struct.q.jaw),variant_switch);
idx = (config_struct.q.jaw+1):(config_struct.q.jaw+config_struct.q.tng);
U_gfa(:,idx)=U_tng(:,1:config_struct.q.tng);

U_lip = get_Ulip(contour_data,U_jaw(:,1:config_struct.q.jaw),variant_switch);
idx = (config_struct.q.jaw+config_struct.q.tng+1):(config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip);
U_gfa(:,idx)=U_lip(:,1:config_struct.q.lip);

U_vel = get_Uvel(contour_data,U_jaw(:,1:config_struct.q.jaw),variant_switch);
idx = (config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+1):(config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+config_struct.q.vel);
U_gfa(:,idx)=U_vel(:,1:config_struct.q.vel);

U_lar = get_Ular(contour_data,U_jaw(:,1:config_struct.q.jaw),variant_switch);
idx = (config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+config_struct.q.vel+1):(config_struct.q.jaw+config_struct.q.tng+config_struct.q.lip+config_struct.q.vel+config_struct.q.lar);
U_gfa(:,idx)=U_lar(:,1:config_struct.q.lar);

D = [contour_data.X,contour_data.Y];
mean_data=ones(size(D,1),1)*mean(D);
Dnorm=D-mean_data;
if strcmp(variant_switch,'toutios2015factor')
    weights = Dnorm*U_gfa;
else
    weights = Dnorm*pinv(U_gfa');
end
mean_vt_shape = mean(D);
contour_data.mean_vt_shape = mean_vt_shape;
contour_data.U_gfa = U_gfa;
contour_data.weights = weights;

if config_struct.verbose
    figure; plot_components(config_struct, contour_data, variant_switch, q);
end

if sim_switch == true
    n = size(weights,1);
    xy_data = D;
    for i=1:n
        xy_data(i,:) = weights_to_vtshape(weights(i,:), mean_vt_shape,  U_gfa, variant_switch);
    end
    Xsim = xy_data(:,1:d);
    Ysim = xy_data(:,(d+1):end);
    
    contour_data.Xsim = Xsim;
    contour_data.Ysim = Ysim;
    
    contour_data.var_expl = sum(var([contour_data.Xsim(:,idx),contour_data.Ysim(:,idx)])) ...
        / sum(var([contour_data.X(:,idx),contour_data.Y(:,idx)]));
end

save(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f)),'contour_data')

end