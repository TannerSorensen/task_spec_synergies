function [signal, srate, A, ADOT, TV, TVDOT, TV_SCORE, ART, ms_frm, last_frm, AREA, TUBELENGTHSMOOTH, UPPEROUTLINE, BOTTOMOUTLINE, TRSD, F_all] = t_casy(utt_name, TV_SCORE, ART, ms_frm, last_frm, ifkill, handles)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%
% this is the old version of t_casy
% TADA_1.58_nogang_newTcasy(1.58) uses new version.

load t_params

% executing casy except plotting
%global play
%global plotGrid
init
% eall
% outline
% c_grid
%=======================

global KEY_FixLip
global KEY_VarLip
global KEY_TongueCircle
global KEY_TongueCircleRad
global KEY_Jaw
global KEY_TipCircle
global KEY_BladeOriginOffset
global KEY_RootOffset
global KEY_Hyoid
global KEY_Nasal
global area
global tubeLengthSmooth
global UpperOutline
global BottomOutline
global trsd

signal = [];
srate = 10000;
AREA = [];
TUBELENGTHSMOOTH = [];
UPPEROUTLINE = [];
BOTTOMOUTLINE = [];
F_all = [];
TRSD = [];


if nargin == 1
    [A, ADOT, TV, TVDOT, TV_SCORE, ART, ms_frm, last_frm] = task_dynamics(utt_name);
elseif nargin == 7
    [A, ADOT, TV, TVDOT, TV_SCORE, ART, ms_frm, last_frm] = task_dynamics(utt_name, TV_SCORE, ART, ms_frm, last_frm);
end

h = waitbar(0,'Please wait... computing acoustic signal');

% 	THE MEASUREMENT UNITS VARY WITH THEIR USE IN THE PROGRAM:
% 	  1. ANGULAR: DEGREES(DEG) = USED FOR I/O;
% 		      RADIANS(RAD) = USED FOR COMPUTATIONS WITHIN
% 			     PROGRAM, OUTPUT TO ASY & GRAPHICS DISPLAY
% 			     SUBROUTINES;
% 	  2. LINEAR:  MILLIMETERS(MM) = USED FOR I/O;
% 		      DECIMETERS(DM; 1DM = 100MM) = USED FOR WITHIN-
% 			     PROGRAM COMPUTATION;
% 		      MERMELS(MRML OR MR) = OUTPUT TO ASY & GRAPHICS
% 			     DISPLAY SUBROUTINES.
% 	  3. ARBITRARY: USED FOR GLOTTAL AND VELIC GESTURES IN ALL
% 			     APPLICATIONS.

TV([i_TBCL i_TTCL i_TTCR], :) = TV([i_TBCL i_TTCL i_TTCR], :) * deg_per_rad;
TV([i_PRO i_LA i_TBCD i_TTCD i_JAW], :) = TV([i_PRO i_LA i_TBCD i_TTCD i_JAW], :) * mm_per_dec;

tot_dur = ms_frm*last_frm/1000;
f0 = 100; synfrm_dur = 1/f0;

init_kill = ifkill(1);
if length(ifkill) >1
    final_kill = tot_dur*1000 - ifkill(2);
else
    final_kill = tot_dur*1000;
end

if (~isempty (handles) & strcmpi(get(handles.mn_genHL, 'check'), 'on')) | isempty (handles)
    fid_w = fopen(strcat(utt_name, '.HL'), 'w'); %%%
end

err_flg = 0;

for i = synfrm_dur/2: synfrm_dur/2: tot_dur
    cur_frm = floor(i *1000/ wag_frm);

    % KEY_FixLip = [0 0];
    % KEY_VarLip = [102/11.2  11/11.2 ];
    % KEY_TongueCircle = [0 0 856/11.2  -0.21];
    % KEY_TongueCircleRad = [0 0 230/11.2  0];
    % KEY_Jaw = [0 0 1264/11.2  -0.28];
    % KEY_TipCircle = [0 0 350/11.2  0];
    % KEY_BladeOriginOffset = [0 0 0 0];
    % KEY_RootOffset = [0 0 0 0];
    % KEY_Hyoid = [800/11.2  830/11.2 ];
    % KEY_Nasal = [0 0 0 0 ];

    KEY_FixLip = [0 A(i_UY,cur_frm)*mm_per_dec]; % make sure to unyoke upper and lower lips in eall.m of casy
    KEY_VarLip  = [A(i_LX,cur_frm)*mm_per_dec A(i_LY,cur_frm)*mm_per_dec];
    KEY_TongueCircle = [0 0 A(i_CL,cur_frm)*mm_per_dec A(i_CA,cur_frm)];
    %KEY_TongueCircleRad;
    KEY_Jaw = [0 0 CONDYLE_LT.LEN*mm_per_dec A(i_JA,cur_frm)-pi/2];
    KEY_TipCircle = [0 0 A(i_TL,cur_frm)*mm_per_dec A(i_TA,cur_frm)];
    %KEY_BladeOriginOffset;
    KEY_RootOffset(3) = A(i_HX,cur_frm);
    %KEY_Hyoid = [800+A(i_HX,cur_frm)*mm_per_dec 830+A(i_HX,cur_frm)*mm_per_dec]./mermels_per_mm;
    %KEY_Hyoid(1) = [800+A(i_HX,cur_frm)*mm_per_dec]./mermels_per_mm;
    cNas = 10; % arbitrary approximation
    KEY_Nasal = [0 0 A(i_NA,cur_frm)*cNas*(A(i_NA,cur_frm)>0) 0];

    % executing refresh(update) except plotting
    eall
    outline
    c_grid
    % plotting
    % t_drawVT

    % area			vector of areas (in cm^2)
    % tube_length	overall length of tube (in cm)

    try

        if mod(i, 10/1000) == 0 % formants computation only at synfrm_dur point, while for all, concatenation for display

            n = 5; %%%% play sound with first n formants

            F = tubeResonances(0.01*area, 0.1*tubeLengthSmooth(end) ); % mm to cm .... all from c_grid.m in CASY
            F_all = [F_all F(1:5)];

            BW = getBandwidths (F(1:n));
            [out t]= syn_buzz (srate, F(1:n), BW, f0, synfrm_dur);


