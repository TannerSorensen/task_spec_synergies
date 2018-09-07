function dx = hybrid_osc(t,x,...
    stif, alpha, beta, gamma,...
    relphase_a, relphase_targ, couplOSC,...
    genrelph, inv_genrelph, ...
    nz_task, nz_comp, nz_freq, sim_type, ...
    clock_oscID, spdng_deg, mod_strength, t_final, h_wait)


%% ode solver for a coupling graph with a grand jacobian matrix
nOSC = length(stif);
nCOUPL = sum(1:nOSC-1);
posID = (1:nOSC);
velID = (1:nOSC)+nOSC;
OSCID = 1:nOSC;

% nosie settings
switch sim_type
    case 0 % no noise
        nz_task = 0;
        nz_comp = 0;
        nz_freq = 0;
    case 1 % trial to trial
        nz_task = nz_task;
        nz_comp = nz_comp;
        nz_freq = nz_freq;
    case 2 % within a trial
        nz_task = randn(1, nCOUPL)*nz_task;
        nz_comp = randn(nOSC,1)*nz_comp;
        nz_freq = randn(nOSC,1)*nz_freq;
end

stif = stif + nz_freq;

if isempty(clock_oscID)
    mod_stif = stif;
else
    global mod_stif
    if isempty(mod_stif)
        mod_stif = stif;
    end
end

%% forward kinematic equation
[phase, amp]  = cart2pol(x(posID), x(velID)./sqrt(mod_stif)); phase = -phase;

if ~isempty(clock_oscID)
    % stif modulation
    % two (slow and fast) oscillators modulated by slow oscillator, phase(clock_oscID)
    cos_phase = (1-cos(2*phase(clock_oscID)))/2;
    sqsh_cos = 2./(1+exp(-10*(cos_phase+0)))-1;
    deg_phase = mod(phase(clock_oscID)*180/pi+360, 360);
    sqsh_cos( find(~(deg_phase >= spdng_deg(1) & deg_phase <spdng_deg(2)))) = 0; % clock-modulating pi
    mod_stif = stif*(1+mod_strength*sqsh_cos); % modulated stiffness
end

%% relative phase
% iCOUPL = 0;
% for i = 1:nOSC
%     for j = i+1:nOSC
%         iCOUPL = iCOUPL+1;
%         relphase(iCOUPL) = genrelph(iCOUPL, i)*phase(i) + genrelph(iCOUPL, j)*phase(j);
%     end
% end

% the above is modified to reduce computation time by HN 08/01
iCOUPL = find(relphase_a ~=0);
relphase = zeros(1, nOSC*(nOSC-1)/2);
for i = 1:length(iCOUPL)
    relphase(iCOUPL(i)) = genrelph(iCOUPL(i), couplOSC(i,1))*phase(couplOSC(i,1)) + genrelph(iCOUPL(i), couplOSC(i,2))*phase(couplOSC(i,2));
end

%% coupling
% for i = 1:nOSC
%     phasevel = -inv_genrelph(i, :).*(relphase_a.*sin(relphase-relphase_targ)+nz_task); %nz_task.*(relphase_a~=0)
%     coupl(i) = sum(stif(i)*(-amp(i)*cos(phase(i)))*phasevel);
% end

% the above is modified to reduce computation time by HN 08/01
phasevel = zeros(1, nOSC*(nOSC-1)/2);
for i = 1:nOSC
    phasevel(iCOUPL) = -inv_genrelph(i, iCOUPL).*(relphase_a(iCOUPL).*sin(relphase(iCOUPL)-relphase_targ(iCOUPL))+nz_task(iCOUPL)); %nz_task.*(relphase_a~=0)
    coupl(i) = sum(stif(i)*(-amp(i)*cos(phase(i)))*phasevel(iCOUPL));
end

    
%% ODE solving
dx = zeros(nOSC*2,1);
dx(posID) = x(velID);



%% generalized including modulated
alpha=-sqrt(mod_stif); beta=sqrt(mod_stif); gamma=1./sqrt(mod_stif);
dx(velID) = -alpha(OSCID).*x(velID) -beta(OSCID).*(x(posID)).^2.*x(velID)...
    -gamma(OSCID).*(x(velID)).^3 -mod_stif(OSCID).*x(posID)+coupl(OSCID)'+nz_comp;

% unmodulated
% dx(velID) = -alpha(OSCID).*x(velID) -beta(OSCID).*(x(posID)).^2.*x(velID)...
%     -gamma(OSCID).*(x(velID)).^3 -stif(OSCID).*x(posID)+coupl(OSCID)'+nz_comp;

global prevT
if round(prevT) ~= round(t)
    waitbar(t/t_final, h_wait)
end
prevT = t;