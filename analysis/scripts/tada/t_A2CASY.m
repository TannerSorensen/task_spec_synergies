function t_A2CASY(A, cur_frm)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%

load t_params

% executing casy except plotting
global play
global plotGrid
init
eall
outline
c_grid
%=======================

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
global area
global tubeLengthSmooth

KEY_FixLip = [0 A(i_UY,cur_frm)*mm_per_dec];
KEY_VarLip  = [A(i_LX,cur_frm)*mm_per_dec A(i_LY,cur_frm)*mm_per_dec];
KEY_TongueCircle = [0 0 A(i_CL,cur_frm)*mm_per_dec A(i_CA,cur_frm)];
KEY_TongueCircleRad;
KEY_Jaw = [0 0 1264/11.2 A(i_JA,cur_frm)-pi/2];
KEY_TipCircle = [0 0 A(i_TL,cur_frm)*mm_per_dec A(i_TA,cur_frm)];
KEY_BladeOriginOffset;
KEY_RootOffset;
KEY_Hyoid;
KEY_Nasal = [0 0 0 A(i_NA,cur_frm)];

% executing refresh except plotting
eall
outline
c_grid
%==========================