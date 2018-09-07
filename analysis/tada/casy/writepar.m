% write parameters (static)

function writepar( fileName )

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

% in what file to save
if nargin < 1 
  fileName = []; 
end

if isempty( fileName )
  [file pathName] = uiputfile( '.par', 'Save parameters file.' );
  if file == 0 
    return
  end
  fileName = [pathName file];
end


[fid msg] = fopen( fileName, 'wt' );
if fid == -1
  error( [ 'Cannot open file '  fileName ' for writing.' '\n' msg ] )
  return
end



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




% coordinates in mm, radians
% 11.2 "mermels" in mm (112 in cm)

put1par( FIX_Larynx, fid )
put1par( FIX_Periarytenoid, fid )
put1par( FIX_PharynxLo, fid )
put1par( FIX_PharynxHi, fid )
put1par( FIX_Velum, fid )
put1par( FIX_VelMax, fid )
put1par( FIX_Maxilla, fid )
put1par( FIX_Alveolus, fid )
put1par( FIX_Teeth, fid )
put1par( FIX_TeethLip, fid )
put1par( FIX_Lip, fid )
put1par( FIX_Terminus, fid )
put1par( VAR_Larynx, fid )
put1par( VAR_LarEpi, fid )
put1par( VAR_Epiglottis, fid )
put1par( VAR_Hyoid, fid )
put1par( VAR_Root, fid )
put1par( VAR_RootTong, fid )
put1par( VAR_TongBlade, fid )
put1par( VAR_BladeTip, fid )
put1par( VAR_TipFloor, fid )
put1par( VAR_Floor, fid )
put1par( VAR_FloorTeeth, fid )
put1par( VAR_Teeth, fid )
put1par( VAR_TeethLip, fid )
put1par( VAR_Lip, fid )
put1par( VAR_Terminus, fid )
put1par( KEY_FixLip, fid )
put1par( KEY_VarLip, fid )
put1par( KEY_TongueCircle, fid )
put1par( KEY_TongueCircleRad, fid )
put1par( KEY_Jaw, fid )
put1par( KEY_TipCircle, fid )
put1par( KEY_BladeOriginOffset, fid )
put1par( KEY_RootOffset, fid )
put1par( KEY_Hyoid, fid )
put1par( KEY_Nasal, fid )
put1par( GEO_Condyle, fid )
put1par( GEO_FixTerminus, fid )
put1par( GEO_VarTerminus, fid )
put1par( GEO_Velum, fid )
put1par( GEO_Hyoid2Epi, fid )
put1par( GEO_Hyoid2LarEpiY, fid )
put1par( GEO_Hyoid2LarynxY, fid )
put1par( GEO_Teeth2FloorTeeth, fid )
put1par( GEO_FixTeeth2TeethLip, fid )
put1par( GEO_VarTeeth2TeethLip, fid )
put1par( GEO_Teeth2FloorX, fid )
put1par( GEO_BladeOrigin, fid )
put1par( GEO_TipCircleRad, fid )
put1par( CMP_BladeOrigin, fid )
put1par( CMP_BladeCircle, fid )
put1par( CMP_BladeCircleRad, fid )
put1par( CMP_TongBlade, fid )
put1par( CMP_FrontFactor, fid )
put1par( CMP_Floor2Teeth, fid )
put1par( CMP_TipCircle, fid )
put1par( CMP_TipTracking, fid )
put1par( CMP_Root, fid )
put1par( CMP_HyoidTongTan, fid )
put1par( CMP_TongueCircle, fid )
put1par( CMP_Velum, fid )
put1par( TUN_LarEpiY, fid )
put1par( TUN_VarLarynxX, fid )
put1par( TUN_FrontFactor, fid )
put1par( TUN_TipTracking, fid )

fprintf( fid, '%% linearise transformation of coord/length to angle\n' );
put1par( TUN_Root, fid )
put1par( TUN_FloorX, fid )
put1par( TUN_GridCenter, fid )

put1par( TUN_PharAdjGlot, fid )
put1par( TUN_PharAdjPeri, fid )
put1par( TUN_PharAdjHyoid, fid )
put1par( TUN_PharAdjRoot, fid )
put1par( TUN_LipWidth, fid )

put1par( TUN_SoftPalate, fid )
put1par( TUN_HardPalate, fid )

put1par( TUN_AlvNarrow, fid )

fprintf( fid, '%% min/max *10, offset*100 (was sq. cm.), scale *10\n' );

put1par( TUN_AlvMid, fid ) 
put1par( TUN_AlvWide, fid )

put1par( SRC_F0, fid )
put1par( SRC_OpenQuotient, fid )
put1par( SRC_SpeedQuotient, fid )
put1par( SRC_SourceAmp, fid )
put1par( SRC_FricAmp, fid )
put1par( SRC_FricLoc, fid )
put1par( SRC_GlotWidth, fid )
put1par( SRC_GlotTens, fid )
put1par( SRC_SubGlotP, fid )


global SEG_Bezier_fix_Velum_VelMax
global SEG_Bezier_fix_VelMax_Maxilla
global SEG_Bezier_fix_Maxilla_Alveolus

put1par( SEG_Bezier_fix_Velum_VelMax, fid )
put1par( SEG_Bezier_fix_VelMax_Maxilla, fid )
put1par( SEG_Bezier_fix_Maxilla_Alveolus, fid )


global soundDuration; % seconds 
global sampPerSec; % samples per second

put1par( soundDuration, fid ) 
put1par( sampPerSec, fid ) 



% internal worker function
function put1par( par, fd )

fprintf( fd, '%s = [', inputname(1) );

sz = size( par );

if length( sz ) > 2
  return
end

for i = 1:sz(1) 
  fprintf( fd, ' %1.3f', par(i,:) );
  if i < sz(1)
    fprintf( fd, ';' );
  end
end
fprintf( fd, ' ];\n' ); 
