% init.m is inialization

function init

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

pts % include pts.m - list of global for data 

% coordinates in mm, radians
% 11.2 "mermels" in mm (112 in cm)
FIX_Larynx = [748/11.2 530/11.2 ];
FIX_Periarytenoid = [718/11.2  703/11.2 ];
FIX_PharynxLo = [618/11.2  703/11.2 ];
FIX_PharynxHi = [618/11.2  1392/11.2 ];
FIX_Velum = [ 618/11.2  1392/11.2  ];
FIX_VelMax = [704/11.2  1495/11.2 ];
FIX_Maxilla = [986/11.2  1637/11.2 ];
FIX_Alveolus = [1326/11.2  1512/11.2 ];
FIX_Teeth = [1438/11.2  1470/11.2 ];
FIX_TeethLip = [1458/11.2  1459/11.2 ];
FIX_Lip = [1540/11.2  1459/11.2 ];
FIX_Terminus = [1589.5/11.2  1508.5/11.2 ];
VAR_Larynx = [925/11.2  530/11.2 ];
VAR_LarEpi = [750/11.2  756/11.2 ];
VAR_Epiglottis = [750/11.2  830/11.2 ];
VAR_Hyoid= [ 800/11.2  830/11.2 ];
VAR_Root = [792.509/11.2  1049.38/11.2 ];
VAR_RootTong = [736.018/11.2  1227.68/11.2 ];
VAR_TongBlade = [1029.37/11.2  1514.88/11.2 ];
VAR_BladeTip = [1277.53/11.2  1322.92/11.2 ];
VAR_TipFloor = [1280.81/11.2  1312.79/11.2 ];
VAR_Floor = [1274.31/11.2  1160.11/11.2 ];
VAR_FloorTeeth = [1286.01/11.2  1160.11/11.2 ];
VAR_Teeth = [1414.77/11.2  1350.69/11.2 ];
VAR_TeethLip = [1434.77/11.2  1361.69/11.2 ];
VAR_Lip = [1516.77/11.2  1361.69/11.2 ];
VAR_Terminus = [1566.27/11.2  1312.19/11.2 ];
KEY_FixLip = [0 0];
KEY_VarLip = [102/11.2  11/11.2 ];
KEY_TongueCircle = [0 0 856/11.2  -0.21];
KEY_TongueCircleRad = [0 0 230/11.2  0];
KEY_Jaw = [0 0 1264/11.2  -0.28];
KEY_TipCircle = [0 0 350/11.2  0];
KEY_BladeOriginOffset = [0 0 0 0];
KEY_RootOffset = [0 0 0 0];
KEY_Hyoid = [800/11.2  830/11.2 ];
KEY_Nasal = [0 0 0 0 ];
GEO_Condyle = [200/11.2  1700/11.2 ];
GEO_FixTerminus = [0 0 70/11.2  pi/4];
GEO_VarTerminus = [0 0 70/11.2  -pi/4];
GEO_Velum = [0 0 28/11.2  -pi/4];
GEO_Hyoid2Epi = [50/11.2  0];
GEO_Hyoid2LarEpiY = [0 0 130/11.2  0];
GEO_Hyoid2LarynxY = [0 0 300/11.2  0];
GEO_Teeth2FloorTeeth = [0 0 230/11.2  1.2566];
GEO_FixTeeth2TeethLip = [0 0 20/11.2  0];
GEO_VarTeeth2TeethLip = [0 0 20/11.2  0];
GEO_Teeth2FloorX = [0 0 400/11.2  0];
GEO_BladeOrigin = [0 0 0 1.7279];
GEO_TipCircleRad = [0 0 20/11.2 0];
CMP_BladeOrigin = [983.472/11.2  1525.41/11.2 ];
CMP_BladeCircle = [873.598/11.2  1057.12/11.2 ];
CMP_BladeCircleRad = [ 0 0 -483.544/11.2  0];
CMP_TongBlade = [0 0 0 1.2428];
CMP_FrontFactor = [0 0 0 0 ];
CMP_Floor2Teeth = [0 0 0 0.9766];
CMP_TipCircle = [1260.83/11.2  1311.93/11.2  350/11.2  -0.656];
CMP_TipTracking = [0 0 0 -0.376];
CMP_Root = [0 0 28.6949/11.2  0.165235];
CMP_HyoidTongTan = [728.41/11.2  1259.31/11.2 ];
CMP_TongueCircle = [955.277/11.2  1297.14/11.2 ];
CMP_Velum = [618/11.2  1392/11.2 ];
TUN_LarEpiY = [0 0 532/11.2  -0.16];
TUN_VarLarynxX = [0 232/11.2  232/11.2  0.5];
TUN_FrontFactor = [0 0 350/11.2  0.004];
TUN_TipTracking = [830/11.2  910/11.2  -950/11.2  0.004*11.2];
  % the last coefficient linearise transformation of coord/length to angle
