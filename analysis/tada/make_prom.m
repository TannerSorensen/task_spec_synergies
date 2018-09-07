function [TV_SCORE] = make_PROM (TV_SCORE, ms_frm, last_frm)                                            
% parameters initialization
load t_params
wag_frm = 5;
n_frm = (last_frm)*ms_frm/wag_frm;

for i = 1:size(TV_SCORE,2)
    for j = 1:size(TV_SCORE(i).GEST,2)
        if ~(TV_SCORE(i).GEST(j).BEG == 0 & TV_SCORE(i).GEST(j).END ==0) % to avoid a problem caused by unspecifed PRO's time span before making fake PRO
            BEG_frm = TV_SCORE(i).GEST(j).BEG * ms_frm/wag_frm+1;
            END_frm = TV_SCORE(i).GEST(j).END * ms_frm/wag_frm;
            
            TV_SCORE(i).GEST(j).PROM = zeros(1, n_frm);
            if i == i_PI | i == i_SPI
                TV_SCORE(i).GEST(j).PROM (BEG_frm : END_frm) = ones(1, END_frm - BEG_frm +1)*TV_SCORE(i).GEST(j).x.VALUE;
            else
                TV_SCORE(i).GEST(j).PROM (BEG_frm : END_frm) = ones(1, END_frm - BEG_frm +1);
            end
        end
    end
end
