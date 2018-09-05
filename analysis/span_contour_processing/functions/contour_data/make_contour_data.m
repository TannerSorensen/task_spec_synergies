function make_contour_data(config_struct)
% MAKE_CONTOUR_DATA - intitialize the struct contour_data containing the 
% contour vertices contained in all the track files in the directory 
% config_struct.track_path. The struct contour_data is saved to file 
% contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat in configStruct.out_path.
% This function must be called to initialize contour_data before taking 
% further steps, such as the guided factor analysis or constriction degree 
% estimation. 
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
% FUNCTION OUTPUT:
%  none
%
% SAVED OUTPUT:
%  Path: config_struct.path_out
%  File name: value of sprintf('contour_data_jaw%d_tng%d_lip%d_vel%d_lar%d.mat',q.jaw,q.tng,q.lip,q.vel,q.lar)
%  Variable name: contour_data
%  Size: 1x1
%  Class: struct
%  Description: Struct with fields for each subject (field name is subject
%    ID, e.g., 'at1_rep'). The fields are structs with the following
%    fields.
%  Fields:
%  - X: X-coordinates of tissue-air boundaries in columns and time-samples
%      in rows
%  - Y: Y-coordinates of tissue-air boundaries in columns and time-samples
%      in rows
%  - files: file ID for each time-sample, note that this indexes the cell
%      array of string file names in fl
%  - file_list: cell array of string file names indexed by the entries of File
%  - sections_id: array of numeric IDs for X- and Y-coordinates in the
%      columns of the variables in fields X, Y; the correspondences are as
%      follows: 01 Epiglottis; 02 Tongue; 03 Incisor; 04 Lower Lip; 05 Jaw;
%      06 Trachea; 07 Pharynx; 08 Upper Bound; 09 Left Bound; 10 Low Bound;
%      11 Palate; 12 Velum; 13 Nasal Cavity; 14 Nose; 15 Upper Lip
%  - frames: frame number; 1 is first segmented video frame
%  - video_frames: frame number; 1 is first frame of avi video file
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 03/16/2018

fprintf('Making contour_data\n')
file_format = '*.mat';  % file name pattern

file_list = dir(fullfile(config_struct.track_path,file_format));
file_list = {file_list.name};
n_file = length(file_list);

ell=1;
fprintf('[')
twentieths = round(linspace(1,n_file,20));
for i=1:n_file
    if ismember(i,twentieths)
        fprintf('=')
    end
    
    file = load(fullfile(config_struct.track_path,file_list{i}));
    n_frame = length(file.trackdata);
    
    for j=1:n_frame
        
        try
            
            segment = file.trackdata{j}.contours.segment;

            segment_start = 0;
            sections_id = [];
            y = [];
            for k=1:(size(segment,2)-1)
                sections_id   = cat(1,sections_id,segment_start+segment{k}.i);
                segment_start = segment_start+max(segment{k}.i);
                v            = segment{k}.v;
                y            = cat(1,y,[v(:,1),v(:,2)]);
            end

            if i==1 && j==1
                len_init = 100000;
                frames = zeros(len_init,1);
                video_frames = zeros(len_init,1);
                files = zeros(len_init,1);
                X=NaN(len_init,size(y,1));
                Y=NaN(len_init,size(y,1));
            else
                X(ell,:) = y(:,1)';
                Y(ell,:) = y(:,2)';
                frames(ell) = j;
                video_frames(ell) = file.trackdata{j}.frameNo;
                files(ell) = i;
            end
            
        catch
            warning('lost frame');
        end
        
        ell=ell+1;
    end
end
fprintf(']\n')

ii=isnan(X(:,1));
X(ii,:)=[];
Y(ii,:)=[];
files(ii)=[];
frames(ii)=[];
video_frames(ii)=[];
X(:,sections_id==11) = repmat(mean(X(:,sections_id==11),1),length(files),1);
Y(:,sections_id==11) = repmat(mean(Y(:,sections_id==11),1),length(files),1);

contour_data = struct('X',X,'Y',Y,'files',files,'file_list',{file_list},...
    'sections_id',sections_id','frames',frames,'video_frames',video_frames);

save(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2_f%d.mat',...
    config_struct.q.jaw,config_struct.q.tng,config_struct.q.lip,100*config_struct.f)),'contour_data')

end