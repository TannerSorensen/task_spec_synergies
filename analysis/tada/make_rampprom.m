function [TV_SCORE] = make_rampprom(TV_SCORE, ms_frm, last_frm)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%
% parameters initialization
load t_params
wag_frm = 5;
n_frm = (last_frm)*ms_frm/wag_frm;

global n_rampfrm
global ramp_style

for i = 1:size(TV_SCORE,2)
    for j = 1:size(TV_SCORE(i).GEST,2)
        if ~(TV_SCORE(i).GEST(j).BEG == 0 & TV_SCORE(i).GEST(j).END ==0) % to avoid a problem caused by unspecifed PRO's time span before making fake PRO
            BEG_frm = TV_SCORE(i).GEST(j).BEG * ms_frm/wag_frm+1;
            END_frm = TV_SCORE(i).GEST(j).END * ms_frm/wag_frm;
            TV_SCORE(i).GEST(j).PROM = zeros(1, n_frm);

            % No Ramp activation
            if i == i_PI | i == i_SPI
                TV_SCORE(i).GEST(j).PROM (BEG_frm : END_frm) = ones(1, END_frm - BEG_frm +1)*TV_SCORE(i).GEST(j).x.VALUE;
            else
                TV_SCORE(i).GEST(j).PROM (BEG_frm : END_frm) = ones(1, END_frm - BEG_frm +1);
            end
            % Ramp activation
            % n_rampfrm = 6; % ramp frame (shoule be even ... e.g.  if ramp shape is like 0 .25 .5 .75. 1,  n_rampfrm =4;)
            % ramp_style = 1; % cosine type ramp: 1, linear type: 0

% delete it            
% if i == i_TBCD & j ==1
%    n_rampfrm = 4;
% end
            ramp_rise_frm = 0:1/n_rampfrm:1;
            if ramp_style == 1;
                theta_rise_frm  = ramp_rise_frm*pi;
                ramp_rise_act = -1/2*cos(theta_rise_frm) +1/2;
            else
                ramp_rise_act = ramp_rise_frm;
            end
% delete it 
% if i == i_TBCD & j ==1
%    n_rampfrm = 16;
% end
            ramp_fall_frm = 1:1/n_rampfrm:2;
            if ramp_style == 1;
                theta_fall_frm  = ramp_fall_frm*pi;
                ramp_fall_act = -1/2*cos(theta_fall_frm) +1/2;
            else
                ramp_fall_act = 2-ramp_fall_frm;
            end

% delete it
% n_rampfrm = 8;


            ramp_rise_act_crt = ramp_rise_act(2:end-1);
            len_rise = length(ramp_rise_act_crt);
            cnt_rise = (len_rise+1)/2;
            mrg_rise = (len_rise-1)/2;

            ramp_fall_act_crt = ramp_fall_act(2:end-1);
            len_fall = length(ramp_fall_act_crt);
            cnt_fall = (len_fall+1)/2;
            mrg_fall = (len_fall-1)/2;

            % No Ramp activation
            if i == i_PI | i == i_SPI
                scl = TV_SCORE(i).GEST(j).x.VALUE;
            else
                scl = 1;
            end
            if BEG_frm-mrg_rise >0
                TV_SCORE(i).GEST(j).PROM (BEG_frm-mrg_rise:BEG_frm+mrg_rise)  = ramp_rise_act_crt(1:end)*scl;
            else
                TV_SCORE(i).GEST(j).PROM (1:BEG_frm+mrg_rise)  = ramp_rise_act_crt(cnt_rise- BEG_frm+1:end)*scl;
            end

            if END_frm+mrg_fall <n_frm
                TV_SCORE(i).GEST(j).PROM (END_frm-mrg_fall:END_frm+mrg_fall)  = ramp_fall_act_crt(1:end)*scl;
            else
                TV_SCORE(i).GEST(j).PROM (END_frm-mrg_fall:end)  = ramp_fall_act_crt(1:n_frm+cnt_fall- END_frm)*scl;
            end
        end
    end
end




% %%% make fake LP (lip protrusion) for unspecified LP %%%
% 
% % find LA gestures that need fake LP
% fake_i = []; % LA gestures that need fake LP
% sz_PRO_gest = length(TV_SCORE(i_PRO).GEST);
% sz_LA_gest = length(TV_SCORE(i_LA).GEST);
% for i = 1:sz_LA_gest
%     b = 0;
%     for j = 1:sz_PRO_gest
%         if TV_SCORE(i_LA).GEST(i).BEG == TV_SCORE(i_PRO).GEST(j).BEG && ...
%                 TV_SCORE(i_LA).GEST(i).END == TV_SCORE(i_PRO).GEST(j).END
%             b = 1;
%         end
%     end
%     if b ~= 1
%         fake_i = [fake_i i];
%     end
% end
% 
% 
% % make fake LP (lip protrusion) for unspecified LP
% if ~isempty(fake_i)
%     j = 1;
%     for i = fake_i
%         % alloc_tv for fake LP
%         if sz_PRO_gest == 1 && ...
%                 TV_SCORE(i_PRO).GEST(sz_PRO_gest).BEG == 0 && ...
%                 TV_SCORE(i_PRO).GEST(sz_PRO_gest).END == 0 % if first initialized structure of PRO gesture is not filled yet
%             j = 0;
%         else
%             TV_SCORE(i_PRO).GEST(sz_PRO_gest+j) = struct(...
%                 'BEG', [0],...
%                 'END', [0],...
%                 'PROM', zeros(1,n_frm),...
%                 'x', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%                 'k', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%                 'd', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%                 'w', struct('VALUE', zeros(1,nARTIC), 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
%                 'PROM_BLEND_SYN', zeros(1,n_frm),...
%                 'PROMSUM_BLEND_SYN', zeros(1,n_frm));
%         end
% 
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).BEG = TV_SCORE(i_LA).GEST(i).BEG;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).END = TV_SCORE(i_LA).GEST(i).END;
% 
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).x.VALUE = 9.6/mm_per_dec;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).k.VALUE = TV_SCORE(i_LA).GEST(i).k.VALUE;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).d.VALUE = 1*2*sqrt(TV_SCORE(i_LA).GEST(i).k.VALUE);
%         LX_fake = 1;
%         w = zeros(1,nARTIC);
%         w(i_LX) = LX_fake;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).w.VALUE = w;
% 
%         % alloc_tvtv for fake LP
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).x.ALPHA = TV_SCORE(i_LA).GEST(i).x.ALPHA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).x.BETA = TV_SCORE(i_LA).GEST(i).x.BETA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).k.ALPHA = TV_SCORE(i_LA).GEST(i).k.ALPHA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).k.BETA = TV_SCORE(i_LA).GEST(i).k.BETA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).d.ALPHA = TV_SCORE(i_LA).GEST(i).d.ALPHA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).d.BETA = TV_SCORE(i_LA).GEST(i).d.BETA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).w.ALPHA = TV_SCORE(i_LA).GEST(i).w.ALPHA;
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).w.BETA = TV_SCORE(i_LA).GEST(i).w.BETA;
% 
%         % make_prom for fake LP
%         TV_SCORE(i_PRO).GEST(sz_PRO_gest+j).PROM = TV_SCORE(i_LA).GEST(i).PROM;
% 
%         j = j+1;
%     end
%     nPRO = length(TV_SCORE(i_PRO).GEST); % recompute number of PRO gestures
% end
