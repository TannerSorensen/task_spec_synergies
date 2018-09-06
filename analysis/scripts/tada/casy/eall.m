function eall

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global FIX_Larynx 
global FIX_Periarytenoid 
global FIX_PharynxLo 
global FIX_PharynxHi 
global FIX_Velum 
global FIX_VelMax 
global FIX_Maxilla 
global FIX_Alveolus 
global FIX_Teeth 
global FIX_TeethLip 
global FIX_Lip 
global FIX_Terminus 
global VAR_Larynx 
global VAR_LarEpi
global VAR_Epiglottis 
global VAR_Hyoid
global VAR_Root 
global VAR_RootTong 
global VAR_TongBlade 
global VAR_BladeTip 
global VAR_TipFloor 
global VAR_Floor 
global VAR_FloorTeeth 
global VAR_Teeth 
global VAR_TeethLip 
global VAR_Lip 
global VAR_Terminus 
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
global GEO_Condyle 
global GEO_FixTerminus 
global GEO_VarTerminus 
global GEO_Velum 
global GEO_Hyoid2Epi 
global GEO_Hyoid2LarEpiY 
global GEO_Hyoid2LarynxY 
global GEO_Teeth2FloorTeeth 
global GEO_FixTeeth2TeethLip 
global GEO_VarTeeth2TeethLip 
global GEO_Teeth2FloorX 
global GEO_BladeOrigin  
global GEO_TipCircleRad  
global CMP_BladeOrigin  
global CMP_BladeCircle  
global CMP_BladeCircleRad 
global CMP_TongBlade 
global CMP_FrontFactor 
global CMP_Floor2Teeth 
global CMP_TipCircle 
global CMP_TipTracking 
global CMP_Root 
global CMP_HyoidTongTan 
global CMP_TongueCircle 
global CMP_Velum 
global TUN_LarEpiY 
global TUN_VarLarynxX 
global TUN_FrontFactor 
global TUN_TipTracking  % linearise transform coord/length t-> angle
global TUN_Root 
global TUN_FloorX 
global TUN_GridCenter 
global TUN_PharAdjGlot 
global TUN_PharAdjPeri 
global TUN_PharAdjHyoid 
global TUN_PharAdjRoot 
global TUN_LipWidth 
global TUN_SoftPalate 
global TUN_HardPalate 
global TUN_AlvNarrow 
global TUN_AlvMid 
global TUN_AlvWide 
global SRC_F0 
global SRC_OpenQuotient 
global SRC_SpeedQuotient 
global SRC_SourceAmp 
global SRC_FricAmp 
global SRC_FricLoc 
global SRC_GlotWidth 
global SRC_GlotTens 
global SRC_SubGlotP 

%  ============================================================================
%    EVAL_CMP_FLOOR2TEETH (THV):  angle above jaw angle KEY_JAW (THJ) to
%		    intersection of lower teeth/gum line with floor of mouth
%  ============================================================================


% void eval_cmp_Floor2Teeth()
% {
%   CMP_Floor2Teeth.polar.ang = KEY_Jaw.polar.ang + 
%                               GEO_Teeth2FloorTeeth.polar.ang;
% 
% }

CMP_Floor2Teeth(4) = KEY_Jaw(4) + GEO_Teeth2FloorTeeth(4);


%  ============================================================================
%    EVAL_CMP_TONGUECIRCLE (C):  center of tongue ball circle
%  ============================================================================


% void eval_cmp_TongueCircle()
% {
%   double a;
% 
%   a = KEY_TongueCircle.polar.ang + KEY_Jaw.polar.ang;
%   CMP_TongueCircle.coord.x = GEO_Condyle.coord.x + 
%                              KEY_TongueCircle.polar.len * cos( a );
%   CMP_TongueCircle.coord.y = GEO_Condyle.coord.y + 
%                              KEY_TongueCircle.polar.len * sin( a );
% 
% }

a = KEY_TongueCircle(4) + KEY_Jaw(4);
CMP_TongueCircle(1:2) = GEO_Condyle(1:2) + ...
    KEY_TongueCircle(3) * [ cos(a) sin(a) ];



%  /*
%    ============================================================================
%      EVAL_FIX_VELUM (5)  - position of velum

%      When computed by the model, FIX and CMP Velum are the same point, 
%      determined by an offset of KEY_Nasal*GEO_Veluum.polar.len
%      along velum declination angle GEO_Velum.polar.ang.  
%      If FIX_Velum is positioned interactively, CMP_Velum represents the 
%      model's best fit to the specified position.
%    ============================================================================
%  */

%  void eval_fix_Velum() 
%  {
%    double len;

%    len = sqrt( KEY_Nasal.polar.len ) * GEO_Velum.polar.len;
%    CMP_Velum.coord.x = FIX_Velum.coord.x = 
%         FIX_PharynxHi.coord.x + len * cos(DEG2RAD(GEO_Velum.polar.ang));
%    CMP_Velum.coord.y = FIX_Velum.coord.y = 
%         FIX_PharynxHi.coord.y - len * sin(DEG2RAD(GEO_Velum.polar.ang));
%  }


% !!!! very strange ????


len = sqrt( KEY_Nasal(3) ) * GEO_Velum(3); % possible second mult must be in sqrt?
FIX_Velum(1:2) = FIX_PharynxHi(1:2) + ...
                  len * [ cos(GEO_Velum(4)) sin( GEO_Velum(4)) ];
            
CMP_Velum(1:2) = FIX_Velum(1:2);

GEO_Velum(1:2) = FIX_PharynxHi(1:2) + GEO_Velum(3) * [ cos( GEO_Velum(4) ) sin( GEO_Velum(4) ) ];


%  /*
%    ============================================================================
%      EVAL_FIX_LIP (10):  outer edge of upper lip
%    ============================================================================
%  */

%  void eval_fix_Lip() 
%  {

%    FIX_Lip.coord.x = FIX_Teeth.coord.x + KEY_FixLip.coord.x + KEY_VarLip.coord.x;
%    FIX_Lip.coord.y = FIX_Teeth.coord.y - KEY_FixLip.coord.y - KEY_VarLip.coord.y;

%    straight_seg( & SEG_FIX_Lip_Terminus );
%  } 