TUN_Root = [0 0 384/11.2  0.56];
TUN_FloorX = [0 0 500/11.2  0.75];
TUN_GridCenter = [990/11.2  1189/11.2 ];

TUN_PharAdjGlot = [0 0 0 1.5]; 
TUN_PharAdjPeri = [0 0 0 2];
TUN_PharAdjHyoid = [0 0 0 2.5];
TUN_PharAdjRoot = [0 0 0 3];
TUN_LipWidth = [0 0 2 1.5];

% TUN_SoftPalate = [0 0 0 2.66667];
% TUN_HardPalate = [0 0 0 2];
TUN_SoftPalate = [0 0 0 2.66667*10^0.5]; % adjust from cm to mm
TUN_HardPalate = [0 0 0 2*10^0.5];

% wrong: measures was in cm, or cm^2, not mermels 
% TUN_AlvNarrow = [0.5/11.2  0 0 1.5];
% TUN_AlvMid = [2/11.2  0 3/11.2  0.75];
% TUN_AlvWide = [0 0 5.25/11.2  5];
TUN_AlvNarrow = [5  0 0 15]; % min/max *10, offset*100 (was sq. cm.), scale *10
TUN_AlvMid = [20  0 300  7.5]; 
TUN_AlvWide = [0 0 525  50];

SRC_F0 = [100]; % fundamental frequency in Hz, usually 100 Hz
SRC_OpenQuotient = [0.5];
SRC_SpeedQuotient = [3];
SRC_SourceAmp = [100];
SRC_FricAmp = [0];
SRC_FricLoc = [0];
SRC_GlotWidth = [0];
SRC_GlotTens = [0];
SRC_SubGlotP = [0];


global SEG_Bezier_fix_Velum_VelMax
global SEG_Bezier_fix_VelMax_Maxilla
global SEG_Bezier_fix_Maxilla_Alveolus

SEG_Bezier_fix_Velum_VelMax = [ [ 648.0/11.2, 1380.0/11.2 ]
				[ 667.0/11.2, 1457.0/11.2 ] ];
SEG_Bezier_fix_VelMax_Maxilla = [ [ 760.0/11.2, 1567.0/11.2 ]
                                  [ 883.0/11.2, 1630.0/11.2 ] ];
SEG_Bezier_fix_Maxilla_Alveolus = [ [ 1147.0/11.2, 1634.0/11.2 ]
                                    [ 1257.0/11.2, 1571.0/11.2 ] ];


global soundDuration; % seconds 
global sampPerSec; % samples per second

soundDuration = 0.5; % 1/2 sec  
sampPerSec = 22050; % 1/2 max for CD, and close to 20KHz used in ASY, MCASY



global numOfWindows;
numOfWindows = 4;

global minBrightness
global maxBrightness
minBrightness = 64;
maxBrightness = 256;


global minXPict
global maxXPict
global minYPict
global maxYPict

minXPict = 0;
maxXPict = 150;
minYPict = 0;
maxYPict = 185;


