addpath(fullfile(pwd,'..'))

% read gparams.txt file
gparams_filename = fullfile(pwd,'..','gest','english','gparams.txt');
gparams_table = readtable(gparams_filename,'Delimiter','tab');
gparams_cell = table2cell(gparams_table);

% get row and column indices for articulator weights we want to modify
tv_names = table2cell(gparams_table(:,1));
cd_row = cellfun(@(x) contains(x,'CD') || contains(x,'LA'), tv_names);
ja_col = 6;

weight_param = [1e-4 1e-2 1e0 1e2 1e4];
weight_param_str = {'0', '1', '2', '3', '4'};
for idx = 1:length(weight_param)
    
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
    
    % [apa]
    gest(['apa' weight_param_str{idx}],'(AA)(PAA)',language_name)
    tada_woGUI(['TVapa' weight_param_str{idx} '.O'], false)
    
    % [ata]
    gest(['ata' weight_param_str{idx}],'(AA)(TAA)',language_name)
    tada_woGUI(['TVata' weight_param_str{idx} '.O'], false)
    
    % [aka]
    gest(['aka' weight_param_str{idx}],'(AA)(KAA)',language_name)
    tada_woGUI(['TVaka' weight_param_str{idx} '.O'], false)
    
    % [aya] (where y is a palatal glide)
    gest(['aya' weight_param_str{idx}],'(AA)(YAA)',language_name)
    tada_woGUI(['TVaya' weight_param_str{idx} '.O'], false)
end

