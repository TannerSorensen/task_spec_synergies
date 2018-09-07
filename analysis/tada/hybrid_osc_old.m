function dx = hybrid_osc(t,x,...
    stif, alpha, beta, gamma,...
    relphase_a, relphase_targ,...
    genrelph, inv_genrelph, nz_task,...
    clock_oscID, spdng_deg, mod_strength)

if isempty(clock_oscID)
    mod_stif = stif;
else
    if isempty(mod_stif)
        mod_stif = stif;
    end
end

% ode solver for a coupling graph with a grand jacobian matrix
nOSC = length(stif);
posID = (1:nOSC);
velID = (1:nOSC)+nOSC;
OSCID = 1:nOSC;

% forward kinematic equation
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

% relative phase
iCOUPL = 0;
for i = 1:nOSC
    for j = i+1:nOSC
        iCOUPL = iCOUPL+1;
        relphase(iCOUPL) = genrelph(iCOUPL, i)*phase(i) + genrelph(iCOUPL, j)*phase(j);
    end
end

% coupling
for i = 1:nOSC
    phasevel = -inv_genrelph(i, :).*(relphase_a.*sin(relphase-relphase_targ)+nz_task); %nz_task.*(relphase_a~=0)
    coupl(i) = sum(stif(i)*(-amp(i)*cos(phase(i)))*phasevel);
end

% ODE solving
dx = zeros(nOSC*2,1);
dx(posID) = x(velID);
nz_comp = 0; %randn; %component noise

% generalized including modulated
alpha=-sqrt(mod_stif); beta=sqrt(mod_stif); gamma=1./sqrt(mod_stif);
dx(velID) = -alpha(OSCID).*x(velID) -beta(OSCID).*(x(posID)).^2.*x(velID)...
    -gamma(OSCID).*(x(velID)).^3 -mod_stif(OSCID).*x(posID)+coupl(OSCID)'+nz_comp;;

% unmodulated
% dx(velID) = -alpha(OSCID).*x(velID) -beta(OSCID).*(x(posID)).^2.*x(velID)...
%     -gamma(OSCID).*(x(velID)).^3 -stif(OSCID).*x(posID)+coupl(OSCID)'+nz_comp;