% key parameter changed - what happens? 

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

%  ============================================================================
%    CASY_MODK.C  - interactive key parameter modification functions
%
%      Includes:
%	MOD_KEY_FixLip
%	MOD_KEY_VarLip
%	MOD_KEY_TongueCircle
%	MOD_KEY_TongueCircleRad
%	MOD_KEY_Jaw 
%	MOD_KEY_TipCircle
%	MOD_KEY_BladeOriginOffset
%	MOD_KEY_RootOffset
% 	MOD_KEY_Hyoid
% 	MOD_KEY_Nasal
%   ============================================================================

function modkey(s)


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


coords0 = get(gca,'CurrentPoint');
coords = coords0(1, 1:2); % the screen cursor points here

switch( s )

    
%   ============================================================================
%     MOD_KEY_FIXLIP
%   ============================================================================

% void mod_key_FixLip(double xpos, double ypos)
% {
%   KEY_FixLip.coord.x = xpos - FIX_Teeth.coord.x - KEY_VarLip.coord.x;
%   KEY_FixLip.coord.y = FIX_Teeth.coord.y - ypos - KEY_VarLip.coord.y;
%   evaldeps(&KEY_FixLip);
% 
% } /* mod_key_FixLip */

case 'FixLip'
    KEY_FixLip(1:2) = coords - FIX_Teeth(1:2) - KEY_VarLip(1:2);
    
 
    % verify the sign for y!!!

% /*
%   ============================================================================
%     MOD_KEY_VARLIP
%   ============================================================================
% */

% void mod_key_VarLip(double xpos, double ypos)
% {
%   KEY_VarLip.coord.x = xpos - 
%                        ( GEO_Condyle.coord.x + 
%                          KEY_Jaw.polar.len * cos( KEY_Jaw.polar.ang ) );
%   KEY_VarLip.coord.y = ypos - 
%                        ( GEO_Condyle.coord.y + 
%                          KEY_Jaw.polar.len * sin( KEY_Jaw.polar.ang ) );
%   evaldeps(&KEY_VarLip);
% 
% } /* mod_key_VarLip */

case 'VarLip'
  KEY_VarLip(1:2) = coords - GEO_Condyle(1:2) - ...
      KEY_Jaw(3) * [ cos( KEY_Jaw(4) ) sin( KEY_Jaw(4) ) ];


% /*
%   ============================================================================
%     MOD_KEY_TONGUECIRCLE
%   ============================================================================
% */

% void mod_key_TongueCircle(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - GEO_Condyle.coord.x;
%   dy = ypos - GEO_Condyle.coord.y;
%   KEY_TongueCircle.polar.len = sqrt( dx*dx + dy*dy );
%   KEY_TongueCircle.polar.ang = dx ? atan2(dy,dx) : PIdiv2;
%   KEY_TongueCircle.polar.ang -= KEY_Jaw.polar.ang;
%   evaldeps(&KEY_TongueCircle);
% 
% } /* mod_key_TongueCircle */

case 'TongueCircle'
    d = coords - GEO_Condyle(1:2);
    KEY_TongueCircle(3) = norm(d);
    KEY_TongueCircle(4) = atan2( d(2), d(1) ) - KEY_Jaw(4);
    

% /*
%   ============================================================================
%     MOD_KEY_TONGUECIRCLERAD
%   ============================================================================
% */

% void mod_key_TongueCircleRad(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - CMP_TongueCircle.coord.x;
%   dy = ypos - CMP_TongueCircle.coord.y;
%   KEY_TongueCircleRad.polar.len = sqrt( dx*dx + dy*dy );
%   evaldeps(&KEY_TongueCircleRad);
% 
% } /* mod_key_TongueCircleRad */

case 'TongueCircleRad'
    KEY_TongueCircleRad(3) = norm( coords - CMP_TongueCircle(1:2) );
    


% /*
%   ============================================================================
%     MOD_KEY_JAW
%   ============================================================================
% */

% void mod_key_Jaw(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - GEO_Condyle.coord.x;
%   dy = ypos - GEO_Condyle.coord.y;
%   KEY_Jaw.polar.ang = dx ? atan2(dy,dx) : -PIdiv2;
%   KEY_Jaw.polar.len = sqrt( dx*dx + dy*dy );
%   evaldeps(&KEY_Jaw);
% 
% } /* mod_key_Jaw */
% 

case 'Jaw'
    d = coords - GEO_Condyle(1:2);
    KEY_Jaw(3) = norm( d );
    KEY_Jaw(4) = atan2( d(2), d(1) );

    

% /*
%   ============================================================================
%     MOD_KEY_TIPCIRCLE
%   ============================================================================
% */

