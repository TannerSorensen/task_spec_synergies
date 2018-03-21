function bm_tab = get_biomarker_table(config_struct,subject_list)
%GET_BIOMARKER_TABLE - returns a table of biomarkers for statistical
%analysis or export

% set regex expression into which the string subject identifiers will be
% substituted in to obtain paths to segmentation results
% (master_track_path), outputs of the analysis (master_out_path), and 
% manual annotations for the analysis (master_manual_annotations_path)
master_out_path = config_struct.out_path;

% set the parameters of the factor analysis
jaw_fac = [1 2 3];
n_jaw_fac = length(jaw_fac);
tng_fac = [4 6 8];
n_tng_fac = length(tng_fac);
lip_fac = 3;
n_lip_fac = length(lip_fac);

% initialize output table
bm_tab = table;

for i=1:length(subject_list)
    fprintf('Participant %d of %d\n',i,length(subject_list))
    
    % substitute participant name into path
    config_struct.out_path = strrep(master_out_path,'%s',subject_list{i});
    
    % load contour_data and concetenate the biomarkers onto the table, for
    % each factor analysis specification
    for j=1:n_jaw_fac
        for k=1:n_tng_fac
            q = struct('jaw',jaw_fac(j),'tng',tng_fac(k),'lip',2,'vel',1,'lar',2);
            load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2',q.jaw,q.tng,q.lip)),'contour_data');
            tmp_bm_tab = contour_data.strategies.biomarker;
            tmp_bm_tab.participant = i*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_jaw = q.jaw*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_tng = q.tng*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_lip = q.lip*ones(size(tmp_bm_tab,1),1);
            bm_tab = cat(1,bm_tab,tmp_bm_tab);
        end
        for k=1:n_lip_fac
            q = struct('jaw',jaw_fac(j),'tng',4,'lip',lip_fac(k),'vel',1,'lar',2);
            load(fullfile(config_struct.out_path,sprintf('contour_data_jaw%d_tng%d_lip%d_vel1_lar2',q.jaw,q.tng,q.lip)),'contour_data');
            tmp_bm_tab = contour_data.strategies.biomarker;
            tmp_bm_tab.participant = i*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_jaw = q.jaw*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_tng = q.tng*ones(size(tmp_bm_tab,1),1);
            tmp_bm_tab.n_lip = q.lip*ones(size(tmp_bm_tab,1),1);
            bm_tab = cat(1,bm_tab,tmp_bm_tab);
        end
    end
    
    % reset path
    config_struct.out_path = strrep(master_out_path,subject_list{i},'%s');
end

end

