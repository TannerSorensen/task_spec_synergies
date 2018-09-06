function [A, ADOT, TV, TVDOT, TV_SCORE, ART, ms_frm, last_frm] = task_dynamics(utt_name, TV_SCORE, ART, ms_frm, last_frm)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)

flg_jawNeut = 0;
flg_anatom = 1;

h = waitbar(0,'Please wait... computing TV');
load t_params

A = [];
ADOT = [];
TV = [];
TVDOT = [];

global ramp_style
if nargin == 1
    if ramp_style
        [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name);
        [TV_SCORE] = make_prom(TV_SCORE, ms_frm, last_frm); % compute PROM and make fake PRO
        [TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm);
    else
        [TV_SCORE, ART, ms_frm, last_frm] = make_gest(utt_name);
        [TV_SCORE] = make_rampprom(TV_SCORE, ms_frm, last_frm);
        [TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm);
    end
end

n_frm = (last_frm)*ms_frm/wag_frm;
a = RESTAN';
adot = zeros(nARTIC,1);

A = cat(2, A, a);
ADOT = cat(2, ADOT, adot);

[tv tvdot] = tv_forward(a, adot);
TV = cat(2,TV, tv);
TVDOT = cat(2, TVDOT, tvdot);

options = odeset('RelTol',[], 'AbsTol',[], 'MaxStep', [.005], 'InitialStep', [.005], 'Refine', []);

