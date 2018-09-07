function [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
% generate gestural parameters from TV(TV) file
% input: utterance name

load t_params

% initialization for tv file
name = 1;  % tract variable name

% open and read tv file
% fn = dir(['TV',utt_name,'.G*']);    % temporary filename
fn = ffind_case(['TV',utt_name,'.G']);

if isempty(fn)                   % if empty
    errordlg('TV~.G file not found','File Error');
else
    fp = fopen(fn, 'rt'); % open data file
    ln = fscanf(fp, '%s', 1); % read first data
    while ~isempty(strmatch('%', ln))
        fgetl(fp);
        ln = fscanf(fp, '%s', 1); % read first data of each line
    end

    % first line information (msec frame, last frame No.)
    ms_frm = str2num(ln); %fscanf(fp, '%f', 1); %msec frame
    last_frm = fscanf(fp, '%f', 1); %last frame No.
    LastFrm = FindLastFrmG(fn);
    if LastFrm > last_frm
        last_frm = LastFrm;
    end
    %srate = 1000/ms_frm;
    
    % added by HN 0910 to take the initial phonation info (new) from tv.g
    % if there is no info, init_kill = [];
    phon_onset = fscanf(fp, '%f', 1); 
    phon_offset = fscanf(fp, '%f', 1);
    
    n_frm = (last_frm)*ms_frm/wag_frm;
    TV_SCORE(1:nTV) = struct(...        
        'GEST', struct(...
        'BEG', [0],...
        'END', [0],...
        'PROM', zeros(1,n_frm),...
        'x', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'k', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'd', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'w', struct('VALUE', zeros(1,nARTIC), 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
        'PROM_BLEND_SYN', zeros(1,n_frm),...
        'PROMSUM_BLEND_SYN', zeros(1,n_frm)),...
        'TV', struct(...
        'PROMSUM', zeros(1,n_frm),...
        'PROM_ACT', zeros(1,n_frm),...
        'x_BLEND', zeros(1,n_frm),...
        'k_BLEND', zeros(1,n_frm),...
        'd_BLEND', zeros(1,n_frm),...
        'WGT_TV', zeros(n_frm, nARTIC)),...
        'phon_onset', [],...
        'phon_offset', []);
    
    TV_SCORE(1).phon_onset = phon_onset;
    TV_SCORE(1).phon_offset = phon_offset;
    
    ART(1:nARTIC) = struct(...
        'TOTWGT', zeros(1,n_frm),...
        'PROM_ACT_JNT', zeros(1,n_frm),...
        'PROM_NEUT', zeros(1,n_frm),...
        'PROMSUM_JNT', zeros(1,n_frm));    
    
    nLA = 0; nPRO = 0; nTTCD = 0; nTTCL = 0; nJAW = 0;...
    nTTCR = 0; nTBCD = 0; nTBCL = 0; nVEL = 0; nGLO = 0;... 
    nF0 = 0; nPI = 0; nSPI = 0; nTR = 0;
    
    % data allocation into struct
    while name % until fscanf can't read
        name = fscanf(fp, '%s', 1); % read first data of each line
        if isempty(strmatch('%', name))
            switch name(2:end-1) % kill ' '  e.g. 'LA' -> LA
                case 'LA'
                    nLA = nLA + 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_LA, nLA, ms_frm, last_frm);
                case 'LP'
                    nPRO = nPRO + 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_PRO, nPRO, ms_frm, last_frm);
                case 'TTCD'
                    nTTCD = nTTCD + 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TTCD, nTTCD, ms_frm, last_frm);
                case 'TTCL'
                    nTTCL = nTTCL+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TTCL, nTTCL, ms_frm, last_frm);
                case 'TTCR'
                    nTTCR = nTTCR+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TTCR, nTTCR, ms_frm, last_frm);
                case 'TBCD'
                    nTBCD = nTBCD+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TBCD, nTBCD, ms_frm, last_frm);
                case 'TBCL'
                    nTBCL = nTBCL+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TBCL, nTBCL, ms_frm, last_frm);
                case 'JAW'
                    nJAW = nJAW+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_JAW, nJAW, ms_frm, last_frm);
                case 'VEL'
                    nVEL = nVEL+ 1;
                    [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_VEL, nVEL, ms_frm, last_frm);
                case 'GLO'
                    nGLO = nGLO+ 1;
                    [TV_SCORE]= alloc_tv (TV_SCORE, fp, i_GLO, nGLO, ms_frm, last_frm);
                case 'F0'
                    nF0 = nF0+ 1;
                    [TV_SCORE]= alloc_tv (TV_SCORE, fp, i_F0, nF0, ms_frm, last_frm);
                case 'PI'
                    nPI = nPI+ 1;
                    [TV_SCORE]= alloc_tv (TV_SCORE, fp, i_PI, nPI, ms_frm, last_frm);
                case 'SPI'
                    nSPI = nSPI+ 1;
                    [TV_SCORE]= alloc_tv (TV_SCORE, fp, i_SPI, nSPI, ms_frm, last_frm);
                case 'TR'
                    nTR = nTR+ 1;
                    [TV_SCORE]= alloc_tv (TV_SCORE, fp, i_TR, nTR, ms_frm, last_frm);
            end
        else
            fgetl(fp);
        end
    end
    % close opened file
    fclose(fp);
