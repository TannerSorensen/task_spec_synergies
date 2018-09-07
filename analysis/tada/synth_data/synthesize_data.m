addpath(fullfile(pwd,'..'))

% read gparams.txt file
gparams_filename = fullfile(pwd,'..','gest','english','gparams.txt');
gparams_table = readtable(gparams_filename,'Delimiter','tab');
gparams_cell = table2cell(gparams_table);

% get row and column indices for articulator weights we want to modify
tv_names = table2cell(gparams_table(:,1));
cd_row = cellfun(@(x) contains(x,'CD') || contains(x,'LA'), tv_names);
ja_col = 6;

consonants = 'ptky';

tongue_idx = 4:55;
jaw_idx = [56 57];
lowerlip_idx = 58:59;
upperlip_idx = 55:57;
hardpalate_idx = 36:54;
velum_idx = 5:35;
pharynx_idx = [3 4];

weight_param = [1e-4 1e-2 1e0 1e2 1e4];
weight_param_str = {'0', '1', '2', '3', '4'};
for idx = 1:length(weight_param)
    
    % initialize containers
    X = zeros(111,0);
    Y = zeros(111,0);
    frames = zeros(1,0);
    files = zeros(1,0);
    
    % -------------------------------
    % ------- VARY JAW WEIGHT -------
    % -------------------------------
    
    % use the language "English" as the basis of our synthesis
    language_name = ['english' weight_param_str{idx}];
    system(['cp -r ../gest/english/ ../gest/' language_name]);
    
    % modify articulator weights
    gparams_cell(cd_row,ja_col) = {num2str(weight_param(idx))};
    
    % write new gestural specifications with different jaw weights
    output_filename = strrep(gparams_filename,'english',language_name);
    writetable(cell2table(gparams_cell), output_filename, 'Delimiter', 'tab');
    system(['mv ' output_filename ' ' strrep(output_filename,'.txt','_bak.txt')]);
    
    % delete first line of file 
    % (contains undesired header not present in the original)
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
    
    for c_idx = 1:length(consonants)
        gest(['a' consonants(c_idx) 'a' weight_param_str{idx}],['(AA)(' upper(consonants(c_idx)) 'AA)'],language_name)
        tada_woGUI(['TVa' consonants(c_idx) 'a' weight_param_str{idx} '.O'], false)
        bo = load(['a' consonants(c_idx) 'a' weight_param_str{idx} '_bo']);
        uo = load(['a' consonants(c_idx) 'a' weight_param_str{idx} '_uo']);
        
        for frame_idx=1:size(bo.BOTTOMOUTLINE,3)
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

            X = cat(2,X,[tongue_x; jaw_x; lowerlip_x; ...
                upperlip_x; hardpalate_x; velum_x; pharynx_x]);
            Y = cat(2,Y,[tongue_y; jaw_y; lowerlip_y; ...
                upperlip_y; hardpalate_y; velum_y; pharynx_y]);
            frames = cat(2,frames,frame_idx);
            files = cat(2,files,c_idx);
        end
    end
    
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

