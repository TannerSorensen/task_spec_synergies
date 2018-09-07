function [tv, tvdot, j, jdotadot] = TV_FORWARD(a, adot)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%
%TV_FORWARD
%
%	 usage:  [tv, tvdot, j, jdotadot] = TV_FORWARD(a, adot)
%
% input : a - instant articulators
%         adot - instant articulators velocity
% output : tv - instant tract variables
%          tvdot - instant tract variables velocity
%          jdotadot - instant jdot*adot
% see also Make_TV, Make_Artic, Make_Asypel, Make_TVSCORE, Make_Artic_Wag
%
% Notation define
% aaa_bbb(O)(.x/y) (distance(/horizontal/vertical) of aaa to bbb; bbbO : origin)
% ccc(dot/dotdot)_ddd (displacement/velocity/acceleration of ccc at ddd)
% ....


%%%%%%%%%%%%%%%%%%%%%%
% to make it faster than repeated 'load' call&
%%%%%%%%%%%%%%%%%%%%%%
t_params








j = zeros(nTV,nARTIC); % initialize j(acobian)
jdotadot = zeros(nTV,1); % initialize jdotadot
tvdot = zeros(nTV,1); % initialize tvdot
tv = zeros(1, nTV);

%%%%%%%%%%%%%
%          LA LP         %
%%%%%%%%%%%%%

% tv_lip ***************************************************************************************
% 	JACL(2,2)=-ASYPAR(1)*DSIN(X(3))
% 	LVAVP(2)=-ASYPAR(1)*DCOS(X(3))*X(4)**2

condyle_ut.y = CONDYLE_UT.LEN * sin (CONDYLE_UT.ANG);  %jaw-space-vert.-axis coordinate for upper teeth.
ut_lt = condyle_ut.y + CONDYLE_LT.LEN * cos( a(i_JA) ); % distance between the upper & lower teeth.

tv(i_PRO) = a(i_LX);
tv(i_LA) = ut_lt + a(i_UY) - a(i_LY);



% tvdot_lip & j_lip ******************************************************************************

% adot_lip (a * d/dt for lips)
adot_lip= adot([i_LX, i_JA, i_UY, i_LY]);

% j_lip (tv*d/da for lips) 
j_lip (i_LIP_PRO, i_LIP_LX) = 1.0;
j_lip (i_LIP_PRO, i_LIP_JA) = 0.0;
j_lip (i_LIP_PRO, i_LIP_UY) = 0.0;
j_lip (i_LIP_PRO, i_LIP_LY) = 0.0;

j_lip (i_LIP_LA, i_LIP_LX) = 0.0;
j_lip (i_LIP_LA, i_LIP_JA) = -CONDYLE_LT.LEN*sin(a(i_JA));
j_lip (i_LIP_LA, i_LIP_UY) = 1.0;
j_lip (i_LIP_LA, i_LIP_LY) = -1.0;

% tvdot_lip (tv * d/dt for lips)
tvdot_lip = j_lip * adot_lip;

% jdot_lip * adot_lip (j*d/dt * a*d/dt for lips) ****************************************************************************
jdotadot_lip(i_LIP_PRO) = 0.0;
jdotadot_lip(i_LIP_LA) = -CONDYLE_LT.LEN * cos(a(i_JA)) * adot_lip(i_LIP_JA)^2;

% Question: we need better names for TBSPACE_RAD, TB_RAD? comment meaning of these in PARAMETERS.M




%%%%%%%%%%%%%
%          JAW         % added by HN 070613
%%%%%%%%%%%%%
%CONDYLE_LT.LEN*cos(a(i_JA)) + CONDYLE_UT.LEN*cos(-pi/2+CONDYLE_UT.ANG);

tv(i_JAW) = ut_lt;
j(i_JAW, i_JA) = -CONDYLE_LT.LEN*sin(a(i_JA));
tvdot(i_JAW) = j(i_JAW, i_JA) * adot(i_JA);
jdotadot(i_JAW) = -CONDYLE_LT.LEN * cos(a(i_JA)) * adot(i_JA)^2;