end

% initialization again for tvtv file
name = 1;  % tract variable name
nLA = 0; nPRO = 0; nTTCD = 0; nTTCL = 0; nJAW = 0;...
nTTCR = 0; nTBCD = 0; nTBCL = 0; nVEL = 0; nGLO = 0;...
nF0 = 0; nPI = 0; nSPI = 0; nTR = 0;

% open and read tvtv file
fn2 = ffind_case(['TVTV',utt_name,'.G']);
if ~isempty(fn2)
    fp2 = fopen(fn2, 'rt'); % open data file
    % first line information (msec frame, last frame No.)
    ms_frm = fscanf(fp2, '%f', 1); %msec frame
    last_frm = fscanf(fp2, '%f', 1); %last frame No.

    % data allocation into struct
    while name % until fscanf can't read
        name = fscanf(fp2, '%s', 1); % read first data of each line
        switch name(2:end-1) % kill ' '  e.g. 'LA' -> LA
            case 'LA'
                nLA = nLA +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_LA, nLA);
            case 'LP'
                nPRO = nPRO +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_PRO, nPRO);
            case 'TTCD'
                nTTCD = nTTCD +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TTCD, nTTCD);
            case 'TTCL'
                nTTCL = nTTCL +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TTCL, nTTCL);
            case 'TTCR'
                nTTCR = nTTCR +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TTCR, nTTCR);
            case 'TBCD'
                nTBCD = nTBCD +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TBCD, nTBCD);
            case 'TBCL'
                nTBCL = nTBCL +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TBCL, nTBCL);
            case 'JAW'
                nJAW = nJAW +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_JAW, nJAW);
            case 'VEL'
                nVEL = nVEL +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_VEL, nVEL);
            case 'GLO'
                nGLO = nGLO +1;
                fscanf(fp2, '%f', 1); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_GLO, nGLO);
            case 'F0'
                nF0 = nF0 +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_F0, nF0);
            case 'PI'
                nPI = nPI +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_PI, nPI);
            case 'SPI'
                nSPI = nSPI +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_SPI, nSPI);
            case 'TR'
                nTR = nTR +1;
                fscanf(fp2, '%f', 5); % skip data
                TV_SCORE = alloc_tvtv (TV_SCORE, fp2, i_TR, nTR);
        end
    end
    % close opened file
    fclose(fp2);
end



function [TV_SCORE] = alloc_tv (TV_SCORE, fp, i_TV, nGEST, ms_frm, last_frm)
% parameters initialization
nARTIC = 14;

% TV index
i_LA = 2;
i_PRO = 1;
i_TBCD = 4;
i_TBCL = 3;
i_TTCD = 9;
i_TTCL = 8;
i_TTCR = 10;
i_JAW = 5;
i_VEL = 6;
i_GLO = 7;
i_F0 = 11;
i_PI = 12;
i_SPI = 13;
i_TR = 14;
nTV = 14;

wag_frm = 5;
% conversion constants
mm_per_dec = 100; % mm to decimeter
mermels_per_mm = 11.2;    % mermel to mm
deg_per_rad = 180/pi;   % radian to degree   = 57.29577

tmp = fscanf(fp, '%f', 1); % skip data

% added by HN 200910
if isempty(tmp)
    fscanf(fp, '%s', 1); % skip osc_id if any
    fscanf(fp, '%f', 1); % skip data
end

BEG = fscanf(fp, '%f', 1);
END = fscanf(fp, '%f', 1);

n_frm = (last_frm)*ms_frm/wag_frm;
TV_SCORE(i_TV).GEST(nGEST) = struct(...
    'BEG', [0],...
    'END', [0],...
    'PROM', zeros(1,n_frm),...
    'x', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
    'k', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
    'd', struct('VALUE', [0], 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
    'w', struct('VALUE', zeros(1,nARTIC), 'ALPHA', [0], 'BETA', [0], 'PROM_BLEND', zeros(1,n_frm), 'PROMSUM_BLEND', zeros(1,n_frm)),...
    'PROM_BLEND_SYN', zeros(1,n_frm),...
    'PROMSUM_BLEND_SYN', zeros(1,n_frm));

TV_SCORE(i_TV).GEST(nGEST).BEG = BEG;
TV_SCORE(i_TV).GEST(nGEST).END = END;
fscanf(fp, '%f', 1); % skip data
switch i_TV
    case { i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
        TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1)/mm_per_dec;
    case {i_TBCL, i_TTCL, i_TTCR}
        TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1)/deg_per_rad;
    case {i_VEL, i_GLO, i_F0, i_PI, i_SPI, i_TR}
        TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1);
end
frq_tmp = fscanf(fp, '%f', 1)*2*pi;    %frq_tmp = w0
TV_SCORE(i_TV).GEST(nGEST).k.VALUE = frq_tmp^2;
TV_SCORE(i_TV).GEST(nGEST).d.VALUE = fscanf(fp, '%f', 1)*2*frq_tmp;    % d = (damping radio)*2*w0
TV_SCORE(i_TV).GEST(nGEST).w.VALUE = get_w(fp, i_TV);

