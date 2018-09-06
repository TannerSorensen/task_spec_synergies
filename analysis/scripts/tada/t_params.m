% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%

% clear all;

% TV index
i_LA = 2;
i_PRO = 1;
i_TBCD = 4;
i_TBCL = 3;
i_TTCD = 9;
i_TTCL = 8;
i_TTCR = 10;
i_JAW = 5;
i_VEL = 6;
i_GLO = 7;
i_F0 = 11;
i_PI = 12;
i_SPI = 13;
i_TR = 14;
nTV = 14;

% ARTIC index
i_LX = 1; %x(1)
i_JA = 2; %x(3)
i_UY = 3; %x(5)
i_LY = 4; %x(7)
i_CL = 5; %x(9)
i_CA = 6; %x(11)
i_TL = 9; %x(17)
i_TA = 10; %x(19)
i_NA = 7; %x(13)
i_GW = 8; %x(15)
i_F0a = 11;
i_PIa = 12;
i_SPIa = 13;
i_HX = 14;
nARTIC = 14;


% j index for sub group
i_LIP_PRO = 1;
i_LIP_LA = 2;

i_LIP_LX = 1;
i_LIP_JA = 2;
i_LIP_UY = 3;
i_LIP_LY = 4;

i_TB_TBCL = 1;
i_TB_TBCD = 2;

i_TB_JA = 1;
i_TB_CL = 2;
i_TB_CA = 3;

i_TT_TTCL = 1;
i_TT_TTCD = 2;
i_TT_TTCR = 3;

i_TT_JA = 1;
i_TT_CL = 2;
i_TT_CA = 3;
i_TT_TL = 4;
i_TT_TA = 5;

% i_CSTR_TV & i_CSTR_ARTIC
i_LIP_TV = [i_PRO, i_LA];
i_LIP_A = [i_LX, i_JA, i_UY, i_LY]; 

i_TB_TV = [i_TBCL, i_TBCD];
i_TB_A = [i_JA, i_CL, i_CA];

i_TT_TV = [i_TTCL, i_TTCD, i_TTCR];
i_TT_A = [i_JA, i_CL, i_CA, i_TL, i_TA];

% i_ARTIC_TV
i_LX_TV = [i_PRO];
i_JA_TV = [i_LA, i_TBCD, i_TBCL, i_JAW, i_TTCD, i_TTCL, i_TTCR];
i_UY_TV = [i_LA];
i_LY_TV = [i_LA];
i_CL_TV = [i_TBCD, i_TBCL, i_TTCD, i_TTCL, i_TTCR];
i_CA_TV = [i_TBCD, i_TBCL, i_TTCD, i_TTCL, i_TTCR];
i_TL_TV = [i_TTCD, i_TTCL, i_TTCR];
i_TA_TV = [i_TTCD, i_TTCL, i_TTCR];
i_NA_TV = [i_VEL];
i_GW_TV = [i_GLO];
i_F0a_TV = [i_F0];
i_PIa_TV = [i_PI];
i_SPIa_TV = [i_SPI];
i_HX_TV = [i_TR];


% i_ARTIC_CSTR
i_LX_CSTR = [i_PRO];
i_JA_CSTR = [i_LA, i_TBCD, i_JAW, i_TTCD];
i_UY_CSTR = [i_LA];
i_LY_CSTR = [i_LA];
i_CL_CSTR = [i_TBCD, i_TTCD];
i_CA_CSTR = [i_TBCD, i_TTCD];
i_TL_CSTR = [i_TTCD];
i_TA_CSTR = [i_TTCD];
i_NA_CSTR = [i_VEL];
i_GW_CSTR = [i_GLO];
i_F0a_CSTR = [i_F0];
i_PIa_CSTR = [i_PI];
i_SPIa_CSTR = [i_SPI];
i_HX_CSTR = [i_TR];

wag_frm = 5;

% conversion constants
mm_per_dec = 100; % mm to decimeter
mermels_per_mm = 11.2;    % mermel to mm
deg_per_rad = 180/pi;   % radian to degree   = 57.29577 

% ASY PARAMETER (converted to mm from mermels)
CONDYLE_LT.LEN = 1264 / mermels_per_mm/mm_per_dec;
CONDYLE_UT.LEN = 1281 / mermels_per_mm/mm_per_dec;
CONDYLE_UT.ANG = 1.382-pi/2;

TB_RAD = 224 / mermels_per_mm/mm_per_dec;
CONDYLE_FLOOR.X = 822 / mermels_per_mm/mm_per_dec;
CONDYLE_FLOOR.Y = -511 / mermels_per_mm/mm_per_dec;
TBSPACE_RAD = 448 / mermels_per_mm/mm_per_dec;
TCTTO_ANG = .55 * pi;
TBTT_LINK = 950 / mermels_per_mm/mm_per_dec;
TBTT_SCL = 4.48;  % NOTE: = .004 * 1120., WHERE 1120 = 1/MRCON = MULTIPLYING FACTOR FOR CONVERTING DECIMETERS TO MERMELS.

