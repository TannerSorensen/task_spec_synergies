function [TV_SCORE, ART, ms_frm, last_frm, sylBegEnd] = make_osc2gest(utt_name, OSC)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)

% compute(estimate) abstract points of BEG of OSC by FRMDIFF
sz_OSC = size(OSC,2);
OSC_BEG = [0 NaN(1,sz_OSC-1)];

for j = 2:sz_OSC  % initialize
    if ~isnan(OSC(1).OSC_FRMDIFF(j))
        OSC_BEG(j) = OSC(1).OSC_FRMDIFF(j);
    end
end

while find(isnan(OSC_BEG) ==1)
    for i = 1:sz_OSC
        for j = 1:sz_OSC
            if i ~= j & ~isnan(OSC(i).OSC_FRMDIFF(j)) & isnan(OSC_BEG(i)) & ~isnan(OSC_BEG(j))
                OSC_BEG(i) = -OSC(i).OSC_FRMDIFF(j) + OSC_BEG(j);
            end
        end
    end
end

OSC_BEG = OSC_BEG -min(OSC_BEG);

% find last frame
OSC_END = [];
for i = 1: sz_OSC
    OSC_END = [OSC_END ceil((OSC_BEG(i) + (length(OSC(i).OSC_ACT)-1))/2+1)];
end
last_frm = max(OSC_END);

load t_params

% open and read tv file
% initialization for tv file
name = 1;  % tract variable name

% fn = dir(['TV',utt_name,'.G*']);    % temporary filename
fn = ffind_case(['TV',utt_name,'.O']);

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
    last_frm_tmp = fscanf(fp, '%f', 1); %last frame No.
    if last_frm_tmp > last_frm
        last_frm = last_frm_tmp;
    end

    % added by HN 0910 to take the initial phonation info (new) from tv.o
    % if there is no info, init_kill = [];
    phon_onset = fscanf(fp, '%f', 1); 
    
    
    srate = 1000/ms_frm;

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
        'PROMSUM_BLEND_SYN', zeros(1,n_frm),...
        'OSC_RAMPPHASES', [],...
        'OSC_RELPHASE', [],...
        'OSC_ID', []),...
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
    
    ART(1:nARTIC) = struct(...
        'TOTWGT', zeros(1,n_frm),...
        'PROM_ACT_JNT', zeros(1,n_frm),...
        'PROM_NEUT', zeros(1,n_frm),...
        'PROMSUM_JNT', zeros(1,n_frm));

    % initialization again for tvtv file
    name = 1;  % tract variable name
    nLA = 0; nPRO = 0; nTTCD = 0; nTTCL = 0; nJAW = 0;...
        nTTCR = 0; nTBCD = 0; nTBCL = 0; nVEL = 0; nGLO = 0;...
        nF0 = 0; nPI = 0; nSPI = 0; nTR = 0; %***** to remove 1st GLO

    % data allocation into struct
    global idx_TV
    idx_TV = [];

    while name % until fscanf can't read
        name = fscanf(fp, '%s', 1); % read first data of each line
        if isempty(strmatch('%', name))
            switch name(2:end-1) % kill ' '  e.g. 'LA' -> LA
                case 'LA'
                    nLA = nLA + 1;
                    [TV_SCORE nLA idx_TV] = alloc_tv (TV_SCORE, fp, i_LA, nLA, ms_frm, last_frm, idx_TV, OSC);
                case 'LP'
                    nPRO = nPRO + 1;
                    [TV_SCORE nPRO idx_TV] = alloc_tv (TV_SCORE, fp, i_PRO, nPRO, ms_frm, last_frm, idx_TV, OSC);
                case 'TTCD'
                    nTTCD = nTTCD + 1;
                    [TV_SCORE nTTCD idx_TV] = alloc_tv (TV_SCORE, fp, i_TTCD, nTTCD, ms_frm, last_frm, idx_TV, OSC);
                case 'TTCL'
                    nTTCL = nTTCL+ 1;
                    [TV_SCORE nTTCL idx_TV] = alloc_tv (TV_SCORE, fp, i_TTCL, nTTCL, ms_frm, last_frm, idx_TV, OSC);
                case 'TTCR'
                    nTTCR = nTTCR+ 1;
                    [TV_SCORE nTTCR idx_TV] = alloc_tv (TV_SCORE, fp, i_TTCR, nTTCR, ms_frm, last_frm, idx_TV, OSC);
                case 'TBCD'
                    nTBCD = nTBCD+ 1;
                    [TV_SCORE nTBCD idx_TV] = alloc_tv (TV_SCORE, fp, i_TBCD, nTBCD, ms_frm, last_frm, idx_TV, OSC);
                case 'TBCL'
                    nTBCL = nTBCL+ 1;
                    [TV_SCORE nTBCL idx_TV] = alloc_tv (TV_SCORE, fp, i_TBCL, nTBCL, ms_frm, last_frm, idx_TV, OSC);
                case 'JAW'
                    nJAW = nJAW+ 1;
                    [TV_SCORE nJAW idx_TV] = alloc_tv (TV_SCORE, fp, i_JAW, nJAW, ms_frm, last_frm, idx_TV, OSC);
                case 'VEL'
                    nVEL = nVEL+ 1;
                    [TV_SCORE nVEL idx_TV] = alloc_tv (TV_SCORE, fp, i_VEL, nVEL, ms_frm, last_frm, idx_TV, OSC);
                case 'GLO'
                    nGLO = nGLO+ 1;
                    [TV_SCORE nGLO idx_TV]= alloc_tv (TV_SCORE, fp, i_GLO, nGLO, ms_frm, last_frm, idx_TV, OSC);
                case 'F0'
                    nF0 = nF0+ 1;
                    [TV_SCORE nF0 idx_TV] = alloc_tv (TV_SCORE, fp, i_F0, nF0, ms_frm, last_frm, idx_TV, OSC);
                case 'PI'
                    nPI = nPI+ 1;
                    [TV_SCORE nPI idx_TV] = alloc_tv (TV_SCORE, fp, i_PI, nPI, ms_frm, last_frm, idx_TV, OSC);
                case 'SPI'
                    nSPI = nSPI+ 1;
                    [TV_SCORE nSPI idx_TV] = alloc_tv (TV_SCORE, fp, i_SPI, nSPI, ms_frm, last_frm, idx_TV, OSC);
                case 'TR'
                    nTR = nTR+ 1;
                    [TV_SCORE nTR idx_TV] = alloc_tv (TV_SCORE, fp, i_TR, nTR, ms_frm, last_frm, idx_TV, OSC);
            end
        else
            fgetl(fp);
        end
    end
    % close opened file
    fclose(fp);
