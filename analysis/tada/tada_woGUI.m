function tada_woGUI(struct_tvfiles, yesHlsyn)
% generate TV.G .HL from TV.o PH.o without visible GUI

utt_name = lower(struct_tvfiles(3:end-2));
utt_save = utt_name;

load t_params
%state = get(fig, 'userdata');
state = struct('BTNDOWN', [],...
    'SELBTNDN', [],...
    'PREVPNT', [],...
    'PAL', [],...
    'HYOID', [],...
    'srate', [],...
    'A', [],...
    'ADOT', [],...
    'CPLAY', 50,...
    'AREA', [],...
    'TUBELENGTHSMOOTH', [],...
    'UPPEROUTLINE', [],...
    'BOTTOMOUTLINE', [],...
    'TV_SCORE', [],...
    'TV', [],...
    'ART', [],...
    'ASYPEL', [],...
    'ms_frm', [],...
    'last_frm', [],...
    'n_frm', [],...
    'sig', [],...
    'curfrm', [],...
    'cur_x', [],...
    'OSC_flg', [],...
    'OSC', [],...
    'ngest', [],...
    'i_TV', [],...         % which TV panel clicked (only gestural boxes)
    'str_TV', [],...
    'uttname', [],...
    'fname', [],...
    'pname', [],...
    't_scaled', [],...
    'path', [],...
    'oscSimParams', [150 100 1 .05 NaN 1],...    % Sim Time, settle Time, RelTol, MaxStep, InitialStep, refine
    'oscSimNoise', [0 0 0 2],... %nz_task, nz_comp, nz_freq, sim_type (see hybrid_osc.m) 
    'clicked_cur_x', [],...
    'h_rt_selGest', [],...
    'sel_ngests', [],...
    'sel_iTVs', [],...
    'MOVGESTBTN', 0,...
    'MODGESTBTN', 0,...
    'speechRate', 1,...
    'F', []);

%handles = guihandles(fig);


if strcmpi(struct_tvfiles(end-1:end), '.o')
    [OSC] = make_osc(utt_name, state, []);
    [TV_SCORE, ART, ms_frm, last_frm, sylBegEnd] = make_osc2gest(utt_name, OSC);
    
    % save gestural scores from .o in .g
    if strcmpi(struct_tvfiles(end-1:end), '.o')
        t_saveAs (utt_save, TV_SCORE, ms_frm)
    end
    
    yesTVg = 1; % in case you want to mview output form TV.g, but not TV.o
                % this is useful due to mismatch bewteen TV.g and TV.o outputs
    if yesTVg    
        [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name);
        [TV_SCORE] = make_prom(TV_SCORE, ms_frm, last_frm); % compute PROM and make fake PRO
    end
    
elseif strcmpi(struct_tvfiles(end-1:end), '.g')
    [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name);
    [TV_SCORE] = make_prom(TV_SCORE, ms_frm, last_frm); % compute PROM and make fake PRO
end



[TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm);


tadaPath = which('tada');
tadaPath = tadaPath(1:end-6);
addpath([tadaPath 'casy'], 0) ;  % 0 means the path will be in the front of search path

% added by HN 0910 to take the initial phonation info (new) from tv.g
ifkill = 0;
if ~isempty(TV_SCORE(1).phon_onset)
    ifkill(1) = TV_SCORE(1).phon_onset*10;
end

if ~isempty(TV_SCORE(1).phon_offset)
    ifkill(2) = TV_SCORE(1).phon_offset*10;
end

[sig srate A ADOT TV TVDOT TV_SCORE ART ms_frm last_frm AREA TUBELENGTHSMOOTH UPPEROUTLINE BOTTOMOUTLINE F] = ...
    t_casy(utt_name, TV_SCORE, ART, ms_frm, last_frm, ifkill, []);


% added by Tanner Sorensen, Sept. 5, 2018
save([utt_save '_uo'], 'UPPEROUTLINE');
save([utt_save '_bo'], 'BOTTOMOUTLINE');