%%%%%%%%%%%%%
%      TBCD TBCL    % 
%%%%%%%%%%%%%

% tv_tb *****************************************************************************************

% from model-articulators to jaw-cartesian space
condyle_tb.sin = sin( a(i_JA) + a(i_CA) );
condyle_tb.cos = cos( a(i_JA) + a(i_CA) );
% sin(a(i_JA..)) gets to be x coordinate because a(i_JA) is an angle from vertical but not horiz.

tb_condyleO.x = a(i_CL) * condyle_tb.sin; % jaw-space-horiz.-axis coordinate for tb(tongue-body-center).
tb_condyleO.y = -a(i_CL) * condyle_tb.cos; % jaw-space-vert.-axis coordinate for tb(tongue-body-center).
                                            
% from jaw-cartesian to tongue-body-cartesian space:
tb_floorO_cart.x = tb_condyleO.x - CONDYLE_FLOOR.X;  % horiz. coord. of tb-center in floor origin(tb(cartesian)-space).
tb_floorO_cart.y = tb_condyleO.y - CONDYLE_FLOOR.Y;  % vert. coord. of tb-center in floor origin(tb(cartesian)-space).

% from tongue-body-cartesian to tongue-body-polar space:
tb_floorO_pol.len = sqrt( tb_floorO_cart.x^2 + tb_floorO_cart.y^2 );  % radial coord. for tb-center in tb(polar)-space.                                                                            
tb_floorO_pol.ang = acos( tb_floorO_cart.x / tb_floorO_pol.len );  % angular coord. for tb-center in tb(polar)-space; corresponds (roughly) to tb-constricton-location

% from tongue-body-polar to tract-variable space.
tv(i_TBCL) = tb_floorO_pol.ang;
tv(i_TBCD) = TBSPACE_RAD - ( tb_floorO_pol.len + TB_RAD ); % corresponds(roughly) to constricton-degree; ie., radial distance through tb-center in tb(polar)-space from tb-"dorsum" to upper/back tract wall.
% Question: we need better names for TBSPACE_RAD, TB_RAD? comment meaning

% tvdot_tb & j_tb ********************************************************************************
% 
% Note: I am summarizing how to get tvdot for tb.
%
% (1) tb_condyle_dot = j_tb_condyleO * adot_tb
% (2) tb_floorO_cart_dot ( = (1) )
% (3) tb_floorO_pol_dot = invel_pol2cart_tb * tb_floorO_cart_dot (derived by the equation vel_cart2pol* tb_floorO_pol_dot = tb_floorO_cart_dot)
% (4) tvdot_tb = vel_pol2tv_tb * tb_floorO_pol_dot
%
% in sum : adot_tb -> tvdot_tb (by total jacobian for tb : vel_pol2tv_tb * invel_pol2cart_tb * j_tb_condyleO)

% adot_tb (a * d/dt for tb)
adot_tb = adot([i_JA, i_CL, i_CA]);

% jacobian matrix of the direct transform from model-articulators to jaw-cartesian space for tongue body:
j_tb_condyleO(1, 1) = -tb_condyleO.y;
j_tb_condyleO(1, 2) = condyle_tb.sin;
j_tb_condyleO(1, 3) = j_tb_condyleO(1,1);
j_tb_condyleO(2, 1) =  tb_condyleO.x;
j_tb_condyleO(2, 2) = -condyle_tb.cos;
j_tb_condyleO(2, 3) = j_tb_condyleO(2,1);

% tb_condyleO_dot (tb_condyleO * d/dt)
tb_condyleO_dot = j_tb_condyleO * adot_tb;

% tb_floorO_cart_dot (tb_floorO_cart * d/dt)
tb_floorO_cart_dot = tb_condyleO_dot;