alpha = fscanf(fp, '%f', 1); % optionally, if there is blends in TV
if ~isempty(alpha)
    beta = fscanf(fp, '%f', 1);

else
    if i_TV == i_VEL | i_TV == i_GLO | i_TV == i_F0 | i_TV == i_PI | i_TV == i_SPI | i_TV == i_TR
        alpha = 0; beta = 0;
    elseif i_TV == i_PRO | i_TV == i_TBCL | i_TV == i_TTCL
        alpha = 1; beta = 1;
    elseif TV_SCORE(i_TV).GEST(nGEST).x.VALUE*100 < 0
        alpha = 100; beta = .01;
    elseif TV_SCORE(i_TV).GEST(nGEST).x.VALUE*100 > 0 & TV_SCORE(i_TV).GEST(nGEST).x.VALUE*100 < 1
        alpha = 10; beta = .1;
    elseif i_TV == i_TBCD
        alpha = .01; beta = 100;
    else
        alpha = 1; beta = 1;
    end
end
TV_SCORE(i_TV).GEST(nGEST).x.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).x.BETA = beta;
TV_SCORE(i_TV).GEST(nGEST).w.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).w.BETA = beta;
if alpha == 0 & beta ==0 & i_TV == i_GLO
    alpha = 1; beta = 1;
end
TV_SCORE(i_TV).GEST(nGEST).k.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).k.BETA = beta;
TV_SCORE(i_TV).GEST(nGEST).d.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).d.BETA = beta;


function TV_SCORE = alloc_tvtv (TV_SCORE, fp, i_TV, nGEST)
% parameters initialization
i_GLO = 7;


alpha = fscanf(fp, '%f', 1);
beta = fscanf(fp, '%f', 1);

al = alpha;
be = beta;
if alpha == 0 & beta == 0 & i_TV == i_GLO
    al = 1; be = 1;
end

TV_SCORE(i_TV).GEST(nGEST).x.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).x.BETA = beta;            
TV_SCORE(i_TV).GEST(nGEST).k.ALPHA = al;
TV_SCORE(i_TV).GEST(nGEST).k.BETA = be;
TV_SCORE(i_TV).GEST(nGEST).d.ALPHA = al;
TV_SCORE(i_TV).GEST(nGEST).d.BETA = be;            
TV_SCORE(i_TV).GEST(nGEST).w.ALPHA = alpha;
TV_SCORE(i_TV).GEST(nGEST).w.BETA = beta;


function w = get_w(fp, i_TV)
% parameters initialization
wag_frm = 5;
% TV index
i_LA = 2;
i_PRO = 1;
i_TBCD = 4;
i_TBCL = 3;
i_TTCD = 9;
i_TTCL = 8;
i_TTCR = 10;
i_JAW = 5;
i_VEL = 6;
i_GLO = 7;
i_F0 = 11;
i_PI = 12;
i_SPI = 13;
i_TR = 14;
nTV = 14;

% ARTIC index
i_LX = 1; %x(1)
i_JA = 2; %x(3)
i_UY = 3; %x(5)
i_LY = 4; %x(7)
i_CL = 5; %x(9)
i_CA = 6; %x(11)
i_TL = 9; %x(17)
i_TA = 10; %x(19)
i_NA = 7; %x(13)
i_GW = 8; %x(15)
i_F0a = 11;
i_PIa = 12;
i_SPIa = 13;
i_HX = 14;
nARTIC = 14;

w = zeros(1,nTV);

switch i_TV
case {i_PRO}
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case {i_LA}
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case {i_TTCD, i_TTCL, i_TTCR}
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case {i_TBCD, i_TBCL}
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);
case i_JAW
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_VEL
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_GLO
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_F0
    art = fscanf(fp, '%5c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_PI
    art = fscanf(fp, '%5c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_SPI
    art = fscanf(fp, '%6c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
case i_TR
    art = fscanf(fp, '%4c', 1); % skip data
    idx = get_i_ARTIC(art(2:end-1));
    w(idx) = fscanf(fp, '%f', 1);   
end



function i_ARTIC = get_i_ARTIC(ARTICname)
load t_params

switch ARTICname
    case 'LX'
        i_ARTIC = i_LX;
    case 'JA' 
        i_ARTIC = i_JA;
    case 'UH'
        i_ARTIC = i_UY;
    case 'LH'
        i_ARTIC = i_LY;
    case 'CL'
        i_ARTIC = i_CL;
    case 'CA' 
        i_ARTIC = i_CA;
    case 'TL'
        i_ARTIC = i_TL;
    case 'TA'
        i_ARTIC = i_TA;
    case 'NA'
        i_ARTIC = i_NA;
    case 'GW'
        i_ARTIC = i_GW;
    case 'F0a'
        i_ARTIC = i_F0a;
    case 'PIa'
        i_ARTIC = i_PIa;
    case 'SPIa'
        i_ARTIC = i_SPIa;
    case 'HX'
        i_ARTIC = i_HX;
end