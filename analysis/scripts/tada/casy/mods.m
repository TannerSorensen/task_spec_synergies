% modifies model after changing of parameter

function mods( s ) % s - name of changed parameter

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



coords0 = get( get( gcbf, 'CurrentAxes' ), 'CurrentPoint' ); 
coords = coords0(1, 1:2);  % the screen cursor points here


switch( s )

% ====== Grid Center ====

case 'TUN_GridCenter'

    TUN_GridCenter = coords; 

% ====== Geo Parameters ====

case 'GEO_FixTerminus'
    d = coords - FIX_Lip(1:2); 
    GEO_FixTerminus(3) = norm(d);
    GEO_FixTerminus(4) = atan2( d(2), d(1) );

case 'GEO_VarTerminus'
    d = coords - VAR_Lip(1:2);
    GEO_VarTerminus(3) = norm(d); 
    GEO_VarTerminus(4) = atan2( d(2), d(1) );

case 'GEO_Velum'
    coords(1) = max( coords(1), FIX_PharynxHi(1) ); 
    GEO_Velum(1:2) = coords; 
    d = coords - FIX_PharynxHi(1:2); 
    GEO_Velum(3) = norm(d); 
    GEO_Velum(4) = atan2(d(2), d(1) );  % verify sign and degrees / radians
    
case 'GEO_Hyoid2Epi'
    GEO_Hyoid2Epi(1) = VAR_Hyoid(1) - coords(1); 
    GEO_Hyoid2Epi(2) = - VAR_Hyoid(2) + coords(2);  

case 'GEO_Hyoid2LarEpiY'
    GEO_Hyoid2LarEpiY(3) = VAR_Hyoid(2) - coords(2) + ...
    TUN_LarEpiY(4) * ( VAR_Hyoid(1) - FIX_PharynxLo(1) - TUN_LarEpiY(3) ); 

case 'GEO_Hyoid2LarynxY'
    GEO_Hyoid2LarynxY(3) = VAR_Hyoid(2) - coords(2);

case 'GEO_Teeth2FloorTeeth'
    d = VAR_Teeth(1:2) - coords; 
    GEO_Teeth2FloorTeeth(3) = norm(d); 
    GEO_Teeth2FloorTeeth(4) = atan2(d(2),d(1)) - KEY_Jaw(4); 
    
case 'GEO_FixTeeth2TeethLip'
    GEO_FixTeeth2TeethLip(3) = coords(1) - FIX_Teeth(1); 

case 'GEO_VarTeeth2TeethLip'
    GEO_VarTeeth2TeethLip(3) = coords(1) - VAR_Teeth(1);   

case 'GEO_Teeth2FloorX'
    GEO_Teeth2FloorX(3) = VAR_Teeth(1) - coords(1) + ...
        ( TUN_FloorX(3)- VAR_Teeth(1) + CMP_TipCircle(1) ) * TUN_FloorX(4);         

case 'GEO_TipCircleRad'
      GEO_TipCircleRad(3) = norm( coords - CMP_TipCircle(1:2) ); 

% =====  Key parameters =====

case 'KEY_FixLip'
    KEY_FixLip(1:2) = coords - FIX_Teeth(1:2) - KEY_VarLip(1:2);
        % verify the sign for y!!!

case 'KEY_VarLip'
  KEY_VarLip(1:2) = coords - GEO_Condyle(1:2) - ...
      KEY_Jaw(3) * [ cos( KEY_Jaw(4) ) sin( KEY_Jaw(4) ) ];

case 'KEY_TongueCircle'
    d = coords - GEO_Condyle(1:2);
    KEY_TongueCircle(3) = norm(d);
    KEY_TongueCircle(4) = atan2( d(2), d(1) ) - KEY_Jaw(4);
    
case 'KEY_TongueCircleRad'
    KEY_TongueCircleRad(3) = norm( coords - CMP_TongueCircle(1:2) );
    
case 'KEY_Jaw'
    d = coords - GEO_Condyle(1:2);
    KEY_Jaw(3) = norm( d );
    KEY_Jaw(4) = atan2( d(2), d(1) );

case 'KEY_TipCircle'
    a = KEY_Jaw(4) + GEO_BladeOrigin(4) + KEY_BladeOriginOffset(4);
    d = coords - CMP_TongueCircle(1:2) - ...
        KEY_TongueCircleRad(3) * [ cos(a) sin(a) ];
    KEY_TipCircle(3) = norm( d );
    KEY_TipCircle(4) = atan2( d(2), d(1) ) - KEY_Jaw(4) - CMP_TipTracking(4);
        
case 'KEY_BladeOriginOffset'
    KEY_BladeOriginOffset(4) = 2 * ( ...
        acos( ( coords(1) - CMP_TongueCircle(1) ) / KEY_TongueCircleRad(3) ) ...
        - CMP_FrontFactor(3 ) ) ...
      - CMP_TipCircle(4) - pi;  
    
case 'KEY_RootOffset'
    KEY_RootOffset(3) = ( coords(1) - ...
                          .5 * (VAR_Hyoid(1) + CMP_HyoidTongTan(1) ) ... 
			 ) / cos( CMP_Root(4) ) - CMP_Root(3);

case 'KEY_Hyoid'
    KEY_Hyoid(1:2) = coords;
    
case 'KEY_Nasal'
    co = cos( GEO_Velum(4) ); % !!! verify degrees/radians
    x = max( coords(1) - FIX_PharynxHi(1), 0 );
    KEY_Nasal(3) = min( x/co/GEO_Velum(3)^2, 1 );

end % of the long switch

refresh
