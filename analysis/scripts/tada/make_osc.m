function OSC = make_osc(utt_name, state, handles)
% Copyright Haskins Laboratories, Inc., 2001-2005
% 300 George Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)

oscSimParams = state.oscSimParams;
oscSimNoise = state.oscSimNoise;
speechRate = state.speechRate;

%h = waitbar(0,'Please wait... computing relative phasing');
load t_params

% open and read PH file
% initialization for tv file
osc_id = 1;  % tract variable name
iOSC = 0;
flg = 'osc'; % 'osc', 'coupl'
iCOUPL = 0;
fn = ffind_case(['PH',utt_name,'.O']);

if ~isempty(fn)
    fp = fopen(fn, 'rt'); % open data file
    while osc_id
        osc_id = fscanf(fp, '%s', 1); % read first data of each line
        if ~isempty(osc_id)
            if isempty(strmatch('%', osc_id)) & ~strcmpi(osc_id, '/coupling/')
                if strcmpi(flg, 'osc')
                    iOSC = iOSC + 1;
                    OSC(iOSC) = struct('OSC_ID',[], 'OSC_RAMPPHASES',[], 'OSC_RELPHASE',[],...
                        'OSC_BEG',[], 'OSC_END',[], 'OSC_FRMDIFF',[], 'OSC_ACT',[], 'OSC_FINRELPHASE',[],...
                        'OSC_OMEGA', [], 'OSC_GENRELPH', [], 'OSC_PHASEINIT', [], 'OSC_CYCDUR', [],...
                        'OSC_ESCAP',[], 'OSC_AMPINIT',[], 'OSC_COUPLSTRNTH',[],...
                        'OSC_STDRELPHASE', [], 'OSC_PEAKS', [], 'OSC_FINPHASE', [], 'OSC_POS', []);

                    OSC(iOSC).OSC_ID = osc_id(2:end-1);
                    OSC_ID_CELL(iOSC) = {osc_id(2:end-1)};
                    % specify omega (frequency of oscillators)
                    OSC(iOSC).OSC_OMEGA = fscanf(fp, '%f', 1);
                    omega(iOSC) = OSC(iOSC).OSC_OMEGA;

                    % specify gen relphase
                    OSC(iOSC).OSC_GENRELPH = fscanf(fp, '%f', 1);
                    oscgenrelph(iOSC) = OSC(iOSC).OSC_GENRELPH;

                    % specify escapement
                    OSC(iOSC).OSC_ESCAP = fscanf(fp, '%f', 1);
                    escap(iOSC) = OSC(iOSC).OSC_ESCAP;

                    % specify initial amplitude
                    OSC(iOSC).OSC_AMPINIT = fscanf(fp, '%f', 1);
                    amp_init(iOSC) = OSC(iOSC).OSC_AMPINIT;

                    % specify initial phase
                    tmp = fscanf(fp, '%f', 1);
                    if isempty(tmp)
                        tmp = fscanf(fp, '%c', 3);
                        if strcmpi(tmp, 'NaN')
                            tmp = NaN;
                        end
                    end
                    OSC(iOSC).OSC_PHASEINIT = tmp;
                    phaseinit(iOSC) = OSC(iOSC).OSC_PHASEINIT;

                    fscanf(fp, '%f', 1); % to place the pointer to the next character '/'
                    fscanf(fp, '%c', 1); %skip '/'

                    n = 1;
                    while ~isempty(n)            % till meet non-numeric delimiter
                        n = fscanf(fp, '%f', 1);
                        OSC(iOSC).OSC_RAMPPHASES = [OSC(iOSC).OSC_RAMPPHASES n];
                    end
                elseif strcmpi(flg, 'coupl')
                    
                    iCOUPL = iCOUPL + 1;
                    osc_id1 = osc_id(2:end-1);
                    tmp = fscanf(fp, '%s', 1);
                    osc_id2 = tmp(2:end-1);
                    
                    idx1 = find(strcmpi(OSC_ID_CELL, osc_id1) ==1);
                    idx2 = find(strcmpi(OSC_ID_CELL, osc_id2) ==1);

                    a1 = fscanf(fp, '%f', 1);
                    a2 = fscanf(fp, '%f', 1);
                    
                    if length(OSC(idx1).OSC_COUPLSTRNTH) ~=iOSC % initialize
                        OSC(idx1).OSC_COUPLSTRNTH = zeros(1,iOSC);
                    end
                    if length(OSC(idx2).OSC_COUPLSTRNTH) ~=iOSC % initialize
                        OSC(idx2).OSC_COUPLSTRNTH = zeros(1,iOSC);
                    end
                    OSC(idx1).OSC_COUPLSTRNTH(idx2) = a1;
                    OSC(idx2).OSC_COUPLSTRNTH(idx1) = a2;

                    n = fscanf(fp, '%f', 1);
                    
                    if length(OSC(idx1).OSC_RELPHASE) ~=iOSC % initialize
                        OSC(idx1).OSC_RELPHASE = NaN(1,iOSC);
                    end
                    if length(OSC(idx2).OSC_RELPHASE) ~=iOSC % initialize
                        OSC(idx2).OSC_RELPHASE = NaN(1,iOSC);
                    end
                    OSC(idx1).OSC_RELPHASE(idx2) = -n; %*
                    OSC(idx2).OSC_RELPHASE(idx1) = n; %*
                end
            else
                if strcmpi(osc_id, '/coupling/')
                    flg = 'coupl';
                end
                fgetl(fp); % throw away comments
            end
        end
    end