% vel_pol2cart_tb (vel_pol2cart_tb * tb_floorO_pol_dot = tb_floorO_cart_dot)  matrix of velocity transform from polar to jaw-cartesian for tb.
vel_pol2cart_tb(1,i_TB_TBCL) = -tb_floorO_pol.len * sin( tb_floorO_pol.ang );
vel_pol2cart_tb(1,i_TB_TBCD) = cos( tb_floorO_pol.ang );
vel_pol2cart_tb(2,i_TB_TBCL) =  tb_floorO_pol.len * cos( tb_floorO_pol.ang );
vel_pol2cart_tb(2,i_TB_TBCD) = sin( tb_floorO_pol.ang );

% inverse matrix of vel_pol2cart_tb
%invel_pol2cart_tb = inv(vel_pol2cart_tb);
invel_pol2cart_tb(i_TB_TBCL,1) = -sin(tb_floorO_pol.ang)/tb_floorO_pol.len;
invel_pol2cart_tb(i_TB_TBCL,2) =  cos(tb_floorO_pol.ang)/tb_floorO_pol.len;
invel_pol2cart_tb(i_TB_TBCD,1) =  cos(tb_floorO_pol.ang);
invel_pol2cart_tb(i_TB_TBCD,2) =  sin(tb_floorO_pol.ang);

% tb_floorO_pol_dot (tb_floorO_pol * d/dt)
tb_floorO_pol_dot =  invel_pol2cart_tb * tb_floorO_cart_dot;

% vel_pol2tv_tb (tvdot_tb = vel_pol2tv_tb * tb_floorO_pol_dot)  matrix of velocity transform from polar to tract variables for tb.
vel_pol2tv_tb(i_TB_TBCL,i_TB_TBCL) = 1;
vel_pol2tv_tb(i_TB_TBCL,i_TB_TBCD) = 0;
vel_pol2tv_tb(i_TB_TBCD,i_TB_TBCL) = 0;
vel_pol2tv_tb(i_TB_TBCD,i_TB_TBCD) = -1;

% total jacobian for tb
j_tb = vel_pol2tv_tb * invel_pol2cart_tb * j_tb_condyleO;

% tvdot_tb (tv * d/dt for tb)
tvdot_tb = j_tb * adot_tb;


% jdot * adot for tb ^****************************************************************************

% derivative (d/dt) of invel_pol2cart_tb
invel_pol2cart_tb_dot (i_TB_TBCL, 1) = sin(tb_floorO_pol.ang) * tb_floorO_pol_dot(2)/ tb_floorO_pol.len^2 -  cos(tb_floorO_pol.ang) * tb_floorO_pol_dot(1) / tb_floorO_pol.len;
invel_pol2cart_tb_dot (i_TB_TBCL, 2) = - cos(tb_floorO_pol.ang) * tb_floorO_pol_dot(2)/ tb_floorO_pol.len^2 - sin(tb_floorO_pol.ang) * tb_floorO_pol_dot(1) / tb_floorO_pol.len;
invel_pol2cart_tb_dot (i_TB_TBCD, 1) = -sin(tb_floorO_pol.ang) * tb_floorO_pol_dot(1);
invel_pol2cart_tb_dot (i_TB_TBCD, 2) = cos(tb_floorO_pol.ang) * tb_floorO_pol_dot(1);


% derivative of j_tb_condyleO with repect to a(rticulators)
jdota_tb_condyleO (i_TB_TBCL, 1) = -tb_condyleO.x;
jdota_tb_condyleO (i_TB_TBCL, 2) = 2*condyle_tb.cos;
jdota_tb_condyleO (i_TB_TBCL, 3) = 2*jdota_tb_condyleO(i_TB_TBCL,1);
jdota_tb_condyleO (i_TB_TBCL, 4) = 0.0;
jdota_tb_condyleO (i_TB_TBCL, 5) = jdota_tb_condyleO(i_TB_TBCL,2);
jdota_tb_condyleO (i_TB_TBCL, 6) = jdota_tb_condyleO(i_TB_TBCL,1);

