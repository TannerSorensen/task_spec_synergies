
% read/execute parameter/script file

function readpar( fileName )

% Copyright Haskins Laboratories, Inc., 2001-2004
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

% what is the name of the script file?
if nargin < 1 
  fileName = []; 
end;
if findstr(fileName, '*'),
  mask = fileName;
  fileName = [];
else
  mask = '*.par';
end;

if isempty(fileName),
  [file, pathName] = uigetfile(mask, 'Select Haskins format PCM file');
  if file == 0 
    return; 
  end;
fileName = [pathName file];
end;

% copy script (*.par) file to temporary *.m file
tmp_name = tempname;
tmp_name1 = [tmp_name '.m'];
[filler, tmp_name2, filler2, filler3] = fileparts( tmp_name );

[status, message, messageid] = copyfile( fileName, tmp_name1  );
if status == 0
  error( message );
  return
end



% list the common global parameters; 
% otherwise it would be necessary to define them in all
% parameter files.
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
global SRC_F0          % fundamental frequency in Hz, usually 100 Hz
global SRC_OpenQuotient 
global SRC_SpeedQuotient 
global SRC_SourceAmp 
global SRC_FricAmp 
global SRC_FricLoc 
global SRC_GlotWidth 
global SRC_GlotTens 
global SRC_SubGlotP 

global SEG_Bezier_fix_Velum_VelMax
global SEG_Bezier_fix_VelMax_Maxilla
global SEG_Bezier_fix_Maxilla_Alveolus


global soundDuration; % seconds 
global sampPerSec; % samples per second



% save the curent search path, add the temporary directory,
% execute temporary script, and restore path
savePath = path;
addpath( tempdir );
eval( tmp_name2 );
path( savePath );


%clean up
delete( tmp_name1 )