for i = 1 : n_frm-1
    [tv, tvdot, j, jdotadot] = tv_forward(a, adot);
    
    %==============================%
    %       FORWARD DYNAMICS       %
    %       INVERSE KINEMATICS     %
    %==============================%
    PROM_ACT = [];
    TOTWGT = [];
    PROM_ACT_JNT = [];
    % NULLACC_SPR = [];
    % NULLACC_DMP = [];
    % NULLACC = [];
    d_BLEND = [];
    x_BLEND =[];
    k_BLEND = [];
    PROM_NEUT = [];

    %%% neutral attractor %%%%%%%
    NEUTARTIC_DEL = a - RESTAN';
    NEUTACC_SPR = k_NEUT' .* NEUTARTIC_DEL;
    NEUTACC_DMP = d_NEUT' .* adot;
    NEUTACC = -NEUTACC_SPR - NEUTACC_DMP;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    N_GEST = [];

    for m = 1:nTV
        PROM_ACT = cat(2, PROM_ACT, TV_SCORE(m).TV.PROM_ACT(i));
        if length(TV_SCORE(m).TV.x_BLEND) ~=0
            x_BLEND = cat(2, x_BLEND, TV_SCORE(m).TV.x_BLEND(i));
        else
            x_BLEND = cat(2, x_BLEND, 0);
            N_GEST = [N_GEST m];
        end

        if length(TV_SCORE(m).TV.d_BLEND) ~=0
            d_BLEND = cat(2, d_BLEND, TV_SCORE(m).TV.d_BLEND(i));
        else
            d_BLEND = cat(2, d_BLEND, 0);
        end

        if length(TV_SCORE(m).TV.k_BLEND) ~=0
            k_BLEND = cat(2, k_BLEND, TV_SCORE(m).TV.k_BLEND(i));
        else
            k_BLEND = cat(2, k_BLEND, 0);
        end
    end

    for n = 1:nARTIC
        TOTWGT = cat(2, TOTWGT, ART(n).TOTWGT(i));
        PROM_ACT_JNT = cat(2, PROM_ACT_JNT, ART(n).PROM_ACT_JNT(i));
        %     NULLACC_SPR = cat(2, NULLACC_SPR, -NEUTACC_SPR(n));
        %     NULLACC_DMP = cat(2, NULLACC_DMP, -NEUTACC_DMP(n));
        %     NULLACC = NULL_KSCL *NULLACC_SPR + NULL_DSCL *NULLACC_DMP;
        PROM_NEUT = cat(2, PROM_NEUT, ART(n).PROM_NEUT(i));
    end

    %%% null projection %%%%%%%%%%
    NULLACC_SPR = -NEUTACC_SPR;
    NULLACC_DMP = -NEUTACC_DMP;
    NULLACC = NULL_KSCL *NULLACC_SPR + NULL_DSCL *NULLACC_DMP;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    PROM_ACT = diag(PROM_ACT);    
    TOTWGT = diag(TOTWGT);
    Ident_TV = eye(nTV, nTV);
    TOTWGTINV = pinv(TOTWGT);
    j_tmp = j;
    %j_tmp(i_JAW,i_JA) = 1;
    % commented because TV(i_JAW) is Constriction Degree, not angle. 20070619 by HN
    j_tmp(i_VEL,i_NA) = 1;
    j_tmp(i_GLO,i_GW) = 1;
    j_tmp(i_F0,i_F0a) = 1;
    j_tmp(i_PI,i_PIa) = 1;
    j_tmp(i_SPI,i_SPIa) = 1;
    j_tmp(i_TR,i_HX) = 1;
    
    JAC = PROM_ACT*j_tmp;
    TJAC = JAC';
    WM1 = TOTWGTINV*TJAC;
    WM2 = JAC*WM1;
    JACJACT = WM2+(Ident_TV-PROM_ACT);
    WM3 = pinv(JACJACT);
    
    IPJAC = TOTWGTINV*TJAC*WM3;

    Ident_ARTIC = eye(nARTIC, nARTIC);
    IDENT_ID_GATE = diag(Ident_ARTIC * PROM_ACT_JNT');
    WM7 = IPJAC*JAC;
    
    
    NULLPROJ = IDENT_ID_GATE-WM7;
    JNTACC_NULL = NULLPROJ*NULLACC;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%% forward dynamics%%%%%%%%%%%%%
    tvdot_tmp = tvdot;
    tvdot_tmp([i_VEL i_GLO i_F0 i_PI i_SPI i_TR])...
        = [adot(i_NA) adot(i_GW) adot(i_F0a) adot(i_PIa) adot(i_SPIa) adot(i_HX)];
    WV3TV =  diag(d_BLEND)*tvdot_tmp;

    tv_tmp = tv;
    
    % tv_tmp([i_JAW i_VEL i_GLO i_F0 i_PI i_SPI i_TR]) = [a(i_JA) a(i_NA) a(i_GW) a(i_F0a) a(i_PIa) a(i_SPIa) a(i_HX)];
    % commented and replaced with the one below
    % because TV(i_JAW) is Constriction Degree, not angle.
    % 20070619 by HN
    tv_tmp([i_VEL i_GLO i_F0 i_PI i_SPI i_TR]) = [a(i_NA) a(i_GW) a(i_F0a) a(i_PIa) a(i_SPIa) a(i_HX)];


    % old BSDEL
    % also see make_x_BLEND in make_tvscore
    % BSDEL = tv_tmp -  x_BLEND'; % delta tv

    % new BSDEL
    BSDEL = tv_tmp - (tv_n + (1+TV_SCORE(i_SPI).TV.PROMSUM(i))*x_BLEND'); % x_BLEND' = delta tv from tv_n   (Spatial pi included)
    % BSDEL = a*k*(X -[X_neut + Beta*a*delta_X0]);  (a: activation)
    % Beta = (1 + "spatial pi activation");
    % a*delta_X0 = x_BLEND is defined in "make_tvscore.m": delta_X0 = X0-X_neut;
    % can be more intuitively expressed like: X - (Xn + b(X0 - Xn))
    % the bigger beta and the further X0 from Xn, the more exaggerated X is.
    WV4TV = diag(k_BLEND)*BSDEL;
    BSACC = -WV3TV -WV4TV; % task force (tvdotdot)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%% inverse kinematics%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BSACC_tmp = BSACC;
    BSACC_tmp(N_GEST) = zeros(1, length(N_GEST));
    SWV1 = BSACC_tmp-jdotadot;
    JNTACC_ACT= IPJAC*SWV1;
    
    %%%%%%%%%%%%%%%%%%%%  added by HN and ES, Apr 7, 2010
    % this line turns on the jaw's neutral attractor 
    % regardless of associated gestural activation
    % change FREQ(i_JA) to increase the effect
    if flg_jawNeut
        PROM_NEUT(i_JA) = 1;
    end
    %%%%%%%%%%%%%%%%%%%% 
    
    adotdot = JNTACC_ACT + JNTACC_NULL + (PROM_NEUT'.*NEUTACC);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%  added by HN and ES, Apr 7, 2010
    % anatomical constraint (al = stiffness of the constraint)
    if flg_anatom
        dm = 1;  al = 5000; uLim = 1.30; dLim = 1.26;
        if a(i_JA) > uLim
            om = sqrt(al*exp(a(i_JA)-uLim));
            adotdot(i_JA) = adotdot(i_JA) - 2*dm*om*adot(i_JA) - om^2*(a(i_JA)-uLim);
        elseif a(i_JA) < dLim
            om = sqrt(al*exp(a(i_JA)-dLim));
            adotdot(i_JA) = adotdot(i_JA) - 2*dm*om*adot(i_JA) - om^2*(a(i_JA)-dLim);
        else
            adotdot(i_JA) = adotdot(i_JA) - 1*a(i_JA);
        end
    end
    %%%%%%%%%%%%%%%%%%%%

    %%% integrate/Solve/%%%%%%%%%%%%%%%
    [T,Y] = ode45(@t_ode, [0 .005], [a adot], options, adotdot);
    a = Y(end,1:nARTIC)';
    adot = Y(end,nARTIC+1:2*nARTIC)';

    [tv tvdot] = tv_forward(a, adot);

    A = cat(2, A, a);
    ADOT = cat(2, ADOT, adot);

    TV = cat(2,TV, tv);
    TVDOT = cat(2, TVDOT, tvdot);
    waitbar(i/(n_frm-1))
end

%TV(5,:) = A(2,:);    % commented because TV(i_JAW) is Constriction Degree, not angle. 20070619 by HN
TV(6,:) = A(7,:);
TV(7,:) = A(8,:);
TV(11:14,:) = A(11:14,:);

TVDOT(5,:) = ADOT(2,:);
TVDOT(6,:) = ADOT(7,:);
TVDOT(7,:) = ADOT(8,:);
TVDOT(11:14,:) = ADOT(11:14,:);
close(h)

%% a1, adot1 -> forward kinematics(tv = z(a), tvdot = j * adot) -> tv1, tvdot1 -> forward dynamics ->tvdotdot1 -> inverse kinematics -> adotdot1 -> integrate/solve/ -> a2, adot2