jdota_tb_condyleO (i_TB_TBCD,1) = -tb_condyleO.y;
jdota_tb_condyleO (i_TB_TBCD,2) = 2*condyle_tb.sin;
jdota_tb_condyleO (i_TB_TBCD,3) = 2*jdota_tb_condyleO(i_TB_TBCD,1);
jdota_tb_condyleO (i_TB_TBCD,4) = 0.0;
jdota_tb_condyleO (i_TB_TBCD,5) = jdota_tb_condyleO(i_TB_TBCD,2);
jdota_tb_condyleO (i_TB_TBCD,6) = jdota_tb_condyleO(i_TB_TBCD,1);

% cross products of adot
adot_tb_pro(1)= adot(i_JA)^2;
adot_tb_pro(2)= adot(i_JA)*adot(i_CL);
adot_tb_pro(3)= adot(i_JA)*adot(i_CA);
adot_tb_pro(4)= adot(i_CL)^2;
adot_tb_pro(5)= adot(i_CL)*adot(i_CA);
adot_tb_pro(6)= adot(i_CA)^2;

adot_tb_pro = adot_tb_pro'; % row vector to column one
    
% jdot_tb * adot_tb (j*d/dt * a*d/dt for tb) ****************************************************************************
%
%                       jdot_tb = (j_tb)d/dt = (vel_pol2tv_tb)d/dt (-->0) * invel_pol2cart_tb * j_tb_condyleO
%                                                   + vel_pol2tv_tb * (invel_pol2cart_tb)d/dt * j_tb_condyleO
%                                                   + vel_pol2tv_tb * invel_pol2cart_tb * (j_tb_condyleO)d/dt (<-- (j_tb_condyleO)d/da * (a)d/dt) )



jdotadot_tb = vel_pol2tv_tb * invel_pol2cart_tb_dot * tb_condyleO_dot...  % tb_condyleO_dot = j_tb_condyleO * adot
                 + vel_pol2tv_tb * invel_pol2cart_tb * jdota_tb_condyleO * adot_tb_pro; % jdota_tb_condyleO * adot_tb = j_tb_condyleO * d/dt


%%%%%%%%%%%%%
%     TTCL TTCD     %
%%%%%%%%%%%%%


% from model-articulators to jaw-cartesian space
tb_ttO.sin = sin ( a(i_JA) + TCTTO_ANG );
tb_ttO.cos = cos ( a(i_JA) + TCTTO_ANG );

ttO_condyleO.x = tb_condyleO.x + TB_RAD * tb_ttO.sin; % jaw-space-horiz.-axis coordinate for tongue-body-center.
ttO_condyleO.y = tb_condyleO.y - TB_RAD * tb_ttO.cos; % jaw-space-vert.-axis coordinate for tongue-body-center.

% tv(i_TTCR)
tv(i_TTCR) =   a(i_JA) + a(i_TA) +TBTT_SCL*(a(i_CL) - TBTT_LINK);

ttcr_sin = sin ( tv(i_TTCR) );
ttcr_cos = cos ( tv(i_TTCR) );

tt_condyleO.x = ttO_condyleO.x + a(i_TL) * ttcr_sin;
tt_condyleO.y = ttO_condyleO.y - a(i_TL) * ttcr_cos;

tt_tbO.x = tt_condyleO.x - CONDYLE_FLOOR.X;
tt_tbO.y = tt_condyleO.y - CONDYLE_FLOOR.Y;

tt2tbO_rad = sqrt( tt_tbO.x^2 + tt_tbO.y^2 );
tt2tbO_ang = acos( tt_tbO.x / tt2tbO_rad );

% tv(i_TTCL) & tv(i_TTCD) 
tv(i_TTCL) = tt2tbO_ang;
tv(i_TTCD) = TBSPACE_RAD - tt2tbO_rad;

%==========================================================

