function [TV_SCORE] = make_piPROM (TV_SCORE, TV_SCORE_OLD, n_frm, t_scaled)
% parameters initialization
load t_params
wag_frm = 5;
n_frm_old = length(TV_SCORE_OLD(1).GEST(1).PROM);

% allocate make_piPROM
for i = 1:nTV
    for j = 1:length(TV_SCORE(i).GEST)
        [TV_SCORE(i).GEST(j).PROM, n_frm] = scaled_vector(t_scaled, TV_SCORE_OLD(i).GEST(j).PROM, n_frm_old);
        
        TV_SCORE(i).GEST(j).BEG = floor(min(find(TV_SCORE(i).GEST(j).PROM >0))/2);
        TV_SCORE(i).GEST(j).END = floor(max(find(TV_SCORE(i).GEST(j).PROM >0))/2);
    end
end






