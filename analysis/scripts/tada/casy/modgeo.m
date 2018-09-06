% process moving geo params

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

%   ============================================================================
%     CASY_MODG.C  - interactive geometric parameter modification functions
% 
%       Includes:
% 	MOD_GEO_FixTerminus
% 	MOD_GEO_VarTerminus
% 	MOD_GEO_Velum
% 	MOD_GEO_Hyoid2Epi
% 	MOD_GEO_Hyoid2LarEpiY
% 	MOD_GEO_Hyoid2LarynxY
% 	MOD_GEO_Teeth2FloorTeeth
% 	MOD_GEO_FixTeeth2TeethLip
% 	MOD_GEO_VarTeeth2TeethLip
% 	MOD_GEO_Teeth2FloorX
% 	MOD_GEO_TipCircleRad
%   ============================================================================

function modgeo(s)


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
coords = coords0(1, 1:2);  % the screen cursor points here


switch( s )

    
%   ============================================================================
%     MOD_GEO_FIXTERMINUS
%   ============================================================================

% void mod_geo_FixTerminus(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - FIX_Lip.coord.x;
%   dy = ypos - FIX_Lip.coord.y;
%   GEO_FixTerminus.polar.len = sqrt( dx*dx + dy*dy );
%   GEO_FixTerminus.polar.ang = dx ? atan2(dy,dx) : PIdiv2;
%   evaldeps(&GEO_FixTerminus);
% 
% } /* mod_geo_FixTerminus */

case 'FixTerminus'
    d = coords - FIX_Lip(1:2); 
    GEO_FixTerminus(3) = norm(d);
    GEO_FixTerminus(4) = atan2( d(2), d(1) );

%   ============================================================================
%     MOD_GEO_VARTERMINUS
%   ============================================================================

% void mod_geo_VarTerminus(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - VAR_Lip.coord.x;
%   dy = ypos - VAR_Lip.coord.y;
%   GEO_VarTerminus.polar.len = sqrt( dx*dx + dy*dy );
%   GEO_VarTerminus.polar.ang = dx ? atan2(dy,dx) : PIdiv2;
%   evaldeps(&GEO_VarTerminus);
% 
% } /* mod_geo_VarTerminus */

case 'VarTerminus'
    d = coords - VAR_Lip(1:2);
    GEO_VarTerminus(3) = norm(d); 
    GEO_VarTerminus(4) = atan2( d(2), d(1) ); 

%   ============================================================================
%     MOD_GEO_VELUM
%   ============================================================================

% void mod_geo_Velum(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   xpos = (xpos<FIX_PharynxHi.coord.x) ? FIX_PharynxHi.coord.x : xpos;
%   GEO_Velum.coord.x = xpos;
%   GEO_Velum.coord.y = ypos;
%   dx = xpos - FIX_PharynxHi.coord.x;
%   dy = FIX_PharynxHi.coord.y - ypos;
%   GEO_Velum.polar.len = sqrt( dx*dx + dy*dy );
%   GEO_Velum.polar.ang = dx ? atan2(dy,dx) : PIdiv2;
%   GEO_Velum.polar.ang = RAD2DEG(GEO_Velum.polar.ang);
%   evaldeps(&GEO_Velum);
% 
% } /* mod_geo_Velum */

case 'Velum'
    coords(1) = max( coords(1), FIX_PharynxHi(1) ); 
    GEO_Velum(1:2) = coords; 
    d = coords - FIX_PharynxHi(1:2); 
    GEO_Velum(3) = norm(d); 
    GEO_Velum(4) = atan2(d(2), d(1) );  % verify sign and degrees / radians
    
%   ============================================================================
%     MOD_GEO_HYOID2EPI
%   ============================================================================

% void mod_geo_Hyoid2Epi(double xpos, double ypos)
% {
%   GEO_Hyoid2Epi.coord.x = VAR_Hyoid.coord.x - xpos;
%   GEO_Hyoid2Epi.coord.y = ypos - VAR_Hyoid.coord.y;
%   evaldeps(&GEO_Hyoid2Epi);
% 
% } /* mod_geo_Hyoid2Epi */

case 'Hyoid2Epi'
    GEO_Hyoid2Epi(1:2) = VAR_Hyoid(1:2) - coords;  % verify sign of the y coordinate

%   ============================================================================
%     MOD_GEO_HYOID2LAREPIY
%   ============================================================================

% void mod_geo_Hyoid2LarEpiY(double xpos, double ypos)
% {
%   TPARAM *p;
% 
%   p = (TPARAM *)&TUN_LarEpiY;
%   GEO_Hyoid2LarEpiY.polar.len = VAR_Hyoid.coord.y - ypos +
% 		p->osl.scale * (VAR_Hyoid.coord.x - (FIX_PharynxLo.coord.x + p->osl.offset));
%   evaldeps(&GEO_Hyoid2LarEpiY);
% 
% } /* mod_geo_Hyoid2LarEpiY */