end

nOSC = length(OSC);

%% initialize OSC_FRMDIFF as NaN
for i = 1:nOSC
    OSC(i).OSC_FRMDIFF = NaN(1,nOSC);
    OSC(i).OSC_FINRELPHASE = NaN(1,nOSC);
    OSC(i).OSC_STDRELPHASE = NaN(1,nOSC);
    OSC(i).OSC_FINPHASE = NaN(1,nOSC); 
end

%% component oscillator parameters
omega = omega';
escap = escap';
amp_init = amp_init';

%% coupling parameters
nCOUPL = sum(1:nOSC-1);
nOSC = round(roots([1, -1, -nCOUPL*2])); % to prevent nOSC from being "double"
nOSC = nOSC(find(nOSC>0));
relphase_a=zeros(1,nCOUPL);
relphase_targ= zeros(1,nCOUPL)* pi/180;

couplOSC =[];
a = [];
targ = [];
iCOUPL = 0;
COUPLs = [];
for i = 1:nOSC
    for j = i+1:nOSC
        iCOUPL = iCOUPL +1;
        if ~isnan(OSC(i).OSC_RELPHASE(j))
            couplOSC = [couplOSC; [i j]];
            % specify coupling strength
            a = [a; OSC(i).OSC_COUPLSTRNTH(j) OSC(j).OSC_COUPLSTRNTH(i)];
            targ = [targ; OSC(i).OSC_RELPHASE(j)];
            COUPLs = [COUPLs iCOUPL];
        end
    end
end



%% %%%%%%%%%%%%%%%%%%%%% initialize phase_init%%%%%%%%%%%%%%%%%% 
% (this procedure may have to be blocked to avoid unexpected resultant
% phases from non-vowel loops). So totally random initial phases!!!
% 
% 1. Specified
% 2. V (phase init to 0)
% 3. C coupled to V (to relphase)
% 4. C coupled to nonV (to relphase)


% CCV
for i = 1:nOSC
    if regexpfind(OSC(i).OSC_ID, 'v\d+')
        if isnan(OSC(i).OSC_PHASEINIT)
            OSC(i).OSC_PHASEINIT = 0;       % V (phase init to 0)
        end
        couplC2V = find(OSC(i).OSC_RELPHASE == 0);   % find Cs 0-degree coupled to V
        couplC2V = couplC2V(find(ismember(couplC2V, regexpfind({OSC(:).OSC_ID}, '^v'))==0));   % exclude Vs (incl. lip rounding) coupled to V
        n = [];
        if length(couplC2V) > 1 % if c is multiple in onset
            for j = couplC2V    % extract segment index in onset and sort by ascending order
                subID = getSubID(OSC(j).OSC_ID); n = [n str2num(subID{1}(end))];
            end
            [tmp id] = sort(n);
            
            if length(couplC2V)==2
                if isnan(OSC(couplC2V(id(1))).OSC_PHASEINIT), OSC(couplC2V(id(1))).OSC_PHASEINIT = 60; end
                if isnan(OSC(couplC2V(id(2))).OSC_PHASEINIT), OSC(couplC2V(id(2))).OSC_PHASEINIT = -60; end
            elseif length(couplC2V)==3                     % CCC
                if isnan(OSC(couplC2V(id(1))).OSC_PHASEINIT), OSC(couplC2V(id(1))).OSC_PHASEINIT = 90; end
                if isnan(OSC(couplC2V(id(2))).OSC_PHASEINIT), OSC(couplC2V(id(2))).OSC_PHASEINIT = 0; end
                if isnan(OSC(couplC2V(id(3))).OSC_PHASEINIT), OSC(couplC2V(id(3))).OSC_PHASEINIT = -90; end
            end
        end
    end