% synthesis through HLsyn, added by HN 200901
if yesHlsyn
    fnHL = [utt_name '.HL'];
    params = ParseHL(fnHL);    
    
    otherF0 = 0;
    if otherF0
        for i = 1:length(params)
            params(i).F0 = 1250; % M: 1250 (default), F: 2200
        end
    end
    isF = 0;
    srate = 20000; % new HLsyn srate for Vikram
    sig = HLsyn(params, srate, isF)';
end
sig = double(sig);
sig = sig/max(abs(sig));

% create ASYPEL variables
ASYPEL(1).SIGNAL(1,:) = utx + A(i_LX,:)*mm_per_dec; % Upper Lip X
ASYPEL(1).SIGNAL(2,:) = uty + A(i_UY,:)*mm_per_dec; % Upper Lip Y

ASYPEL(5).SIGNAL(1,:) = xf + A(i_CL,:)*mm_per_dec.*cos(A(i_CA,:)+A(i_JA,:) - pi/2); % Tongue body center X e1
ASYPEL(5).SIGNAL(2,:) = yf + A(i_CL,:)*mm_per_dec.*sin(A(i_CA,:)+A(i_JA,:) - pi/2); % Tongue body certer Y e2

ASYPEL(3).SIGNAL(1,:) = xf+rj*cos(A(i_JA,:) - pi/2); % Jaw X e3
ASYPEL(3).SIGNAL(2,:) = yf+rj*sin(A(i_JA,:) - pi/2); % Jaw Y e4

ASYPEL(2).SIGNAL(1,:) = ASYPEL(3).SIGNAL(1,:)+A(i_LX,:)*mm_per_dec; % Lower Lip X e5
ASYPEL(2).SIGNAL(2,:) = ASYPEL(3).SIGNAL(2,:)+A(i_LY,:)*mm_per_dec; % Lower Lip Y e6

ASYPEL(4).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)+rc*cos(A(i_JA,:) - pi/2+.55*pi)+A(i_TL,:)*mm_per_dec.*cos(A(i_JA,:) - pi/2+A(i_TA,:)+(.004*(A(i_CL,:)*mm_per_dec-950 / mermels_per_mm)) * mermels_per_mm); % Tongue Tip X e7
ASYPEL(4).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(A(i_JA,:) - pi/2+.55*pi)+A(i_TL,:)*mm_per_dec.*sin(A(i_JA,:) - pi/2+A(i_TA,:)+(.004*(A(i_CL,:)*mm_per_dec-950 / mermels_per_mm)) * mermels_per_mm); % Tongue Tip Y e8

ASYPEL(8).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:); % Tongue Front X
ASYPEL(8).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc; % Tongue Front Y

ASYPEL(6).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc*sin(pi/4); % Tongue Dorsal X
ASYPEL(6).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:)+rc*sin(pi/4); % Tongue Dorsal Y

ASYPEL(7).SIGNAL(1,:) = ASYPEL(5).SIGNAL(1,:)-rc; % Tongue Rear X
ASYPEL(7).SIGNAL(2,:) = ASYPEL(5).SIGNAL(2,:); % Tongue Rear Y


% manually allocate computed variabes into 'state'.
state.ASYPEL = ASYPEL;
if strcmpi(struct_tvfiles(end-1:end), '.o')
    state.OSC = OSC;
end

state.TV_SCORE = TV_SCORE;
state.ART = ART;
state.TV = TV;
state.ms_frm = ms_frm;
state.last_frm = last_frm;
state.sig = sig;
state.srate = srate;
state.A = A;
state.ADOT = ADOT;
state.F = F;
    
warning off, audiowrite([utt_name '.wav'], sig, srate ); warning on
rmpath([tadaPath 'casy']) ;  % remove this path in order to avoid the functions


t_saveMview (utt_save, state)

% save "state" variable
sav_str = ['save ' utt_save ' '  'state -v6;'];
eval(sav_str)

if exist('make_GPV')
    GPV = make_GPV(['TV' utt_save '.G'], TV);
    eval([lower(utt_save) '_g = GPV;'])
    eval(['save ' lower(utt_save) '_g ' lower(utt_save) '_g'])
end