% ASYPEL constants (converted to mm from mermels)
rc = 230.000 / mermels_per_mm;
xf =  200.000 / mermels_per_mm;
yf = 1700.000 / mermels_per_mm;
rj = 1264.000 / mermels_per_mm;
utx = 1438.000 / mermels_per_mm;
uty = 1470.000 / mermels_per_mm;

RESTAN(i_LX) = 102/mermels_per_mm/mm_per_dec; 	% LIP HORIZ.
RESTAN(i_JA) = -.28 + pi/2;  
% =1.29 RAD(=73.96 DEG); NOTE: THE
%			+pi/2 FACTOR CONVERTS FROM ASY JAW ANGLES
%			(RT.HORIZ.=0 DEG.) TO TASK DYNAMIC JAW ANGLES
%			(DOWN.VERT.=0 DEG.).
RESTAN(i_UY) = -11/mermels_per_mm/mm_per_dec; 	% ULV
RESTAN(i_LY) = 11/mermels_per_mm/mm_per_dec; 		% LLV

% new neutral state of TBC
% RESTAN(i_CL) = 856/mermels_per_mm/mm_per_dec;   % TBR       def: 856
% RESTAN(i_CA) = -.21;  % TBA (RAD;= -12.O3 DEG)              def: -.21
% RESTAN(i_CL) = 823/mermels_per_mm/mm_per_dec;   % TBR       def: 856
% RESTAN(i_CA) = -.223;  % TBA (RAD;= -12.O3 DEG)              def: -.21

RESTAN(i_CL) = 856/mermels_per_mm/mm_per_dec;   % TBR       def: 856
RESTAN(i_CA) = -.21;  % TBA (RAD;= -12.O3 DEG)              def: -.21


% ga: 790 -.12, ta: 900, -.1

RESTAN(i_NA) = 0; 		% VH
RESTAN(i_GW) = 0; 		% GW
RESTAN(i_TL) = 350/mermels_per_mm/mm_per_dec; 	% TTR
RESTAN(i_TA) = 0;	% TTA (RAD;= 0. DEG)
RESTAN(i_F0a) = 125;
RESTAN(i_PIa) = 0;
RESTAN(i_SPIa) = 0;
RESTAN(i_HX) = 0;

FREQ(i_LX) = 10;   % FREQ. = HZ.
FREQ(i_JA) = 2;   % FREQ. = HZ.    %%%%%%%%%
FREQ(i_UY) = 2;   % FREQ. = HZ.
FREQ(i_LY) = 2;   % FREQ. = HZ.
FREQ(i_CL) = 2;   % FREQ. = HZ.
FREQ(i_CA) = 2;   % FREQ. = HZ.
FREQ(i_NA) = 5;   % FREQ. = HZ.
FREQ(i_GW) = 20;   % FREQ. = HZ.
FREQ(i_TL) = 2;   % FREQ. = HZ.
FREQ(i_TA) = 2;   % FREQ. = HZ.
FREQ(i_F0a) = 2;   % FREQ. = HZ.
FREQ(i_PIa) = 2;   % FREQ. = HZ.
FREQ(i_SPIa) = 2;   % FREQ. = HZ.
FREQ(i_HX) = 2;   % FREQ. = HZ.

ARTIC_DAMPRAT(i_LX) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_JA) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_UY) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_LY) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_CL) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_CA) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_NA) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_GW) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_TL) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_TA) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_F0a) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_PIa) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_SPIa) = 1;   % DAMPING RATIO = DIMENSIONLESS.
ARTIC_DAMPRAT(i_HX) = 1;   % DAMPING RATIO = DIMENSIONLESS.

FREQ = FREQ * 2.0 * pi;              % FREQ. = RAD/SEC
k_NEUT = FREQ.^2;                       % STIFFNESS.
d_NEUT = 2.0 * ARTIC_DAMPRAT .* FREQ;  % DAMPING COEFFICIENT.

NULL_KSCL = 0;
NULL_DSCL = 1;

hyoid = [7.142857142857143e+001 7.410714285714286e+001];

tv_n = [9.107142857142858e-002; ...
            7.758895341068778e-002; ...
            2.123609260162975e+000; ...
            8.654337753120089e-002; ...
            9.72e-002; ...      
            0; ...
            0; ...
            4.566455893664498e-001; ...
            1.631461248387526e-001; ...
            9.147963267948964e-001; ...
            120; ... %F0
            0; ... %PI
            0; ... %SPI
            0]; %TR
% def_area = [119.3725   83.9033  108.3140  218.5497 ...
%       307.3532  337.9718  314.3938  254.4072 ...
%       211.8935  178.8416  155.7782  154.7671 ...
%       162.3324  175.4414  204.1237  226.9290 ...
%       250.2022  332.6236  354.6639  288.3084 ...
%       848.0035];

% save t_params