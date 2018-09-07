% SYNTHESIZE_DATA This script generates synthesized participant data
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% University of Southern California
% 09/07/2018

% add TaDA to path
addpath(fullfile(pwd,'..','tada'))

% read file gest/english/gparams.txt
% (contains gestural parameters for English)
gparams_filename = fullfile(pwd,'..','tada','gest','english','gparams.txt');
gparams_table = readtable(gparams_filename,'Delimiter','tab');
gparams_cell = table2cell(gparams_table);

% get row and column indices for the jaw articulator weights in all LA and
% CD gestures that use the jaw
tv_names = table2cell(gparams_table(:,1));
ja_row = cellfun(@(x) contains(x,'CD') || contains(x,'LA'), tv_names);
ja_col = 6;

% character array containing the consonants for all [a]-consonant-[a]
% utterances to be synthesized
consonants = 'ptky';
file = cellfun(@(x) strrep('aCa','C',x), num2cell(consonants), 'UniformOutput', false);

% jaw weights vary from very small (1e-4, jaw is "light" and moves a lot)
% to very large (1e4, jaw is "heavy" and moves little)
weight_param = [1e-4 1e-2 1e0 1e2 1e4];
weight_param_str = cellfun(@(x) num2str(x), num2cell(0:length(weight_param)-1), 'UniformOutput', false);

% hard-coded indices of tongue, jaw, lower lip, upper lip, hard palate,
% velum, and pharynx contours
tongue_idx = 4:55;
jaw_idx = [56 57];
lowerlip_idx = 58:59;
upperlip_idx = 55:57;
hardpalate_idx = 36:54;
velum_idx = 5:35;
pharynx_idx = [3 4];
n_contour_vertices = length([tongue_idx,jaw_idx,lowerlip_idx,...
    upperlip_idx,hardpalate_idx,velum_idx,pharynx_idx]);

for idx = 1:length(weight_param)
    
    % -------------------------------
    % ------- VARY JAW WEIGHT -------
    % -------------------------------
    
    % set jaw articulator weights to weight_param(idx), leaving the same 
    % all other gestural parameters of "English"
    language_name = ['english' weight_param_str{idx}];
    system(['cp -r ../tada/gest/english/ ../tada/gest/' language_name]);
    gparams_cell(ja_row,ja_col) = {num2str(weight_param(idx))};
    
    % write new gestural specifications with different jaw weights
    output_filename = strrep(gparams_filename,'english',language_name);
    writetable(cell2table(gparams_cell), output_filename, 'Delimiter', 'tab');
    
    % delete first line of file 
    % (contains undesired header not present in the original)
    system(['mv ' output_filename ' ' strrep(output_filename,'.txt','_bak.txt')]);
    fid=fopen(strrep(output_filename,'.txt','_bak.txt'),'rt');
    fid2=fopen(output_filename,'wt');
    id=0;
    a=fgets(fid);
    while(ischar(a))
        id=id+1;
        if id==1
            a=fgets(fid);
            continue
        else
            fprintf(fid2,a);
        end
        a=fgets(fid);
    end
    system(['rm ' strrep(output_filename,'.txt','_bak.txt')]);
    
    % ------------------------------
    % ----- SYNTHESIZE DATASET -----
    % ------------------------------
    
    % initialize containers for contour x- and y-coordinates, frame number
    % (i.e., time point), and file number (index for file 
    X = zeros(n_contour_vertices,0);
    Y = zeros(n_contour_vertices,0);
    frames = zeros(1,0);
    files = zeros(1,0);
    
    % for each consonant in [a]-consonant-[a] utterance...
    for c_idx = 1:length(consonants)
        % create oscillator (.O) files from ARPABET text input
        gest(['a' consonants(c_idx) 'a' weight_param_str{idx}],['(AA)(' upper(consonants(c_idx)) 'AA)'],language_name)
        
        % create gestural score (.G) file from oscillator files
        tada_woGUI(['TVa' consonants(c_idx) 'a' weight_param_str{idx} '.O'], false)
        
        % load the bottom (bo, bottom outline) and upper (uo, upper outline) contours
        bo = load(['a' consonants(c_idx) 'a' weight_param_str{idx} '_bo']);
        uo = load(['a' consonants(c_idx) 'a' weight_param_str{idx} '_uo']);
        n_frames = size(bo.BOTTOMOUTLINE,3);
        
        % for each frame (i.e., time point) in the synthesized utterance
        for frame_idx=1:n_frames
            % get x- and y-coordinates for each contour vertex
            tongue_x = bo.BOTTOMOUTLINE(tongue_idx,1,frame_idx);
            tongue_y = bo.BOTTOMOUTLINE(tongue_idx,2,frame_idx);
            jaw_x = bo.BOTTOMOUTLINE(jaw_idx,1,frame_idx);
            jaw_y = bo.BOTTOMOUTLINE(jaw_idx,2,frame_idx);
            lowerlip_x = bo.BOTTOMOUTLINE(lowerlip_idx,1,frame_idx);
            lowerlip_y = bo.BOTTOMOUTLINE(lowerlip_idx,2,frame_idx);
            upperlip_x = uo.UPPEROUTLINE(upperlip_idx,1,frame_idx);
            upperlip_y = uo.UPPEROUTLINE(upperlip_idx,2,frame_idx);
            hardpalate_x = uo.UPPEROUTLINE(hardpalate_idx,1,frame_idx);
            hardpalate_y = uo.UPPEROUTLINE(hardpalate_idx,2,frame_idx);
            velum_x = uo.UPPEROUTLINE(velum_idx,1,frame_idx);
            velum_y = uo.UPPEROUTLINE(velum_idx,2,frame_idx);
            pharynx_x = uo.UPPEROUTLINE(pharynx_idx,1,frame_idx);
            pharynx_y = uo.UPPEROUTLINE(pharynx_idx,2,frame_idx);
            
            % add the x- and y-coordinates of the contour vertices, the
            % frame number, and the file number to container
            X = cat(2,X,[tongue_x; jaw_x; lowerlip_x; ...
                upperlip_x; hardpalate_x; velum_x; pharynx_x]);
            Y = cat(2,Y,[tongue_y; jaw_y; lowerlip_y; ...
                upperlip_y; hardpalate_y; velum_y; pharynx_y]);
            frames = cat(2,frames,frame_idx);
            files = cat(2,files,c_idx);
        end
    end
    
    % save containers to hard disk
    contour_data.X = X';
    contour_data.Y = Y';
    contour_data.files = files';
    contour_data.file_list = cellfun(@(x) strrep('aCa','C',x), num2cell(consonants), 'UniformOutput', false);

    n_tongue_pts = length(tongue_x);
    n_jaw_pts = length(jaw_x);
    n_lowerlip_pts = length(lowerlip_x);
    n_upperlip_pts = length(upperlip_x);
    n_hardpalate_pts = length(hardpalate_x);
    n_velum_pts = length(velum_x);
    n_pharynx_pts = length(pharynx_x);

    contour_data.sections_id = [2*ones(1,n_tongue_pts), ...
        3*ones(1,n_jaw_pts), ...
        4*ones(1,n_lowerlip_pts), ...
        15*ones(1,n_upperlip_pts), ...
        11*ones(1,n_hardpalate_pts), ...
        12*ones(1,n_velum_pts), ...
        7*ones(1,n_pharynx_pts)];

    contour_data.frames = frames';
    contour_data.video_frames = frames';

    save(['synth_participant_' num2str(idx)],'contour_data');
end