% void mod_key_TipCircle(double xpos, double ypos)
% {
%   double dx, dy, a;
% 
%   a = KEY_Jaw.polar.ang + GEO_BladeOrigin.polar.ang + 
%       KEY_BladeOriginOffset.polar.ang;
%   dx = xpos - ( CMP_TongueCircle.coord.x + 
%                 KEY_TongueCircleRad.polar.len * cos( a ) );
%   dy = ypos - ( CMP_TongueCircle.coord.y + 
%                 KEY_TongueCircleRad.polar.len * sin( a ) );
%   KEY_TipCircle.polar.len = sqrt( dx*dx + dy*dy );
%   KEY_TipCircle.polar.ang = dx ? atan2( dy, dx ) : PIdiv2;
%   KEY_TipCircle.polar.ang -= ( KEY_Jaw.polar.ang + CMP_TipTracking.polar.ang );
%   evaldeps( & KEY_TipCircle );
% 
% } /* mod_key_TipCircle */

case 'TipCircle'
    a = KEY_Jaw(4) + GEO_BladeOrigin(4) + KEY_BladeOriginOffset(4);
    d = coords - CMP_TongueCircle(1:2) - ...
        KEY_TongueCircleRad(3) * [ cos(a) sin(a) ];
    KEY_TipCircle(3) = norm( d );
    KEY_TipCircle(4) = atan2( d(2), d(1) ) - KEY_Jaw(4) - CMP_TipTracking(4);
        
    

% /*
%   ============================================================================
%     MOD_KEY_BLADEORIGINOFFSET
%   ============================================================================
% */

case 'BladeOriginOffset'
    KEY_BladeOriginOffset(4) = 2 * ( ...
        acos( ( coords(1) - CMP_TongueCircle(1) ) / KEY_TongueCircleRad(3) ) ...
        - CMP_FrontFactor(3 ) ) ...
      - CMP_TipCircle(4) - pi;  
    
% /*
%   ============================================================================
%     MOD_KEY_ROOTOFFSET
%   ============================================================================
% */

% void mod_key_RootOffset(double xpos, double ypos)
% {
%   double n, d;
% 
%   d = cos(CMP_Root.polar.ang);
%   n = xpos - .5 * (VAR_Hyoid.coord.x + CMP_HyoidTongTan.coord.x);
%   KEY_RootOffset.polar.len = d ? n/d - CMP_Root.polar.len : INFINITY;
%   evaldeps(&KEY_RootOffset);
% 
% } /* mod_key_RootOffset */

case 'RootOffset'
    KEY_RootOffset(3) = ( coords(1) - ...
                          .5 * (VAR_Hyoid(1) + CMP_HyoidTongTan(1) ) ... 
                        ) / cos( CMP_Root(4) ) - CMP_Root(3);
    


% /*
%   ============================================================================
%     MOD_KEY_HYOID
%   ============================================================================
% */

% void mod_key_Hyoid(double xpos, double ypos)
% {
%   KEY_Hyoid.coord.x = xpos;
%   KEY_Hyoid.coord.y = ypos;
%   evaldeps(&KEY_Hyoid);
% 
% } /* mod_key_Hyoid */

case 'Hyoid'
    KEY_Hyoid(1:2) = coords;
    


% /*
%   ============================================================================
%     MOD_KEY_NASAL
%   ============================================================================
% */

% void mod_key_Nasal(double xpos, double ypos)
% {
%   double x;
%   double co;
% 
%   co = cos(DEG2RAD(GEO_Velum.polar.ang));
%   x = (xpos<FIX_PharynxHi.coord.x) ? FIX_PharynxHi.coord.x : xpos;
%   x = x - FIX_PharynxHi.coord.x;
% 
% /* ***  case 1:  right of PharynxHi; length is projection onto line  *** */
% /*	from PharynxHi down and right at current velum declination angle */
% 
% 
%   			 
%     KEY_Nasal.polar.len = fabs(co) > 1.0e-4 ?
%                      x / co :
% /* ***  case 2:  on top of or left of PharynxHi; length is 0  *** */
%                      0;
% 
%   KEY_Nasal.polar.len = 
%               fabs( GEO_Velum.polar.len ) < fabs( KEY_Nasal.polar.len ) ? 
%               1.0                                           :
%               KEY_Nasal.polar.len/GEO_Velum.polar.len;
%   KEY_Nasal.polar.len *= KEY_Nasal.polar.len;
% 
%   evaldeps(&KEY_Nasal);
% 
% } /* mod_key_Nasal */

case 'Nasal'
    co = cos( GEO_Velum(4) ); % !!! verify degrees/radians
    x = max( coords(1) - FIX_PharynxHi(1), 0 );
    KEY_Nasal(3) = min( x/co/GEO_Velum(3)^2, 1 );
    


end % switch

refresh