% modified by HN (not to let the upper and lower lips yoked)
FIX_Lip = FIX_Teeth + ...
  [ (KEY_FixLip(1) + KEY_VarLip(1) )  (KEY_FixLip(2))]; % - KEY_VarLip(2) ) ];


%  /*
%    ============================================================================
%      EVAL_FIX_TERMINUS (11):  upper tube termination
%    ============================================================================
%  */

%  void eval_fix_Terminus() 
%  {
%    FIX_Terminus.coord.x = FIX_Lip.coord.x + 
%                           GEO_FixTerminus.polar.len * 
%                             cos( GEO_FixTerminus.polar.ang );
%    FIX_Terminus.coord.y = FIX_Lip.coord.y + 
%                           GEO_FixTerminus.polar.len * 
%                             sin( GEO_FixTerminus.polar.ang );

%    straight_seg( & SEG_FIX_Lip_Terminus );
%  } 

FIX_Terminus = FIX_Lip + ...
   GEO_FixTerminus(3) * [ cos( GEO_FixTerminus(4) ) sin( GEO_FixTerminus(4) ) ];


%  /*
%    ============================================================================
%      EVAL_VAR_HYOID (4,P):  anterior end of tongue root at height
%  			     of hyoid (valecula).  
%      X:  KEY_Hyoid
%      Y:  KEY_Hyoid
%    ============================================================================
%  */

%  void eval_var_Hyoid() 
%  {

%    VAR_Hyoid.coord.x = KEY_Hyoid.coord.x;
%    VAR_Hyoid.coord.y = KEY_Hyoid.coord.y;

%  } /* eval_var_Hyoid */


VAR_Hyoid(1:2) = KEY_Hyoid(1:2);





%  /* 
%    ============================================================================
%      EVAL_VAR_TEETH (13, LJ):  position of lower teeth

%      Distance KEY_Jaw.polar.len (RJ) from GEO_Condyle 
%      at angle KEY_Jaw.polar.ang (THJ)
%    ============================================================================
%  */

%  void eval_var_Teeth() 
%  {

%    VAR_Teeth.coord.x = GEO_Condyle.coord.x + 
%                        KEY_Jaw.polar.len * cos( KEY_Jaw.polar.ang );
%    VAR_Teeth.coord.y = GEO_Condyle.coord.y + 
%                        KEY_Jaw.polar.len * sin( KEY_Jaw.polar.ang );

%  } /* eval_var_Teeth */


VAR_Teeth(1:2) = GEO_Condyle(1:2) + ...
                 KEY_Jaw(3) * [ cos( KEY_Jaw(4) )   sin( KEY_Jaw(4) ) ]; 


             
%  /* 
%    ============================================================================
%      EVAL_VAR_LIP (15):  lower lip

%      X: KEY_VarLip.coord.x right of VAR_Teeth, plus KEY_VarLip.coord.y 
%              if positive
%      Y: VAR_Teeth offset by KEY_VarLip.coord.y
%    ============================================================================
%  */

%  void eval_var_Lip() 
%  {

%    VAR_Lip.coord.x = VAR_Teeth.coord.x + KEY_VarLip.coord.x;
%    VAR_Lip.coord.y = VAR_Teeth.coord.y + KEY_VarLip.coord.y;
%    if (KEY_VarLip.coord.y > 0.)	/* HLJ > 0 */
%      VAR_TeethLip.coord.x += KEY_VarLip.coord.y;

%  } /* eval_var_Lip */

VAR_Lip(1:2) = VAR_Teeth(1:2) + KEY_VarLip(1:2);
if( KEY_VarLip(2) > 0 )
    VAR_TeethLip(1) = VAR_TeethLip(1) + KEY_VarLip(2);
end

%  /* 
%    ============================================================================
%      EVAL_VAR_TERMINUS (16):  tube termination

%      GEO_VarTerminus.polar.len right of VAR_Lip 
%      along angle GEO_VarTerminus.polar.ang
%    ============================================================================
%  */

%  void eval_var_Terminus() 
%  {

%    VAR_Terminus.coord.x = VAR_Lip.coord.x + 
%                           GEO_VarTerminus.polar.len * 
%                             cos( GEO_VarTerminus.polar.ang );
%    VAR_Terminus.coord.y = VAR_Lip.coord.y + 
%                           GEO_VarTerminus.polar.len * 
%                             sin( GEO_VarTerminus.polar.ang );

%  } /* eval_var_Terminus */

VAR_Terminus(1:2) = VAR_Lip(1:2) + ... 
    GEO_VarTerminus(3) * [ cos( GEO_VarTerminus(4) )   sin( GEO_VarTerminus(4) ) ];


