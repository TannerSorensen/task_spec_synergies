function t_saveAs(utt_save, TV_SCORE, ms_frm)
% write TV .G

load t_params
phon_onset = num2str(TV_SCORE(1).phon_onset);
fid_w = fopen(strcat('TV', utt_save, '.G'), 'w');
fprintf(fid_w, '%s\n', [num2str(ms_frm) ' ' '0 ' phon_onset]); %num2str(last_frm)]);

for i = 1:size(TV_SCORE, 2)
    for j = 1:size(TV_SCORE(i).GEST, 2)
        w_line = [];
        switch i
            case {i_TBCL, i_TTCL, i_TTCR}
                rescale = deg_per_rad;
            case { i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
                rescale = mm_per_dec;
            case {i_VEL, i_GLO, i_F0 i_PI i_SPI i_TR}
                rescale = 1;
        end
        if ~(TV_SCORE(i).GEST(j).BEG==0&TV_SCORE(i).GEST(j).END==0)
            tv_line = ['''' get_TVname(i) '''' ' '...
                        '0' ' '...
                        num2str(TV_SCORE(i).GEST(j).BEG) ' '...
                        num2str(TV_SCORE(i).GEST(j).END) ' '...
                        '0' ' '...
                        num2str(TV_SCORE(i).GEST(j).x.VALUE*rescale) ' '...
                        num2str(sqrt(TV_SCORE(i).GEST(j).k.VALUE)/(2*pi)) ' '...
                        num2str(TV_SCORE(i).GEST(j).d.VALUE/(2*sqrt(TV_SCORE(i).GEST(j).k.VALUE))) ' '];

            w_idx = find(TV_SCORE(i).GEST(j).w.VALUE >0);
            for k = w_idx
                ARTICname = get_ARTICname(k);
                tmp = [ARTICname '=' num2str(TV_SCORE(i).GEST(j).w.VALUE(k))];
                if k ~= w_idx(end)
                    tmp = [tmp ','];
                else
                    tmp = [tmp ' '];
                end
                w_line = [w_line tmp];
            end
            blend_line = [num2str(TV_SCORE(i).GEST(j).w.ALPHA) ' ' num2str(TV_SCORE(i).GEST(j).w.BETA)];
            fprintf(fid_w, '%s\n', [tv_line w_line blend_line]);
        end
    end
end

fclose(fid_w);