end

% TV from OSC
for i = 1:nTV
    for j = 1:length(TV_SCORE(i).GEST)
        for k = 1:sz_OSC
            if strcmpi(TV_SCORE(i).GEST(j).OSC_ID, OSC(k).OSC_ID)
                TV_SCORE(i).GEST(j).BEG = OSC(k).OSC_BEG;
                TV_SCORE(i).GEST(j).END = OSC(k).OSC_END;
                TV_SCORE(i).GEST(j).PROM(OSC_BEG(k)+1:OSC_BEG(k)+length(OSC(k).OSC_ACT)) = OSC(k).OSC_ACT;
                TV_SCORE(i).GEST(j).OSC_RELPHASE = OSC(k).OSC_RELPHASE;
                TV_SCORE(i).GEST(j).OSC_ID = OSC(k).OSC_ID;
            end
        end
    end
end

sylBegEnd = getSylBegEnd(OSC);




% %%% make fake LP (lip protrusion) for unspecified LP %%%
%
% % find LA gestures that need fake LP
% fake_i = []; % LA gestures that need fake LP
% sz_PRO_gest = length(TV_SCORE(i_PRO).GEST);
% sz_LA_gest = length(TV_SCORE(i_LA).GEST);
% for i = 1:sz_LA_gest
%     b = 0;
%     for j = 1:sz_PRO_gest
%         if TV_SCORE(i_LA).GEST(i).BEG == TV_SCORE(i_PRO).GEST(j).BEG & ...
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
%         if sz_PRO_gest == 1 & ...
%                 TV_SCORE(i_PRO).GEST(sz_PRO_gest).BEG == 0 & ...
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
%                 'PROMSUM_BLEND_SYN', zeros(1,n_frm),...
%                 'OSC_RAMPPHASES', [],...
%                 'OSC_RELPHASE', [],...
%                 'OSC_ID', []);
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
%         % OSC info for fake LP
%         TV_SCORE(i_PRO).GEST(i).OSC_RELPHASE = TV_SCORE(i_LA).GEST(i).OSC_RELPHASE;
%         TV_SCORE(i_PRO).GEST(i).OSC_ID = TV_SCORE(i_LA).GEST(i).OSC_ID;
%
%         j = j+1;
%     end
%     nPRO = length(TV_SCORE(i_PRO).GEST); % recompute number of PRO gestures
% end