%  ============================================================================
%    EVAL_CMP_BLADEORIGIN (B):  origin of tongue tip segment on tongue circle:
%				the actual point of departure from the tongue
%    ball surface (i.e. VAR_TongBlade or B') rotates around this point as 
%    a function of tongue tip height.  CMP_BladeOrigin is the intersection
%    of a line drawn from the tongue ball center (CMP_TongueCircle) to its
%    circumference at an angle of KEY_Jaw.polar.ang (THJ) plus 
%    GEO_BladeOrigin.polar.ang (.55pi) plus KEY_BladeOriginOffset.polar.ang 
%    with respect to the horizontal.
%  ============================================================================


% void eval_cmp_BladeOrigin()
% {
%   double a;
% 
%   a = KEY_Jaw.polar.ang + GEO_BladeOrigin.polar.ang + 
%       KEY_BladeOriginOffset.polar.ang;
%   CMP_BladeOrigin.coord.x = CMP_TongueCircle.coord.x + 
%                       KEY_TongueCircleRad.polar.len * cos( a );
%   CMP_BladeOrigin.coord.y = CMP_TongueCircle.coord.y + 
%                       KEY_TongueCircleRad.polar.len * sin( a );
% 
% }

a = KEY_Jaw(4) + GEO_BladeOrigin(4) + KEY_BladeOriginOffset(4);
CMP_BladeOrigin = CMP_TongueCircle + KEY_TongueCircleRad(3) * [ cos( a ) sin( a ) ];



%  ============================================================================
%    EVAL_CMP_TIPTRACKING (THTC):  tongue ball center contribution to 
%				   tongue tip angle.  Proportional to the
%    difference between KEY_TongueCircle.polar.len (SC) 
%    and TUN_TipTracking.offset
%    Given the current tuning parameters, the most negative tongue center
%    contribution is -27 degrees for SC <= 830, and the least negative
%    contribution is -9 degrees for SC >= 910
%  ============================================================================


% void eval_cmp_TipTracking()
% {
%   TPARAM *p;
%   double len;
% 
%   p = ( TPARAM * )  & TUN_TipTracking;	/* map tuning param args */
%   len = MAX( KEY_TongueCircle.polar.len, p->minx.min );
%   len = MIN( len, p->minx.max );
%   CMP_TipTracking.polar.ang = (len + p->osl.offset) * p->osl.scale;
% 
% }


% TUN_TipTracking = [830/11.2  910/11.2  -950/11.2  0.004*11.2]; from init.m by HN
% commented by HN
%len = min( max( KEY_TongueCircle(3), TUN_TipTracking(1) ), TUN_TipTracking(2) );
len = KEY_TongueCircle(3);
CMP_TipTracking(4) = ( len + TUN_TipTracking(3) ) * TUN_TipTracking(4); 




%  ============================================================================
%    EVAL_CMP_HYOIDTONGTAN (T):  intersection of tongue body circle with
%				 tangent from VAR_Hyoid (P)
%  ============================================================================


% void eval_cmp_HyoidTongTan()
% {
%   double PT, a, a1, a2, dx, dy;
% 
%   dx = VAR_Hyoid.coord.x - CMP_TongueCircle.coord.x;
%   dy = VAR_Hyoid.coord.y - CMP_TongueCircle.coord.y;
% 
%   PT = dx * dx  +  dy * dy - 
%              KEY_TongueCircleRad.polar.len * KEY_TongueCircleRad.polar.len;
% 
%   % check for error 
%   PT = PT > 0.0       ?  
%          sqrt( PT ) :
%          0.0;          /* ??? plug ??? */
% 
%   a1 = dx ? atan2(dy, dx) : PIdiv2;
%   a2 = KEY_TongueCircleRad.polar.len ? 
%        atan2(PT, KEY_TongueCircleRad.polar.len) : 
%        PIdiv2;
%   a  = a1 - a2;
% 
%   CMP_HyoidTongTan.coord.x = CMP_TongueCircle.coord.x + 
%                              KEY_TongueCircleRad.polar.len * cos( a );
%   CMP_HyoidTongTan.coord.y = CMP_TongueCircle.coord.y + 
%                              KEY_TongueCircleRad.polar.len * sin( a );
% 
% }

d(1:2) = VAR_Hyoid(1:2) - CMP_TongueCircle(1:2);
PT = sqrt( d*d' - KEY_TongueCircleRad(3)^2 );
a = atan2( d(2), d(1) ) - atan2( PT, KEY_TongueCircleRad(3) );
CMP_HyoidTongTan(1:2) = CMP_TongueCircle(1:2) + ...
    KEY_TongueCircleRad(3) * [ cos(a) sin(a) ];



%  /*
%    ============================================================================
%      EVAL_FIX_TEETHLIP (9):  intersection of upper teeth and upper lip
%    ============================================================================
%  */

%  void eval_fix_TeethLip() 
%  {

%    FIX_TeethLip.coord.x = FIX_Teeth.coord.x + GEO_FixTeeth2TeethLip.polar.len;
%    FIX_TeethLip.coord.y = FIX_Lip.coord.y; 
  
%    straight_seg( & SEG_FIX_Teeth_TeethLip );
%    straight_seg( & SEG_FIX_TeethLip_Lip );
%  } 


FIX_TeethLip(1:2) = [ FIX_Teeth(1) + GEO_FixTeeth2TeethLip(3) FIX_Lip(2) ];




%  /*
%    ============================================================================
%      EVAL_VAR_LARYNX (1):  anterior edge of larynx

%      X:  related (by tuning function) to movement of VAR_Hyoid
%      Y:  down from VAR_Hyoid by GEO_Hyoid2LarynxY

%      The horizontal position of VAR_Hyoid is compared to a point determined
%      by FIX_PharynxLo.coord.x and TUN_VarLarynxX.minx.max. The scaled 
%      ( TUN_VarLarynxX.osl.scale )
%      difference is used as an offset from the point determined by 
%      FIX_Periarytenoid.coord.x and TUN_VarLarynX.osl.offset.
%    ============================================================================
%  */

%  void eval_var_Larynx() 
%  {
%    TPARAM *p;

%    p = (TPARAM *)&TUN_VarLarynxX;	/* map tuning param args */
%    VAR_Larynx.coord.x = FIX_Periarytenoid.coord.x + p->osl.offset + 
%  	               ( VAR_Hyoid.coord.x - ( FIX_PharynxLo.coord.x + 
%                                                 p->minx.max )
%                         ) * p->osl.scale;
%    VAR_Larynx.coord.y = VAR_Hyoid.coord.y - GEO_Hyoid2LarynxY.polar.len;

%  } /* eval_var_Larynx */


VAR_Larynx(1:2) = [ FIX_Periarytenoid(1) + TUN_VarLarynxX(3) + ...
 	                ( VAR_Hyoid(1) - FIX_PharynxLo(1) - TUN_VarLarynxX(2) ) ...                                                
                          * TUN_VarLarynxX(4) ...
                     VAR_Hyoid(2) - GEO_Hyoid2LarynxY(3) ];


             




             %  /*
%    ============================================================================
%      EVAL_VAR_EPIGLOTTIS (3):  anterior edge (effective top) of epiglottis

%      X:  GEO_Hyoid2Epi left of VAR_Hyoid
%      Y:  same as VAR_Hyoid
%    ============================================================================
%  */

%  void eval_var_Epiglottis() 
%  {

%  /* ***  Compute parameter  *** */
 
%    VAR_Epiglottis.coord.x = VAR_Hyoid.coord.x - GEO_Hyoid2Epi.coord.x;
%    VAR_Epiglottis.coord.y = VAR_Hyoid.coord.y + GEO_Hyoid2Epi.coord.y;

%  } /* eval_var_Epiglottis */


VAR_Epiglottis(1:2) = VAR_Hyoid(1:2) + [ -GEO_Hyoid2Epi(1) GEO_Hyoid2Epi(2) ];




%  /* 
%    ============================================================================
%      EVAL_VAR_FLOORTEETH (12, V):  intersection of lower teeth/gum line with
%  				   floor of mouth

%      GEO_Floor2Teeth.polar.len back from VAR_Teeth along angle CMP_Floor2Teeth 
%      (THV)
%    ============================================================================
%  */

%  void eval_var_FloorTeeth() 
%  {
%    VAR_FloorTeeth.coord.x = VAR_Teeth.coord.x - 
%                             GEO_Teeth2FloorTeeth.polar.len *
%                               cos(CMP_Floor2Teeth.polar.ang);
%    VAR_FloorTeeth.coord.y = VAR_Teeth.coord.y - 
%                             GEO_Teeth2FloorTeeth.polar.len * 
%                               sin(CMP_Floor2Teeth.polar.ang);
  
%  } /* eval_var_FloorTeeth */



VAR_FloorTeeth(1:2) = VAR_Teeth(1:2) - ...
                       GEO_Teeth2FloorTeeth(3) * ...
                          [ cos( CMP_Floor2Teeth(4) )  sin( CMP_Floor2Teeth(4) ) ];


                      
                      
%  /* 
%    ============================================================================
%      EVAL_VAR_TEETHLIP (14):  intersection of lower lip with lower teeth

%      X: GEO_VarTeeth2TeethLip right of VAR_Teeth
%      Y: VAR_Lip.coord.y
%    ============================================================================
%  */

%  void eval_var_TeethLip() 
%  {

%    VAR_TeethLip.coord.x = VAR_Teeth.coord.x + GEO_VarTeeth2TeethLip.polar.len;
%    VAR_TeethLip.coord.y = VAR_Lip.coord.y;

%  } /* eval_var_TeethLip */

VAR_TeethLip(1:2) = [ VAR_Teeth(1) + GEO_VarTeeth2TeethLip(3)    VAR_Lip(2) ];


                      
%  ============================================================================
%    EVAL_CMP_TIPCIRCLE (TT, THH, STL)
%
%	CMP_TipCircle.coord.x,y (TT):  center of tongue tip circle
%	CMP_TipCircle.polar.ang (THH): composite tongue tip angle (see below)
%	CMP_TipCircle.polar.len (STL): tongue tip length (see below)
%
%    The center of the tongue tip circle (TT) is determined by polar coords
%    THH and STL offset from CMP_BladeOrigin (B).  STL is constrained in
%    ASY to be the smaller of input length KEY_TipCircle.polar.len (ST) and a
%    maximum length STMX (although this contraint is bypassed when running
%    WAG); here the length is currently just the unconstrained value of
%    KEY_TipCircle.polar.len
%
%    The tongue tip angle THH is the sum of three components:
%      KEY_Jaw.polar.ang (THJ): jaw angle
%      KEY_TipCircle.polar.ang (THT): tip angle
%      CMP_TipTracking.polar.ang (THTC): tongue ball center contribution to 
%        tip angle
%  ============================================================================


% void eval_cmp_TipCircle()
% {
%   CMP_TipCircle.polar.ang = KEY_Jaw.polar.ang + KEY_TipCircle.polar.ang + 
%                             CMP_TipTracking.polar.ang;
%   CMP_TipCircle.polar.len = KEY_TipCircle.polar.len;
%   CMP_TipCircle.coord.x = CMP_BladeOrigin.coord.x + 
%                           CMP_TipCircle.polar.len * 
%                             cos( CMP_TipCircle.polar.ang );
%   CMP_TipCircle.coord.y = CMP_BladeOrigin.coord.y + 
%                           CMP_TipCircle.polar.len * 
%                             sin( CMP_TipCircle.polar.ang );
% 
% }

CMP_TipCircle(3) = KEY_TipCircle(3);
CMP_TipCircle(4) = KEY_Jaw(4) + KEY_TipCircle(4) + CMP_TipTracking(4);

CMP_TipCircle(1:2) = CMP_BladeOrigin(1:2) + CMP_TipCircle(3) * ...
                           [ cos( CMP_TipCircle(4) ) sin( CMP_TipCircle(4) ) ];
 


%  ============================================================================
%    EVAL_CMP_ROOT (PHK,THPT):  length & angle of perpendicular bisector of 
%			    tangent VAR_Hyoid (P) : CMP_HyoidTongTan (T)
%  ============================================================================


% void eval_cmp_Root()
% {
%   TPARAM *p;
%   double dx, dy;
% 
%   p = ( TPARAM * )  & TUN_Root;	
% 
%   dx = CMP_HyoidTongTan.coord.x - VAR_Hyoid.coord.x;
%   dy = CMP_HyoidTongTan.coord.y - VAR_Hyoid.coord.y;
% 
%   CMP_Root.polar.ang = dx ? atan2(dy, dx) - PIdiv2 : 0.;
%   CMP_Root.polar.len = (sqrt( dy*dy + dx*dx ) - p->osl.offset) * p->osl.scale;
% 
% }

d(1:2) = CMP_HyoidTongTan(1:2) - VAR_Hyoid(1:2);
CMP_Root(4) = atan2(d(2), d(1)) - pi/2;
CMP_Root(3) = ( norm(d) - TUN_Root(3) ) * TUN_Root(4);

                       




% evaluate fixed parameters

%    ============================================================================
%      CASY_EFIX.C  - evaluate fixed parameters

%        Includes:
%  	EVAL_FIX_LARYNX
%  	EVAL_FIX_VELUM
%  	EVAL_FIX_TEETHLIP
%  	EVAL_FIX_LIP
%  	EVAL_FIX_TERMINUS
%    ============================================================================

%    ============================================================================
%      EVAL_FIX_LARYNX (1):  posterior edge of larynx

%      Y:  forced to VAR_Larynx.coord.Y
%    ============================================================================

%  void eval_fix_Larynx() 
%  {

%    FIX_Larynx.coord.y = VAR_Larynx.coord.y;
%    straight_seg( & SEG_FIX_Larynx_Periarytenoid );

%  } /* eval_fix_Larynx */

FIX_Larynx(2) = VAR_Larynx(2);


%  /*
%    ============================================================================
%      EVAL_VAR_LAREPI (2):  intersection of epiglottis
%  	and line up and back from front edge of larynx

%      X:  same as epiglottis
%      Y:  down from VAR_Hyoid by GEO_Hyoid2LarEpiY + tuning factor
%  	  determined by horizontal position of VAR_Hyoid

%      Tuning: Adjust vertical position of VAR_LarEpi by scaled 
%      (TUN_LarEpiY.osl.scale)
%      difference between VAR_Hyoid horizontal position and point determined by
%      FIX_PharynxLo and TUN_LarEpiY.osl.offset.
%    ============================================================================
%  */

%  void eval_var_LarEpi() 
%  {
%    TPARAM *p;

%    p = (TPARAM *)&TUN_LarEpiY;		/* map tuning param args */

%    VAR_LarEpi.coord.x = VAR_Epiglottis.coord.x;
%    VAR_LarEpi.coord.y = VAR_Hyoid.coord.y - GEO_Hyoid2LarEpiY.polar.len + 
%  		       ( VAR_Hyoid.coord.x - ( FIX_PharynxLo.coord.x + 
%                                                 p->osl.offset )
%                         ) * p->osl.scale;

%  } /* eval_var_LarEpi */

VAR_LarEpi(1:2) = [ VAR_Epiglottis(1) ...
                    VAR_Hyoid(2) - GEO_Hyoid2LarEpiY(3) + ... 
                    ( VAR_Hyoid(1) - FIX_PharynxLo(1) - TUN_LarEpiY(3) ) ...
                          * TUN_LarEpiY(4) ];



                  
                  
                  
%  /*
%    ============================================================================
%      EVAL_VAR_ROOT (5,K):  end of perpendicular bisector of tangent line
%  			drawn from VAR_Hyoid to CMP_HyoidTongTan (PT)
%      			which is CMP_Root (PHK) plus KEY_RootOffset in length

%      If angle of tangent line - PI/2 CMP_Root.polar.ang (THPT) is in first 
%      quadrant, 
%      the end of its perpendicular bisector will be (below, at, above) tangent 
%      line when tangent line is (<, =, >) 3.5 cm long (384 mermels) (when
%      KEY_RootOffset is 0)
%    ============================================================================
%  */

%  void eval_var_Root() 
%  {
%    double dx, dy, len;

%    dx = CMP_HyoidTongTan.coord.x - VAR_Hyoid.coord.x;
%    dy = CMP_HyoidTongTan.coord.y - VAR_Hyoid.coord.y;

%    len = KEY_RootOffset.polar.len + CMP_Root.polar.len;

%    VAR_Root.coord.x = VAR_Hyoid.coord.x + 0.5 * dx + 
%                       len * cos( CMP_Root.polar.ang );
%    VAR_Root.coord.y = VAR_Hyoid.coord.y + 0.5 * dy + 
%                       len * sin( CMP_Root.polar.ang );

%    /* debug: function isnan is not available under VAX/VMS */
%    /*
%    if( isnan( VAR_Root.coord.x ) ||
%        isnan( VAR_Root.coord.y )
%      )
%    {
%      dx = 0.0;
%    }
%    */

%  } /* eval_var_Root */


VAR_Root(1:2) = (VAR_Hyoid(1:2) + CMP_HyoidTongTan(1:2) ) / 2 + ...
    (KEY_RootOffset(3) + CMP_Root( 3)) * ...
                  [ cos( CMP_Root(4) )   sin( CMP_Root(4) ) ];


%  /*
%    ============================================================================
%      EVAL_VAR_ROOTTONG (6,L):  intersection of tongue body circle with 
%  			        tangent drawn from VAR_Root (K)
%    ============================================================================
%  */

%  void eval_var_RootTong() 
%  {
%    double KL, a, a1, a2, dx, dy;

%    dx = VAR_Root.coord.x - CMP_TongueCircle.coord.x;
%    dy = VAR_Root.coord.y - CMP_TongueCircle.coord.y;

%    KL = dx * dx  +  dy * dy - 
%               KEY_TongueCircleRad.polar.len  *KEY_TongueCircleRad.polar.len;

%    /* check for error */
%    KL = KL > 0.0       ? 
%           sqrt( KL ) : 
%           0.0;             /* ??? plug ??? */

%    a1 = dx ? atan2( dy, dx ) : PIdiv2;
%    a2 = KEY_TongueCircleRad.polar.len ? 
%         atan2( KL, KEY_TongueCircleRad.polar.len ) : 
%         PIdiv2;
%    a  = a1 - a2;

%    VAR_RootTong.coord.x = CMP_TongueCircle.coord.x + 
%                           KEY_TongueCircleRad.polar.len * cos( a );
%    VAR_RootTong.coord.y = CMP_TongueCircle.coord.y + 
%                           KEY_TongueCircleRad.polar.len * sin( a );

%  } /* eval_var_RootTong */


d = VAR_Root(1:2) - CMP_TongueCircle(1:2);
a1 = atan2( d(2), d(1) );

KL = sqrt( max( 0, d(1)^2 + d(2)^2 - KEY_TongueCircleRad(3)^2 ) );
a2 = atan2( KL, KEY_TongueCircleRad(3) );

a = a1 - a2;

VAR_RootTong(1:2) = CMP_TongueCircle(1:2) + ...
                    KEY_TongueCircleRad(3) * [ cos(a) sin(a) ];


                
                
                
                
                
                
%  /* 
%    ============================================================================
%      EVAL_VAR_FLOOR (11):  point defining left-most edge of mouth floor

%      Determined by an offset back from VAR_Teeth (GEO_Teeth2Floor), adjusted 
%      by tongue tip position.  May not lie farther right of VAR_Teeth.  
%      Left of VAR_FloorTeeth vertical position is the same as FloorTeeth; 
%      in the region between VAR_Teeth and VAR_FloorTeeth vertical position 
%      tracks line between them.
%    ============================================================================
%  */

%  void eval_var_Floor() 
%  {
%    TPARAM *p = ( TPARAM * )  & TUN_FloorX;	

%    VAR_Floor.coord.x = VAR_Teeth.coord.x - GEO_Teeth2FloorX.polar.len + 
%                        ( p->osl.offset - 
%                          ( VAR_Teeth.coord.x - CMP_TipCircle.coord.x ) 
%                        ) * p->osl.scale;

VAR_Floor(1) = VAR_Teeth(1) - GEO_Teeth2FloorX(3) + ...
                 ( TUN_FloorX(3) - ( VAR_Teeth(1) - CMP_TipCircle(1) )) ...
                * TUN_FloorX(4);
            
if VAR_Floor(1) >= VAR_Teeth(1); 
  VAR_Floor(1:2) = VAR_Teeth(1:2);
elseif( VAR_Floor(1) > VAR_FloorTeeth(1) );
  VAR_Floor(2) =  VAR_Teeth(2) ...
                - ( VAR_Teeth(1) - VAR_Floor(1) ) * tan( CMP_Floor2Teeth(4) );
else
  VAR_Floor(2) = VAR_FloorTeeth(2); 
end


%    if( VAR_Floor.coord.x >= VAR_Teeth.coord.x ) 
%                                            /* right of Teeth? clip to Teeth */
%    {	
%      VAR_Floor.coord.x = VAR_Teeth.coord.x;
%      VAR_Floor.coord.y = VAR_Teeth.coord.y;

%      /* remove FloorTeeth from otl */
%      {
%        SegNODE ** ppSeg;
  
%        for( ppSeg = & VARSEGS;   * ppSeg;   ppSeg = & (* ppSeg)->next )
%        {
%  	if( ( * ppSeg )->segment == & SEG_VAR_Floor_FloorTeeth )
%  	{
%  	  remove_segment( ppSeg );
%  	  insert_segment( ppSeg, & SEG_VAR_Floor_Teeth );
%  	}
%  	else if( ( * ppSeg )->segment == & SEG_VAR_FloorTeeth_Teeth )
%  	  remove_segment( ppSeg );
%        }
%      }
%      VAR_FloorTeeth.flags |= MASK_SKIP_DRAW;	
%    } 
%    else if( VAR_Floor.coord.x > VAR_FloorTeeth.coord.x )    
%    /* between Teeth & FloorTeeth */
%    {
%      VAR_Floor.coord.y = VAR_Teeth.coord.y - 
%                          ( VAR_Teeth.coord.x - VAR_Floor.coord.x ) * 
%                          tan( CMP_Floor2Teeth.polar.ang );

%      /* remove FloorTeeth from otl */
%      {
%        SegNODE ** ppSeg;
  
%        for( ppSeg = & VARSEGS;   * ppSeg;   ppSeg = & (* ppSeg)->next )
%        {
%  	if( ( * ppSeg )->segment == & SEG_VAR_Floor_FloorTeeth )
%  	{
%  	  remove_segment( ppSeg );
%  	  insert_segment( ppSeg, & SEG_VAR_Floor_Teeth );
%  	}
%  	else if( ( * ppSeg )->segment == & SEG_VAR_FloorTeeth_Teeth )
%  	  remove_segment( ppSeg );
%        }
%      }
%      VAR_FloorTeeth.flags |= MASK_SKIP_DRAW;	
%    } 
%    else 					/* left of FloorTeeth */
%    {
%      VAR_Floor.coord.y = VAR_FloorTeeth.coord.y;

%      /* include FloorTeeth on otl */
%      {
%        SegNODE ** ppSeg;
  
%        for( ppSeg = & VARSEGS;   * ppSeg;   ppSeg = & (* ppSeg)->next )
%        {
%  	if( ( * ppSeg )->segment == & SEG_VAR_Floor_Teeth )
%  	{
%  	  remove_segment( ppSeg );
%  	  insert_segment( ppSeg, & SEG_VAR_FloorTeeth_Teeth );
%  	  insert_segment( ppSeg, & SEG_VAR_Floor_FloorTeeth );
%  	}
%        }
%      }
%      VAR_FloorTeeth.flags &= ~MASK_SKIP_DRAW;	
%    } 
%  } /* eval_var_Floor */




%  ============================================================================
%    EVAL_CMP_FRONTFACTOR:  tongue tip curve fronting factor
%
%   Proportional to the amount by which tongue tip length 
%   CMP_TipCircle.polar.len (STL)
%   is less than TUN_FrontFactor.polar.len mermels long
%  ============================================================================


% void eval_cmp_FrontFactor()
% {
%   TPARAM *p;
% 
%   p = ( TPARAM * )  & TUN_FrontFactor;	
%   CMP_FrontFactor.polar.len = ( CMP_TipCircle.polar.len - p->osl.offset ) * 
%                               p->osl.scale;
% 
% }

CMP_FrontFactor(3) = ( CMP_TipCircle(3) - TUN_FrontFactor(3) ) * ...
                                                       TUN_FrontFactor(4);
                         



%  ============================================================================
%    EVAL_CMP_TONGBLADE (TVV):  angle determining VAR_TongBlade, the
%				point at which the outline diverges from
%				the tongue ball circle. 
%
%    CMP_TongBlade is determined by the tongue tip angle CMP_TipCircle.polar.ang 
%    (THH) plus KEY_BladeOriginOffset.polar.ang, adjusted by a fronting factor 
%    (CMP_FrontFactor.polar.len) proportional to tongue tip length 
%    (CMP_TipCircle.polar.len, STL)
%  ============================================================================

% void eval_cmp_TongBlade()
% {
%   CMP_TongBlade.polar.ang = 0.5 * ( CMP_TipCircle.polar.ang + 
%                                     KEY_BladeOriginOffset.polar.ang + PI ) + 
%                             CMP_FrontFactor.polar.len;
% 
% }

% modified by HN Hosung Nam 070625
% a bug: CMP_FrontFactor(4) -> CMP_FrontFactor(3)
% CMP_TongBlade(4) = 0.5 * ( CMP_TipCircle(4) + KEY_BladeOriginOffset(4)+ pi ) + ...
%                          CMP_FrontFactor(4);

CMP_TongBlade(4) = 0.5 * ( CMP_TipCircle(4) + KEY_BladeOriginOffset(4)+ pi ) + ...
                         CMP_FrontFactor(3);


                     
                     
%  /*
%    ============================================================================
%      EVAL_VAR_TONGBLADE (7, B'):  point of departure of tongue tip curve from
%  			    tongue body circle.  

%      Located at angle CMP_TongBlade.polar.ang from CMP_TongueCircle.coord.x,y  
%    ============================================================================
%  */

%  void eval_var_TongBlade() 
%  {

%    VAR_TongBlade.coord.x = CMP_TongueCircle.coord.x + 
%                            KEY_TongueCircleRad.polar.len * 
%                              cos( CMP_TongBlade.polar.ang );
%    VAR_TongBlade.coord.y = CMP_TongueCircle.coord.y + 
%                            KEY_TongueCircleRad.polar.len * 
%                              sin( CMP_TongBlade.polar.ang );

%  } /* eval_var_TongBlade */

VAR_TongBlade(1:2) = CMP_TongueCircle(1:2) + ...
                       KEY_TongueCircleRad(3) * ...
                             [ cos( CMP_TongBlade(4) ) sin( CMP_TongBlade(4) ) ];


                         
                         
                         
                         
%  ============================================================================
%    EVAL_CMP_BLADECIRCLERAD:  radius of tongue blade circle
%
%    The tongue blade circle describes the curvature of the variable outline
%    between the tongue ball and the tongue tip circles.  It has its center 
%    (CMP_BladeCircle, Q) on the extension of the line determined by the 
%    tongue ball center (CMP_TongueCircle, C) and the point the outline curve 
%    diverges from the tongue ball circle (VAR_TongBlade, B').  It is tangent 
%    to the tongue ball circle at point VAR_TongBlade, B', and to the tip 
%    circle at VAR_BladeTip.  By the Rule of Cosines
%
%	(BQ+Tr)^2 = BQ^2 + BT^2 - 2 BQ BT cos(theta)
%
%    where Tr is the tip circle radius GEO_TipCircle.polar.len
%	  BT is the Euclidean distance between VAR_TongBlade (B') and tip 
%		circle center CMP_TipCircle.coord.x,y (T)
%	  theta is the included angle QBT
%      and BQ is the blade circle radius (CMP_BladeCircleRad.polar.len)
%
%    theta is the declination of point B' from the horizontal 
%        (CMP_TongBlade.polar.ang)
%	at the tongue ball center (CMP_TongueCircle, C), less the declination 
%	of point T from the horizontal at point B'
%  ============================================================================


% void eval_cmp_BladeCircleRad()
% {
%   double dTxBx,dTyBy, theta, BT, v;
% 
%   dTxBx = CMP_TipCircle.coord.x - VAR_TongBlade.coord.x;
%   dTyBy = CMP_TipCircle.coord.y - VAR_TongBlade.coord.y;
%   BT = sqrt( dTxBx*dTxBx + dTyBy*dTyBy );
%   theta = CMP_TongBlade.polar.ang - (dTxBx?atan2(dTyBy,dTxBx):PIdiv2);
% 
% ***  test for infinite radius  ***
% 
%   v = 2 * (BT * cos(theta) + GEO_TipCircleRad.polar.len);
%   CMP_BladeCircleRad.polar.len = v ? 
%                                  ( BT * BT  - 
%                     GEO_TipCircleRad.polar.len * GEO_TipCircleRad.polar.len
%                                  ) / v : 
%                                  INFINITY;
% 
% }


% dTB = CMP_TipCircle(1:2) - VAR_TongBlade
% BT = norm( dTB )
% if BT == 0
%     theta = CMP_TongBlade(4) - pi/2
% else
%     theta = CMP_TongBlade(4) - atan2(dTB(2),dTB(1))
% end
%  
% v = BT * cos(theta) + GEO_TipCircleRad(3)
% if( v == 0 ) % ***  test for infinite radius  ***
%     CMP_BladeCircleRad(3) = Inf
% else
%     CMP_BladeCircleRad(3) = ( BT^2  - GEO_TipCircleRad(3)^2 ) / 2*v
% end

dTB = CMP_TipCircle(1:2) - VAR_TongBlade(1:2);
BT = norm( dTB );


theta = CMP_TongBlade(4) - atan2(dTB(2),dTB(1)); 
% if BT==0, arctan2 == 0;
% however, in this case 
% BT*cos( theta) == 0 does not matter what

 
v = BT * cos(theta) + GEO_TipCircleRad(3);
CMP_BladeCircleRad(3) = ( BT^2  - GEO_TipCircleRad(3)^2 ) / (2*v);
% CMP_BladeCircleRad(3) == Inf if v==0





%  ============================================================================
%    EVAL_CMP_BLADECIRCLE:  center of tongue blade circle; lies along the 
%				extension of the line determined by the 
%    tongue ball center (CMP_TongueCircle, C) and the point the outline curve 
%    diverges from the tongue ball circle (VAR_TongBlade, B').  The slope of
%    this line is described by CMP_TongBlade.polar.ang
%
%  ============================================================================


% void eval_cmp_BladeCircle()
% {
%   CMP_BladeCircle.coord.x = VAR_TongBlade.coord.x + 
%                CMP_BladeCircleRad.polar.len * cos(CMP_TongBlade.polar.ang);
%   CMP_BladeCircle.coord.y = VAR_TongBlade.coord.y + 
%                CMP_BladeCircleRad.polar.len * sin(CMP_TongBlade.polar.ang);
% 
% }

CMP_BladeCircle = VAR_TongBlade + ...
    CMP_BladeCircleRad(3) * [ cos(CMP_TongBlade(4)) sin(CMP_TongBlade(4)) ];




%  /* 
%    ============================================================================
%      EVAL_VAR_BLADETIP:  point of contact between tongue blade and tongue tip
%  			circles
%    ============================================================================
%  */

%  void eval_var_BladeTip() 
%  {
%    double dx, dy, h; 

%    dx = CMP_TipCircle.coord.x - CMP_BladeCircle.coord.x;
%    dy = CMP_TipCircle.coord.y - CMP_BladeCircle.coord.y;
%    h = sqrt( dx*dx + dy*dy );

%    if (h > 1.e-4 ) {
%      if (CMP_BladeCircleRad.polar.len > 0) {
%        VAR_BladeTip.coord.x = CMP_TipCircle.coord.x - 
%                               dx * GEO_TipCircleRad.polar.len / h;
%        VAR_BladeTip.coord.y = CMP_TipCircle.coord.y - 
%                               dy * GEO_TipCircleRad.polar.len / h;
%      } else {
%        VAR_BladeTip.coord.x = CMP_TipCircle.coord.x + 
%                               dx * GEO_TipCircleRad.polar.len / h;
%        VAR_BladeTip.coord.y = CMP_TipCircle.coord.y + 
%                               dy * GEO_TipCircleRad.polar.len / h;
%      } 
%    } else {
%      VAR_BladeTip.coord.x = CMP_BladeCircle.coord.x;
%      VAR_BladeTip.coord.y = CMP_BladeCircle.coord.y;
%    } 
%  } /* eval_var_BladeTip */


% ??????????? 1-st and 2-nd branches are identical

d = CMP_TipCircle(1:2) - CMP_BladeCircle(1:2);
h = norm( d );

% commented by HN
% if( h > 1.0e-4 )
%     VAR_BladeTip(1:2) = CMP_TipCircle(1:2) + d * GEO_TipCircleRad(3) / h;
% else
%     VAR_BladeTip(1:2) = CMP_BladeCircle(1:2);
% end
VAR_BladeTip(1:2) = CMP_TipCircle(1:2);
    
    



%  /* 
%    ============================================================================
%      EVAL_VAR_TIPFLOOR (10):  rightmost tangent of tongue tip circle with line
%  				drawn from VAR_Floor

%      removed from outline if above VAR_BladeTip (on same side of circle)
%    ============================================================================
%  */

%  void eval_var_TipFloor() 
%  {
%    double FT, a, a1, a2, dx, dy;

%    dx = VAR_Floor.coord.x - CMP_TipCircle.coord.x;
%    dy = VAR_Floor.coord.y - CMP_TipCircle.coord.y;
%    dx = fabs(dx);
%    dy = fabs(dy);

  

%    FT = dx*dx + dy*dy - 
%               GEO_TipCircleRad.polar.len * GEO_TipCircleRad.polar.len ;

%    /* checking for error */
%    FT = FT > 0.0       ?
%           sqrt( FT ) :
%           0.0;             /* ??? plug ??? */


%    a1 = dx ? atan2( dy, dx ) : PIdiv2;
%    a2 = GEO_TipCircleRad.polar.len ? 
%         atan2( FT, GEO_TipCircleRad.polar.len ) : 
%         PIdiv2;
%    a  = a1 - a2;

%    VAR_TipFloor.coord.x = CMP_TipCircle.coord.x + 
%                           GEO_TipCircleRad.polar.len * cos( a );
%    VAR_TipFloor.coord.y = CMP_TipCircle.coord.y + 
%                           GEO_TipCircleRad.polar.len * sin( a );


d = abs( VAR_Floor(1:2) - CMP_TipCircle(1:2) );
FT = sqrt( max( 0, d(1)^2+ d(2)^2 - GEO_TipCircleRad(3)^2 ));
a = atan2( d(2), d(1) ) - atan2( FT, GEO_TipCircleRad(3) );
VAR_TipFloor(1:2) = CMP_TipCircle(1:2)  + ...
                          GEO_TipCircleRad(3) * [ cos(a) sin(a) ];

    

%    if( VAR_TipFloor.coord.y > VAR_BladeTip.coord.y  && 
%        VAR_BladeTip.coord.x > CMP_TipCircle.coord.x
%      )                                      	/* remove from outline */
%    {
%      SegNODE ** ppSeg;

%      for( ppSeg = & VARSEGS;   * ppSeg;   ppSeg = & (* ppSeg)->next )
%      {
%        if( ( * ppSeg )->segment == & SEG_VAR_BladeTip_TipFloor )
%        {
%          remove_segment( ppSeg );
%          insert_segment( ppSeg, & SEG_VAR_BladeTip_Floor );
%        }
%        else if( ( * ppSeg )->segment == & SEG_VAR_TipFloor_Floor )
%          remove_segment( ppSeg );
%      }

%      VAR_TipFloor.flags |= MASK_SKIP_DRAW;
%    }
%    else
%    {
%      SegNODE ** ppSeg;

%      for( ppSeg = & VARSEGS;   * ppSeg;   ppSeg = & (* ppSeg)->next )
%      {
%        if( ( * ppSeg )->segment == & SEG_VAR_BladeTip_Floor )
%        {
%          remove_segment( ppSeg );
%          insert_segment( ppSeg, & SEG_VAR_TipFloor_Floor );
%          insert_segment( ppSeg, & SEG_VAR_BladeTip_TipFloor );
%        }
%      }
%      VAR_TipFloor.flags &= ~MASK_SKIP_DRAW;
%    }

%    /* debug */
%    /*
%    if( isnan( VAR_TipFloor.coord.x ) ||
%        isnan( VAR_TipFloor.coord.y )
%      )
%    {
%      dx = 0.0;
%    }
%    */

%  } /* eval_var_TipFloor */
                    

% calculates intermediate variables

%  ============================================================================
%    CASY_ECMP.C  - evaluate computed parameters
%
%      Includes:
%	EVAL_CMP_BLADEORIGIN
%	EVAL_CMP_BLADECIRCLE
%	EVAL_CMP_BLADECIRCLERAD
%	EVAL_CMP_TONGBLADE
%	EVAL_CMP_FRONTFACTOR
%	EVAL_CMP_FLOOR2TEETH
%	EVAL_CMP_TIPCIRCLE
%	EVAL_CMP_TIPTRACKING
%	EVAL_CMP_ROOT
%	EVAL_CMP_HYOIDTONGTAN
%	EVAL_CMP_TONGUECIRCLE
%  ============================================================================



% evaluate variable parameters

%  /*
%    ============================================================================
%      CASY_EVAR.C  - evaluate variable parameters

%        Includes:
%  	EVAL_VAR_LARYNX
%  	EVAL_VAR_LAREPI
%  	EVAL_VAR_EPIGLOTTIS
%  	EVAL_VAR_HYOID
%  	EVAL_VAR_ROOT
%  	EVAL_VAR_ROOTTONG
%  	EVAL_VAR_TONGBLADE
%  	EVAL_VAR_BLADETIP
%  	EVAL_VAR_TIPFLOOR
%  	EVAL_VAR_FLOOR
%  	EVAL_VAR_FLOORTEETH
%  	EVAL_VAR_TEETH
%  	EVAL_VAR_TEETHLIP
%  	EVAL_VAR_LIP
%  	EVAL_VAR_TERMINUS
%    ============================================================================
%  */