%	2.A. TONGUE-TIP: ARTIC TO JAW-XY JACOBIAN.


	TTART_JXY(1,1) = j_tb_condyleO(1,1) + TB_RAD*tb_ttO.cos + a(i_TL)*ttcr_cos;
	TTART_JXY(1,2) = j_tb_condyleO(1,2) + TBTT_SCL*a(i_TL)*ttcr_cos;
	TTART_JXY(1,3) = j_tb_condyleO(1,3);
	TTART_JXY(1,4) = ttcr_sin;
	TTART_JXY(1,5) = a(i_TL)*ttcr_cos;

	TTART_JXY(2,1) = j_tb_condyleO(2,1) + TB_RAD*tb_ttO.sin + a(i_TL)*ttcr_sin;
	TTART_JXY(2,2) = j_tb_condyleO(2,2) + TBTT_SCL*a(i_TL)*ttcr_sin;
	TTART_JXY(2,3) = j_tb_condyleO(2,3);
	TTART_JXY(2,4) = - ttcr_cos;
	TTART_JXY(2,5) = a(i_TL)*ttcr_sin;

%	2.B. TONGUE-TIP: (D/DT) (TTART_JXY).
% here condyle_tb.cos/sin is substitution for tc_cos/sin( each 2) (What tc_cos/sin in Eliot's?)...
% 현재 LG가 type out 해보니까, tc_cos = 0; tc_sin = 0; 로 나타남...

	DERIV_TTART_JXY(1,1) = adot(i_JA) * ( -TTART_JXY(2,1) ) + adot(i_CL) * ( -TTART_JXY(2,2) ) + adot(i_CA) * ( -TTART_JXY(2,3) ) + adot(i_TL) * ( -TTART_JXY(2,4) ) + adot(i_TA) * ( -TTART_JXY(2,5) );
    DERIV_TTART_JXY(1,2) = adot(i_JA) * ( -TTART_JXY(2,2) )	+ adot(i_CL) * ( -TBTT_SCL*TBTT_SCL*TTART_JXY(2,5) ) + adot(i_CA) * ( condyle_tb.cos ) + adot(i_TL) * ( TBTT_SCL*ttcr_cos ) + adot(i_TA) * ( -TBTT_SCL*TTART_JXY(2,5) );
    DERIV_TTART_JXY(1,3) = adot(i_JA) * ( -TTART_JXY(2,3) )	+ adot(i_CL) * ( condyle_tb.cos ) + adot(i_CA) * ( -TTART_JXY(2,3) );
    DERIV_TTART_JXY(1,4) = adot(i_JA) * ( ttcr_cos ) + adot(i_CL) * ( TBTT_SCL*ttcr_cos ) + adot(i_TA) * ( ttcr_cos );
    DERIV_TTART_JXY(1,5) = adot(i_JA) * ( -TTART_JXY(2,5) )	+ adot(i_CL) * ( -TBTT_SCL*TTART_JXY(2,5) ) + adot(i_TL) * ( ttcr_cos ) + adot(i_TA) * ( -TTART_JXY(2,5) );
    
    DERIV_TTART_JXY(2,1) = adot(i_JA) * ( TTART_JXY(1,1) ) + adot(i_CL) * ( TTART_JXY(1,2) )	+ adot(i_CA) * ( TTART_JXY(1,3) ) + adot(i_TL) * ( TTART_JXY(1,4) ) + adot(i_TA) * ( TTART_JXY(1,5) );
	DERIV_TTART_JXY(2,2) = adot(i_JA) * ( TTART_JXY(1,2) ) + adot(i_CL) * ( TBTT_SCL*TBTT_SCL*TTART_JXY(1,5) ) + adot(i_CA) * ( condyle_tb.sin ) + adot(i_TL) * ( TBTT_SCL*ttcr_sin )	+ adot(i_TA) * ( TBTT_SCL*TTART_JXY(1,5) );
    DERIV_TTART_JXY(2,3) = adot(i_JA) * ( TTART_JXY(1,3) ) + adot(i_CL) * ( condyle_tb.sin ) + adot(i_CA) * ( TTART_JXY(1,3) );
    DERIV_TTART_JXY(2,4) = adot(i_JA) * ( ttcr_sin ) + adot(i_CL) * ( TBTT_SCL*ttcr_sin ) + adot(i_TA) * ( ttcr_sin );
	DERIV_TTART_JXY(2,5) = adot(i_JA) * ( TTART_JXY(1,5) ) + adot(i_CL) * ( TBTT_SCL*TTART_JXY(1,5) ) + adot(i_TL) * ( ttcr_sin ) + adot(i_TA) * ( TTART_JXY(1,5) );

%   C	COMPUTE TOTAL JACOBIAN (MODEL ARTIC. TO TRACT-VARIABLES):
%	2.	TONGUE TIP:

%	2.A.1	TT-JACOBIAN FOR ROWS TTCL & TTCD.
    TT_VELMATX(1,1) = -tt2tbO_rad * sin( tt2tbO_ang );
	TT_VELMATX(1,2) = cos( tt2tbO_ang );
	TT_VELMATX(2,1) =  tt2tbO_rad * cos( tt2tbO_ang );
	TT_VELMATX(2,2) = sin( tt2tbO_ang );

TT_INVELMATX = inv(TT_VELMATX);

TT_VEL_TEM = vel_pol2tv_tb * TT_INVELMATX;

JACTT_POS = TT_VEL_TEM * TTART_JXY;

%	2.A.2	TT-JACOBIAN FOR ROW TTCR.
	JACTT_OA(1,1) = 1.0;
	JACTT_OA(1,2) = TBTT_SCL;
	JACTT_OA(1,3) = 0.0;
	JACTT_OA(1,4) = 0.0;
	JACTT_OA(1,5) = 1.0;

%	2.A.3	FULL TT-JACOBIAN.
j_tt = [JACTT_POS;JACTT_OA];

%	2.B. TT-VELOCITY VECTORS.
adot_tt = adot([i_JA, i_CL, i_CA, i_TL, i_TA]);
tvdot_tt =  j_tt * adot_tt;


%	2.C. TT: TTAVP
%	DEFINE (D/DT)(TT_INVELMATX):
	TT_DERIV_INVEL(1,1) = ( sin(tt2tbO_ang) * (-tvdot_tt(i_TT_TTCD))/ tt2tbO_rad^2 ) - ( cos(tt2tbO_ang) * tvdot_tt(i_TT_TTCL) / tt2tbO_rad );
	TT_DERIV_INVEL(1,2) = - ( cos(tt2tbO_ang) * (-tvdot_tt(i_TT_TTCD))/ tt2tbO_rad^2 ) - ( sin(tt2tbO_ang) * tvdot_tt(i_TT_TTCL) / tt2tbO_rad );
	TT_DERIV_INVEL(2,1) = - sin(tt2tbO_ang) * tvdot_tt(i_TT_TTCL);
	TT_DERIV_INVEL(2,2) =  cos(tt2tbO_ang) * tvdot_tt(i_TT_TTCL);

WM1TT = vel_pol2tv_tb * TT_DERIV_INVEL;

DERIV_WM1TT = WM1TT * TTART_JXY;

DERIV_WM2TT = TT_VEL_TEM * DERIV_TTART_JXY;
DERIV_WM3TT = DERIV_WM1TT + DERIV_WM2TT;
TTAVP_POS = DERIV_WM3TT * adot_tt;

TTAVP = TTAVP_POS;
TTAVP(3) = 0.0;	%! BY INSPECTION, SINCE CORRESPONDING ELEMENTS OF j_tt-ROW#3 ARE CONSTANTS.

jdotadot_tt = TTAVP;



% ===============================================================================================

tv = tv'; % row vector to column one

%***************************************** (integrating tvdot)
tvdot (i_LIP_TV) = tvdot_lip;
tvdot (i_TB_TV) = tvdot_tb;
tvdot (i_TT_TV) = tvdot_tt;

%***************************************** (integration into complete jacobian)
j (i_LIP_TV, i_LIP_A) = j_lip;
j (i_TB_TV, i_TB_A) = j_tb;
j (i_TT_TV, i_TT_A) = j_tt;
%***************************************** (integration into complete jdot*adot)
jdotadot (i_LIP_TV) = jdotadot_lip;
jdotadot (i_TB_TV) = jdotadot_tb;
jdotadot (i_TT_TV) = jdotadot_tt;

j = j ([1 2 3 4 5 6 7 8 9 10 11 12 13 14],:);