case 'Hyoid2LarEpiY'
    GEO_Hyoid2LarEpiY(3) = VAR_Hyoid(2) - coords(2) + ...
        TUN_LarEpiY(4) * ( VAR_Hyoid(1) - FIX_PharynxLo(1) - TUN_LarEpiY(3) ); 

    
%   ============================================================================
%     MOD_GEO_HYOID2LARYNXY
%   ============================================================================

% void mod_geo_Hyoid2LarynxY(double xpos, double ypos)
% {
%   GEO_Hyoid2LarynxY.polar.len = VAR_Hyoid.coord.y - ypos;
%   evaldeps(&GEO_Hyoid2LarynxY);
% 
% } /* mod_geo_Hyoid2LarynxY */

case 'Hyoid2LarynxY'
    GEO_Hyoid2LarynxY(3) = VAR_Hyoid(2) - coords(2); 

%   ============================================================================
%     MOD_GEO_TEETH2FLOORTEETH
%   ============================================================================

% void mod_geo_Teeth2FloorTeeth(double xpos, double ypos)
% {
%   double dx, dy, a;
% 
%   dx = VAR_Teeth.coord.x - xpos;
%   dy = VAR_Teeth.coord.y - ypos;
%   GEO_Teeth2FloorTeeth.polar.len = sqrt( dx*dx + dy*dy );
%   a = dx ? atan2(dy,dx) : PIdiv2;
%   GEO_Teeth2FloorTeeth.polar.ang = a - KEY_Jaw.polar.ang;
%   evaldeps(&GEO_Teeth2FloorTeeth);
% 
% } /* mod_geo_Teeth2FloorTeeth */

case 'Teeth2FloorTeeth'
    d = VAR_Teeth(1:2) - coords; 
    GEO_Teeth2FloorTeeth(3) = norm(d); 
    GEO_Teeth2FloorTeeth(4) = atan2(d(2),d(1)) - KEY_Jaw(4); 
    

%   ============================================================================
%     MOD_GEO_FIXTEETH2TEETHLIP
%   ============================================================================

% void mod_geo_FixTeeth2TeethLip(double xpos, double ypos)
% {
%   GEO_FixTeeth2TeethLip.polar.len = xpos - FIX_Teeth.coord.x;
%   evaldeps(&GEO_FixTeeth2TeethLip);
% 
% } /* mod_geo_FixTeeth2TeethLip */

case 'FixTeeth2TeethLip'
    GEO_FixTeeth2TeethLip(3) = coords(1) - FIX_Teeth(1); 
    

%   ============================================================================
%     MOD_GEO_VARTEETH2TEETHLIP
%   ============================================================================

% void mod_geo_VarTeeth2TeethLip(double xpos, double ypos)
% {
%   GEO_VarTeeth2TeethLip.polar.len = xpos - VAR_Teeth.coord.x;
%   evaldeps(&GEO_VarTeeth2TeethLip);
% 
% } /* mod_geo_VarTeeth2TeethLip */

case 'VarTeeth2TeethLip'
    GEO_VarTeeth2TeethLip(3) = coords(1) - VAR_Teeth(1); 
  
%   ============================================================================
%     MOD_GEO_TEETH2FLOORX
%   ============================================================================

% void mod_geo_Teeth2FloorX(double xpos, double ypos)
% {
%   TPARAM *p;
% 
%   p = (TPARAM *)&TUN_FloorX;	
%   GEO_Teeth2FloorX.polar.len = VAR_Teeth.coord.x - xpos 
% 		+ (p->osl.offset - (VAR_Teeth.coord.x - CMP_TipCircle.coord.x)
%                   ) * p->osl.scale;
%   evaldeps(&GEO_Teeth2FloorX);
% 
% } /* mod_geo_Teeth2FloorX */

case 'Teeth2FloorX'
    GEO_Teeth2FloorX(3) = VAR_Teeth(1) - coords(1) + ...
        ( TUN_FloorX(3)- VAR_Teeth(1) + CMP_TipCircle(1) ) * TUN_FloorX(4); 
        

%   ============================================================================
%     MOD_GEO_TIPCIRCLERAD
%   ============================================================================

% void mod_geo_TipCircleRad(double xpos, double ypos)
% {
%   double dx, dy;
% 
%   dx = xpos - CMP_TipCircle.coord.x;
%   dy = ypos - CMP_TipCircle.coord.y;
%   GEO_TipCircleRad.polar.len = sqrt( dx*dx + dy*dy );
%   evaldeps(&GEO_TipCircleRad);
% 
% } /* mod_geo_TipCircleRad */

case 'TipCircleRad'
      GEO_TipCircleRad(3) = norm( coords - CMP_TipCircle(1:2) ); 


end % switch

refresh