%             % squashing GLO (squaring makes it minimize below 1 and exaggerate above 1)
%             scl_GLO = (TV(i_GLO, cur_frm)*10)^2*(1-2*(TV(i_GLO, cur_frm)<0));
%             if scl_GLO >= 36
%                 sqsh_GLO = 36+4;
%             elseif scl_GLO < 36 & scl_GLO >= -.01
%                 sqsh_GLO = scl_GLO+4;
%             elseif scl_GLO < -.01
%                 sqsh_GLO = 0;
%             end
            
            % squashing GLO (squaring makes it minimize below 1 and exaggerate above 1)
            % modified by HN to turn creaky voice on
            scl_GLO = (TV(i_GLO, cur_frm)*10)^2*(1-2*(TV(i_GLO, cur_frm)<0));
            if scl_GLO >= 36
                sqsh_GLO = 36+4;
            elseif scl_GLO < 36
                sqsh_GLO = scl_GLO+4;
%             elseif scl_GLO < -.01
%                 sqsh_GLO = 0;
            end
            if sqsh_GLO <= 0
                sqsh_GLO = 0;
            end
            

            %putting silence in the computed signal below threshold of area
            % threshold for area = 10 (the smaller, the hairier)
            if (isempty(find(area<10, 1)) & sqsh_GLO > 0 & i > init_kill/1000 & i <= final_kill/1000) %%% | A(i_NA, cur_frm) > 0  newly added to couple velum port
                signal = [signal out]; % output concatenation
            else
                out(1,:) = 0;
                signal = [signal out];
            end
            
            if (~isempty (handles) & strcmpi(get(handles.mn_genHL, 'check'), 'on')) | isempty (handles)

                % control ag parameter in HLsyn 
                % (no signal before init_kill and after final_kill)
                if i >= init_kill/1000 & i <= final_kill/1000
                    fprintf(fid_w, '%s\n', ['ag' ' ' num2str(i*1000) ' ' num2str(sqsh_GLO)]);
                else
                    fprintf(fid_w, '%s\n', ['ag' ' ' num2str(i*1000) ' ' '0']);
                end

                
                a = 3;
                b = .6;
                cstr_thrsh = 100;
                fprintf(fid_w, '%s\n', ['al' ' ' num2str(i*1000) ' ' num2str(...
                    (a*pi*((TV(i_LA, cur_frm)+b)/2.*(TV(i_LA, cur_frm)>0))^2).*(a*pi*((TV(i_LA, cur_frm)+b)/2.*(TV(i_LA, cur_frm)>0))^2 < cstr_thrsh)...
                    + (a*pi*((TV(i_LA, cur_frm)+b)/2.*(TV(i_LA, cur_frm)>0))^2 >= cstr_thrsh)*100    )]);
                
                if TV(i_TTCL, cur_frm) <= 35  % when tongue tip is low below upper teeth (40 degrees)
                    fprintf(fid_w, '%s\n', ['ab' ' ' num2str(i*1000) ' ' '100']);
                else
                    fprintf(fid_w, '%s\n', ['ab' ' ' num2str(i*1000) ' ' num2str(...
                        (a*pi*((TV(i_TTCD, cur_frm)+b)/2.*(TV(i_TTCD, cur_frm)>0))^2).*(a*pi*((TV(i_TTCD, cur_frm)+b)/2.*(TV(i_TTCD, cur_frm)>0))^2 < cstr_thrsh)...
                        + (a*pi*((TV(i_TTCD, cur_frm)+b)/2.*(TV(i_TTCD, cur_frm)>0))^2 >= cstr_thrsh)*100    )]);                    
                end
                
                fprintf(fid_w, '%s\n', ['an' ' ' num2str(i*1000) ' ' num2str(TV(i_VEL, cur_frm).*(TV(i_VEL, cur_frm)>0)*150)]);
                fprintf(fid_w, '%s\n', ['ue' ' ' num2str(i*1000) ' ' num2str(0)]);

                fprintf(fid_w, '%s\n', ['f0' ' ' num2str(i*1000) ' ' num2str(TV(i_F0,cur_frm)*10)]);

                fprintf(fid_w, '%s\n', ['f1' ' ' num2str(i*1000) ' ' num2str(F(1))]);
                fprintf(fid_w, '%s\n', ['f2' ' ' num2str(i*1000) ' ' num2str(F(2))]);
                fprintf(fid_w, '%s\n', ['f3' ' ' num2str(i*1000) ' ' num2str(F(3))]);
                fprintf(fid_w, '%s\n', ['f4' ' ' num2str(i*1000) ' ' num2str(F(4))]);

                % enveloping initial acoustic signal after the phonation beginning (= init_kill)
                % control ps parameter in HLsyn
                if i*1000 <= init_kill | i*1000 >= final_kill
                    fprintf(fid_w, '%s\n', ['ps' ' ' num2str(i*1000) ' ' num2str(0)]);
                else
                    frm2Kill = (i*1000-init_kill)/10; % frame distance from acoustic kill zone
                    ps = round(frm2Kill)*2;  if ps >8, ps = 8; end

                    frm2Kill = -(i*1000-final_kill)/10; % frame distance from acoustic kill zone
                    ps = round(frm2Kill)*2;  if ps >8, ps = 8; end
                    
                    
                    
                    fprintf(fid_w, '%s\n', ['ps' ' ' num2str(i*1000) ' ' num2str(ps)]);
                end



                
                fprintf(fid_w, '%s\n', ['dc' ' ' num2str(i*1000) ' ' num2str(0)]);
                fprintf(fid_w, '%s\n', ['ap' ' ' num2str(i*1000) ' ' num2str(0)]);
                fprintf(fid_w, '%s\n', '');
            end
        end
        % concatenate area functions
        if size(AREA, 2) > length(area) & ~isempty(AREA)
            area(end+1:end+(size(AREA, 2) - length(area))) = nan;
            tubeLengthSmooth(end+1:end+(size(TUBELENGTHSMOOTH, 2) - length(tubeLengthSmooth))) = nan;
        elseif size(AREA, 2) < length(area) & ~isempty(AREA)
            AREA(:,end+1:end+(length(area) - size(AREA, 2))) = nan;
            TUBELENGTHSMOOTH(:,end+1:end+(length(tubeLengthSmooth) - size(TUBELENGTHSMOOTH, 2))) = nan;
        end
        AREA = [AREA; area];
        TUBELENGTHSMOOTH = [TUBELENGTHSMOOTH; tubeLengthSmooth];
        
        if size(TRSD, 2) > length(trsd') & ~isempty(TRSD)
            trsd(end+1:end+(size(TRSD, 2)' - length(trsd'))) = nan;
        elseif size(TRSD, 2) < length(trsd') & ~isempty(TRSD)
            TRSD(:,end+1:end+(length(trsd') - size(TRSD, 2))) = nan;
        end

        
        
        TRSD = [TRSD; trsd'];
        
        % concatenate OUTLINES functions
        if size(UPPEROUTLINE, 1) > size(UpperOutline,1) & ~isempty(UPPEROUTLINE)
            UpperOutline(end+1:end+size(UPPEROUTLINE, 1) - size(UpperOutline,1),:) = nan;
        elseif size(UPPEROUTLINE, 1) < size(UpperOutline,1) & ~isempty(UPPEROUTLINE)
            UPPEROUTLINE(end+1:end+size(UpperOutline,1)-size(UPPEROUTLINE, 1),: ,:)
        end
        UPPEROUTLINE = cat(3, UPPEROUTLINE, UpperOutline);

        if size(BOTTOMOUTLINE, 1) > size(BottomOutline,1) & ~isempty(BOTTOMOUTLINE)
            BottomOutline(end+1:end+size(BOTTOMOUTLINE, 1) - size(BottomOutline,1),:) = nan;
        elseif size(BOTTOMOUTLINE, 1) < size(BottomOutline,1) & ~isempty(BOTTOMOUTLINE)
            BOTTOMOUTLINE(end+1:end+size(BottomOutline,1)-size(BOTTOMOUTLINE, 1),: ,:)
        end
        BOTTOMOUTLINE = cat(3, BOTTOMOUTLINE, BottomOutline);
    catch
        out = zeros(1,srate*synfrm_dur+1);
        err_flg = 1;
    end

    waitbar(i/tot_dur)
end

if err_flg
    errordlg('Out-of-range error in CASY')
end

if (~isempty (handles) & strcmpi(get(handles.mn_genHL, 'check'), 'on')) | isempty (handles)
    fclose(fid_w);    
end
close(h)