end

% if any unfilled, assign random number
for i = 1:nOSC
    if isnan(OSC(i).OSC_PHASEINIT) % if not NaN, specify it!
        OSC(i).OSC_PHASEINIT = rand*360-180;
    end
end

phase_init = [OSC.OSC_PHASEINIT]'*pi/180;


[relphase_a, relphase_targ] = setCOUPL(couplOSC, a', targ*pi/180, relphase_a, relphase_targ);

%phase_init = zeros(nOSC, 1)+randn([nOSC 1])*pi/180; %round(rand([nOSC 1])*360)*pi/180; % randint(nOSC,1,360)*pi/180; don't use randint (communication toolbox)
stif=omega.^2; nOSC = length(omega);
alpha=-sqrt(stif).*escap; beta=sqrt(stif).*escap; gamma=escap./sqrt(stif);
pos_init = amp_init .* cos(phase_init);
vel_init = -sqrt(stif) .* amp_init .* sin(phase_init);

% generalized relphase parameters (nOSC x nCOUPL)
% Jacobian matrix: m x n (m: tasks, couplings, n: articulators, oscillators)
genrelph = zeros(size(relphase_a,2), nOSC);

iCOUPL = 0;
for i = 1:nOSC
    for j = i+1:nOSC
        iCOUPL = iCOUPL+1;

%         % estimation of generalized relative phases from omega ratio
%         gcd_omega(iCOUPL) = gcd(round(omega(i)), round(omega(j)));
%         lcm_omega(iCOUPL) = lcm(round(omega(i)), round(omega(j)));
%         genrelph(iCOUPL, i) = -round(omega(j))/gcd_omega(iCOUPL);
%         genrelph(iCOUPL, j) = round(omega(i))/gcd_omega(iCOUPL);

        % allocation of specified generalized relative phases
        gcd_oscgenrelph(iCOUPL) = gcd(round(oscgenrelph(i)), round(oscgenrelph(j)));
        genrelph(iCOUPL, i) = -round(oscgenrelph(j))/gcd_oscgenrelph(iCOUPL);
        genrelph(iCOUPL, j) = round(oscgenrelph(i))/gcd_oscgenrelph(iCOUPL);

        relphase_init(iCOUPL) = genrelph(iCOUPL, j)*phase_init(j) + genrelph(iCOUPL, i)*phase_init(i);
    end
end

inv_genrelph = pinv(genrelph);
% psuedo-inverse is scaled by nOSC HN 08/01
inv_genrelph = inv_genrelph*nOSC; 
% unidirectional(or asymmetrical) coupling computation after pseudo-inverse of genrelph

iCOUPL = 0;
for i = 1:nOSC
    for j = i+1:nOSC
        iCOUPL = iCOUPL+1;
        inv_genrelph(i, iCOUPL) = inv_genrelph(i, iCOUPL)*OSC(i).OSC_COUPLSTRNTH(j);
        inv_genrelph(j, iCOUPL) = inv_genrelph(j, iCOUPL)*OSC(j).OSC_COUPLSTRNTH(i);
        %inv_genrelph(find(~ismember([1:nOSC], [i j])==1), iCOUPL) =0;
    end
end

cell_oscSimParams = mat2cell(oscSimParams,[1],[ones(1,length(oscSimParams))]);
for i = 1:length(oscSimParams)
    if isnan(cell_oscSimParams{i})
        cell_oscSimParams{i} = [];
    end
end

t_final = cell_oscSimParams{1};
options = odeset('RelTol', cell_oscSimParams{3}, 'MaxStep', cell_oscSimParams{4}, 'InitialStep', cell_oscSimParams{5}, 'refine', cell_oscSimParams{6});
nz_task = oscSimNoise(1); 
nz_comp = oscSimNoise(2); 
nz_freq = oscSimNoise(3); 
sim_type = oscSimNoise(4);

h_wait = waitbar(0,'solving ODE for steady states of coupled oscillators');
global prevT, prevT = 0;
[t,x] = ode45(@hybrid_osc,[0 t_final],[pos_init vel_init], options,...
    stif, alpha, beta, gamma,...
    relphase_a, relphase_targ, couplOSC,...
    genrelph, inv_genrelph, ...
    nz_task, nz_comp, nz_freq, sim_type, ...
    [], [], [], t_final, h_wait);
clear prevT
close(h_wait)

posID = (1:nOSC);
velID = (1:nOSC)+nOSC;
[phase, amp]  = cart2pol(x(:,posID), x(:,velID)/diag(sqrt(stif))); phase = -phase;

% iCOUPL = 0;
% for i = 1:nOSC
%     for j = i+1:nOSC
%         iCOUPL = iCOUPL+1;
%         relphase(:,iCOUPL) = genrelph(iCOUPL, i)*phase(:,i) + genrelph(iCOUPL, j)*phase(:,j);
%     end
%     [OSC(i).OSC_CYCDUR OSC(i).OSC_PEAKS]  = cal_cyc(x(:,i), t);
%     OSC(i).OSC_FINPHASE = phase(end,i)*180/pi;
%     OSC(i).OSC_POS = x(:,i);
% end

% the above is modified to reduce computation time by HN 08/01
iCOUPL = find(relphase_a ~=0);
relphase = zeros(length(phase),nOSC*(nOSC-1)/2);
for i = 1:length(iCOUPL)
    relphase(:,iCOUPL(i)) = genrelph(iCOUPL(i), couplOSC(i,1))*phase(:,couplOSC(i,1)) + genrelph(iCOUPL(i), couplOSC(i,2))*phase(:,couplOSC(i,2));
end

for i = 1:nOSC
    [OSC(i).OSC_CYCDUR OSC(i).OSC_PEAKS]  = cal_cyc(x(:,i), t);
    OSC(i).OSC_FINPHASE = phase(end,i)*180/pi;
    OSC(i).OSC_POS = x(:,i);
end






relphase = unwrap(relphase) * 180/pi;
%relphase = mod((relphase + 180),360) - 180; % commented by HN 09/24/06 redundant with the procedure below

settleTime = cell_oscSimParams{2};
settleStep = round(length(t)*settleTime/t_final);



% adjusting resultant relphase based on target relphase: e.g. -179...-1 0 1...179
fin_relphase = [];
for i = COUPLs
    if  abs(mean(relphase(settleStep:end,i))-relphase_targ(i)/pi*180) >180 %&relphase(end,i)*relphase_targ(i)/pi*180 < 0.001
        if (mean(relphase(settleStep:end,i))-relphase_targ(i)/pi*180)>= 0
            rephase = -360;
        else
            rephase = 360;
        end
    else
        rephase = 0;
    end
    fin_relphase = [fin_relphase; mean(relphase(settleStep:end,i))+rephase];
    relphase(:,i) = relphase(:,i) + rephase;
end

stdrelphase = std(relphase(settleStep:end,:));

%% display of relative phases
if ~isempty (handles)
    if strcmpi(get(handles.mn_plotRelPhase, 'checked'), 'on')
        h= figure; set(h, 'name', 'Relative phases'); hold on
        for i = 1:size(couplOSC, 1)
            clr = get(gca, 'colororder');
            plot(t, relphase(:, COUPLs(i)), 'color', clr(mod(i, size(clr, 1))+1,:))
            xlabel ('Time')
            text(-25, relphase(1,COUPLs(i)),...
                [texlabel(OSC(couplOSC(i,2)).OSC_ID, 'literal') '-' texlabel(OSC(couplOSC(i,1)).OSC_ID, 'literal')],...
                'FontSize',8, 'color', clr(mod(i, size(clr, 1))+1,:))
        end
        hold off
    end
end

%% display of cycle ticks
if ~isempty (handles)
    if strcmpi(get(handles.mn_plotCycleTicks, 'checked'), 'on')
        h= figure; set(h, 'name', 'Cycle Ticks');
        nOSC = length(OSC);
        for i = 1:nOSC
            szX = size(x,1);

            [peaks throughs]= find_peaks(x(:,i));

            npeaks = length(peaks);
            ticks = ones(2,npeaks);
            ticks(1,:) = ticks(1,:)*i -.1;    ticks(2,:) = ticks(2,:)*i +.1;
            plot([t(peaks)';t(peaks)'], ticks, 'k', 'linewidth', 2.5), hold on

            nthroughs = length(throughs);
            ticks = ones(2,nthroughs);
            ticks(1,:) = ticks(1,:)*i -.03;    ticks(2,:) = ticks(2,:)*i +.03;
            plot([t(throughs)';t(throughs)'], ticks, 'k', 'linewidth', 2),

            plot([0 t(end)], [i i], 'k')
            xlabel ('Time')
            text(t(end)-11.5, i, texlabel(OSC(i).OSC_ID, 'literal'), 'FontSize', 8, 'color', 'r')
        end
        axis([t(end)-10 t(end) 0 nOSC+1])
        hold off
    end
end

%% store std of relative phases
k = 0;
for i = 1:nOSC
    for j = i+1:nOSC
        k = k+1;
        OSC(i).OSC_STDRELPHASE(j) = stdrelphase(k);
        OSC(j).OSC_STDRELPHASE(i) = stdrelphase(k);
    end
end


%% setting activation interval (considering speechRate, osc_freq)
for i = 1:nOSC
        phi = [0 OSC(i).OSC_RAMPPHASES]/180*pi;
        t = phi/(2*pi)/speechRate*(100/pi)*OSC(i).OSC_CYCDUR;%/omega(i); % divided by omega 'cause fast osc should have short frames

        plateau = ones(1, round(t(3)-t(2)));

        n_ramp_rise_frm = round(t(2)-t(1));
        n_ramp_fall_frm = round(t(4)-t(3));

        ramp_rise_frm = 0:1/n_ramp_rise_frm:1;
        theta_rise_frm = ramp_rise_frm*pi;
        ramp_rise_act = -1/2*cos(theta_rise_frm) +1/2;

        ramp_fall_frm = 1:1/n_ramp_fall_frm:2;
        theta_fall_frm = ramp_fall_frm*pi;
        ramp_fall_act = -1/2*cos(theta_fall_frm) +1/2;

        out = [ramp_rise_act plateau ramp_fall_act];
        OSC(i).OSC_ACT = out;
end

%% determining cycles in case of relative phases of oscillators with different frequencies
for i = 1:length(fin_relphase)
    if OSC(couplOSC(i,1)).OSC_GENRELPH >= OSC(couplOSC(i,2)).OSC_GENRELPH       % distinguish btw slow and fast oscillators
        fastOSC = 1; slowOSC = 2;
    else
        fastOSC = 2; slowOSC = 1;
    end

% if in-phase, compare onsets, otherwise, compare offsets
    dropPeakID = 5; % from the end of cycles
    drop_pnt = OSC(couplOSC(i,slowOSC)).OSC_PEAKS(end-dropPeakID);               % project from slow oscillator
    move_pnt = drop_pnt + OSC(couplOSC(i,fastOSC)).OSC_CYCDUR ...                % move on fast oscillator by target relative phase
        * OSC(couplOSC(i,fastOSC)).OSC_RELPHASE(couplOSC(i,slowOSC))/360;
    [val findPeakID]=min(abs(OSC(couplOSC(i,fastOSC)).OSC_PEAKS -move_pnt));     % find the nearst peak on fast oscillator

    if OSC(couplOSC(i,1)).OSC_RELPHASE(couplOSC(i,2)) == 0
        comp_offset = 0; % inphase: compare onsets
    else
        comp_offset = 1; % non-inphase: compare offsets
    end
    tmpPeak(slowOSC) = OSC(couplOSC(i,slowOSC)).OSC_PEAKS(end-dropPeakID-comp_offset); % toward onset from offset
    tmpPeak(fastOSC) = OSC(couplOSC(i,fastOSC)).OSC_PEAKS(findPeakID-comp_offset);     % toward onset from offset
    
% compare activation offset and oscillator onset

%     dropPeakID = 5; % from the end of cycles
%     drop_pnt = OSC(couplOSC(i,slowOSC)).OSC_PEAKS(end-dropPeakID);               % project from slow oscillator
%     move_pnt = drop_pnt + OSC(couplOSC(i,fastOSC)).OSC_CYCDUR ...                % move on fast oscillator by target relative phase
%         * OSC(couplOSC(i,fastOSC)).OSC_RELPHASE(couplOSC(i,slowOSC))/360;
%     [val findPeakID]=min(abs(OSC(couplOSC(i,fastOSC)).OSC_PEAKS -move_pnt));     % find the nearst peak on fast oscillator
% 
%     if (OSC(couplOSC(i,1)).OSC_GENRELPH > OSC(couplOSC(i,2)).OSC_GENRELPH &...
%         OSC(couplOSC(i,1)).OSC_RELPHASE(couplOSC(i,2)) > 0) |...
%        (OSC(couplOSC(i,1)).OSC_GENRELPH < OSC(couplOSC(i,2)).OSC_GENRELPH &...
%         OSC(couplOSC(i,2)).OSC_RELPHASE(couplOSC(i,1)) > 0)
% 
%         tmpPeak(slowOSC) = OSC(couplOSC(i,slowOSC)).OSC_PEAKS(end-dropPeakID)...
%             -OSC(couplOSC(i,slowOSC)).OSC_CYCDUR* OSC(couplOSC(i,slowOSC)).OSC_RAMPPHASES(end)/360; % toward onset from offset
%         tmpPeak(fastOSC) = OSC(couplOSC(i,fastOSC)).OSC_PEAKS(findPeakID-1);     % toward onset from offset
%     else
%         tmpPeak(slowOSC) = OSC(couplOSC(i,slowOSC)).OSC_PEAKS(end-dropPeakID); % toward onset from offset
%         tmpPeak(fastOSC) = OSC(couplOSC(i,fastOSC)).OSC_PEAKS(findPeakID);     % toward onset from offset
% 
%     end


    frmdiff = round((tmpPeak(2)-tmpPeak(1))/speechRate*(100/pi));                     % compute FRAME difference 

    OSC(couplOSC(i,1)).OSC_FRMDIFF(couplOSC(i,2)) = frmdiff;
    OSC(couplOSC(i,2)).OSC_FRMDIFF(couplOSC(i,1)) = -frmdiff;
    OSC(couplOSC(i,1)).OSC_FINRELPHASE(couplOSC(i,2)) = fin_relphase(i);
    OSC(couplOSC(i,2)).OSC_FINRELPHASE(couplOSC(i,1)) = -fin_relphase(i);
end

%% computing(estimating) absolute points of BEG of OSC by FRMDIFF
OSC_BEG = [0 NaN(1,nOSC-1)];
for j = 2:nOSC  % initialize
    if ~isnan(OSC(1).OSC_FRMDIFF(j))
        OSC_BEG(j) = OSC(1).OSC_FRMDIFF(j);
    end
end

k=0;
while find(isnan(OSC_BEG) ==1)
    k = k+1;
    for i = 1:nOSC
        for j = 1:nOSC
            if i ~= j & ~isnan(OSC(i).OSC_FRMDIFF(j)) & isnan(OSC_BEG(i)) & ~isnan(OSC_BEG(j))
                OSC_BEG(i) = -OSC(i).OSC_FRMDIFF(j) + OSC_BEG(j);
            end
        end
    end
    if k > 200
        error('Some coupling(s) might be missing')
    end
end

OSC_BEG = OSC_BEG -min(OSC_BEG);

%% allocate BEG, END
for i = 1:nOSC
    OSC(i).OSC_BEG = round(OSC_BEG(i)/2);
    OSC(i).OSC_END = round((OSC_BEG(i) + length(OSC(i).OSC_ACT) -1)/2);
end