function sylBegEnd = getSylBegEnd(OSC)
sylBegEnd = [];
Ft = {OSC.OSC_ID};
nSyl = 1;
while 1
    idSeg = regexpfind(Ft, [num2str(nSyl) '$']);
    if ~idSeg   % IdSeg == 0
        break
    end
    sylBegEnd = [sylBegEnd ; min([OSC(idSeg).OSC_BEG]) max([OSC(idSeg).OSC_END])];
    nSyl = nSyl+1;
end



function [TV_SCORE, nGEST, idx_TV] = alloc_tv (TV_SCORE, fp, i_TV, nGEST, ms_frm, last_frm, idx_TV, OSC)
load t_params

idx_TV = [idx_TV i_TV];

if 1 %~(i_TV == i_GLO) %~(i_TV == i_GLO & BEG == 0 & END == 10)
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
        'PROMSUM_BLEND_SYN', zeros(1,n_frm),...
        'OSC_RAMPPHASES', [],...
        'OSC_RELPHASE', [],...
        'OSC_ID', []);

    osc_id = fscanf(fp, '%s', 1); % oscillator(gesture) ID (e.g. 'ON1_CLO')
    osc_id = osc_id(2:end-1);

    switch i_TV
        case { i_LA, i_PRO, i_TBCD, i_TTCD, i_JAW}
            TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1)/mm_per_dec;
            %             if i_TV == i_LA % fake-up lip-protrusion tract-variable parameters
            %                 TV_SCORE(i_PRO).GEST(nGEST(2)).x.VALUE = 9.6/mm_per_dec;
            %             end
        case {i_TBCL, i_TTCL, i_TTCR}
            TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1)/deg_per_rad;
        case {i_VEL, i_GLO, i_F0, i_PI, i_SPI, i_TR}
            TV_SCORE(i_TV).GEST(nGEST).x.VALUE = fscanf(fp, '%f', 1);
    end
    frq_tmp = fscanf(fp, '%f', 1)*2*pi;
    TV_SCORE(i_TV).GEST(nGEST).k.VALUE = frq_tmp^2;
    TV_SCORE(i_TV).GEST(nGEST).d.VALUE = fscanf(fp, '%f', 1)*2*frq_tmp;
    TV_SCORE(i_TV).GEST(nGEST).w.VALUE = get_w(fp, i_TV);
    %     if i_TV == i_LA % fake-up lip-protrusion tract-variable parameters
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).k.VALUE = frq_tmp^2;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).d.VALUE = 1*2*frq_tmp;
    %         LX_fake = 1;
    %         w = zeros(1,nARTIC);
    %         w(i_LX) = LX_fake;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).w.VALUE = w;
    %     end

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

    %     if length(nGEST) == 2
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).x.ALPHA = alpha;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).x.BETA = beta;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).k.ALPHA = alpha;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).k.BETA = beta;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).d.ALPHA = alpha;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).d.BETA = beta;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).w.ALPHA = alpha;
    %         TV_SCORE(i_PRO).GEST(nGEST(2)).w.BETA = beta;
    %     end

    % search OSC for osc_id of TV
    len_OSC = length(OSC);
    for i = 1:len_OSC
        if strcmp (OSC(i).OSC_ID, osc_id)
            nOSC = i;
        end
    end

    TV_SCORE(i_TV).GEST(nGEST).OSC_RELPHASE = OSC(nOSC).OSC_RELPHASE;
    TV_SCORE(i_TV).GEST(nGEST).OSC_ID = osc_id;
    TV_SCORE(i_TV).GEST(nGEST).OSC_RAMPPHASES = OSC(nOSC).OSC_RAMPPHASES;
end


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