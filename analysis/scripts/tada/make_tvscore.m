function [TV_SCORE, ART] = make_tvscore(TV_SCORE, ART, ms_frm, last_frm)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
% generate gestural parameters directly from gestures ('PROM's)
% not from utterance name (e.g. make_tvscore)

load t_params
n_frm = (last_frm)*ms_frm/wag_frm;

nPRO = length(TV_SCORE(i_PRO).GEST);
nLA = length(TV_SCORE(i_LA).GEST);
nTTCD = length(TV_SCORE(i_TTCD).GEST);
nTTCL = length(TV_SCORE(i_TTCL).GEST);
nTTCR = length(TV_SCORE(i_TTCR).GEST);
nTBCD = length(TV_SCORE(i_TBCD).GEST);
nTBCL = length(TV_SCORE(i_TBCL).GEST);
nJAW = length(TV_SCORE(i_JAW).GEST);
nVEL = length(TV_SCORE(i_VEL).GEST);
nGLO = length(TV_SCORE(i_GLO).GEST);
nF0 = length(TV_SCORE(i_F0).GEST);
nPI = length(TV_SCORE(i_PI).GEST);
nSPI = length(TV_SCORE(i_SPI).GEST);
nTR = length(TV_SCORE(i_TR).GEST);

TV_SCORE = make_PROMSUM (TV_SCORE, i_PRO, nPRO, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_LA, nLA, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TTCD, nTTCD, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TTCL, nTTCL, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TTCR, nTTCR, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TBCD, nTBCD, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TBCL, nTBCL, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_JAW, nJAW, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_VEL, nVEL, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_GLO, nGLO, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_F0, nF0, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_PI, nPI, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_SPI, nSPI, ms_frm, last_frm);
TV_SCORE = make_PROMSUM (TV_SCORE, i_TR, nTR, ms_frm, last_frm);

TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_LA, nLA);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_F0, nF0);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_PI, nPI);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TR, nTR);

TV_SCORE = make_PROM_BLEND (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_LA, nLA);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_F0, nF0);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_PI, nPI);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TR, nTR);

TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_LA, nLA);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_F0, nF0);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_PI, nPI);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TR, nTR);

TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_LA, nLA);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_F0, nF0);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_PI, nPI);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TR, nTR);

TV_SCORE = make_d_BLEND (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_d_BLEND (TV_SCORE, i_LA, nLA);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_d_BLEND (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_d_BLEND (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_d_BLEND (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_d_BLEND (TV_SCORE, i_F0, nF0);
TV_SCORE = make_d_BLEND (TV_SCORE, i_PI, nPI);
TV_SCORE = make_d_BLEND (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_d_BLEND (TV_SCORE, i_TR, nTR);

TV_SCORE = make_k_BLEND (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_k_BLEND (TV_SCORE, i_LA, nLA);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_k_BLEND (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_k_BLEND (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_k_BLEND (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_k_BLEND (TV_SCORE, i_F0, nF0);
TV_SCORE = make_k_BLEND (TV_SCORE, i_PI, nPI);
TV_SCORE = make_k_BLEND (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_k_BLEND (TV_SCORE, i_TR, nTR);

TV_SCORE = make_x_BLEND (TV_SCORE, i_PRO, nPRO);
TV_SCORE = make_x_BLEND (TV_SCORE, i_LA, nLA);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TTCD, nTTCD);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TTCL, nTTCL);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TTCR, nTTCR);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TBCD, nTBCD);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TBCL, nTBCL);
TV_SCORE = make_x_BLEND (TV_SCORE, i_JAW, nJAW);
TV_SCORE = make_x_BLEND (TV_SCORE, i_VEL, nVEL);
TV_SCORE = make_x_BLEND (TV_SCORE, i_GLO, nGLO);
TV_SCORE = make_x_BLEND (TV_SCORE, i_F0, nF0);
TV_SCORE = make_x_BLEND (TV_SCORE, i_PI, nPI);
TV_SCORE = make_x_BLEND (TV_SCORE, i_SPI, nSPI);
TV_SCORE = make_x_BLEND (TV_SCORE, i_TR, nTR);

TV_SCORE = make_WGT_TV (TV_SCORE, i_PRO, nPRO, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_LA, nLA, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TTCD, nTTCD, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TTCL, nTTCL, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TTCR, nTTCR, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TBCD, nTBCD, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TBCL, nTBCL, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_JAW, nJAW, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_VEL, nVEL, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_GLO, nGLO, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_F0, nF0, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_PI, nPI, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_SPI, nSPI, ms_frm, last_frm);
TV_SCORE = make_WGT_TV (TV_SCORE, i_TR, nTR, ms_frm, last_frm);

[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_LX, i_LX_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_JA, i_JA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_UY, i_UY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_LY, i_LY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_CL, i_CL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_CA, i_CA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_TL, i_TL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_TA, i_TA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_NA, i_NA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_GW, i_GW_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_F0a, i_F0a_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_PIa, i_PIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_SPIa, i_SPIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_HX, i_HX_TV, ms_frm, last_frm);

[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_LX);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_JA);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_UY);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_LY);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_CL);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_CA);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_TL);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_TA);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_NA);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_GW);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_F0a);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_PIa);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_SPIa);
[TV_SCORE ART] = make_PROM_NEUT(TV_SCORE, ART, i_HX);

[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_LX, i_LX_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_JA, i_JA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_UY, i_UY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_LY, i_LY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_CL, i_CL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_CA, i_CA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_TL, i_TL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_TA, i_TA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_NA, i_NA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_GW, i_GW_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_F0a, i_F0a_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_PIa, i_PIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_SPIa, i_SPIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_HX, i_HX_TV, ms_frm, last_frm);

[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_LX, i_LX_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_JA, i_JA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_UY, i_UY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_LY, i_LY_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_CL, i_CL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_CA, i_CA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_TL, i_TL_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_TA, i_TA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_NA, i_NA_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_GW, i_GW_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_F0a, i_F0a_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_PIa, i_PIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_SPIa, i_SPIa_TV, ms_frm, last_frm);
[TV_SCORE ART] = make_TOTWGT(TV_SCORE, ART, i_HX, i_HX_TV, ms_frm, last_frm);

TV_SCORE = make_PROM_ACT (TV_SCORE, i_PRO);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_LA);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TTCD);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TTCL);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TTCR);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TBCD);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TBCL);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_JAW);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_VEL);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_GLO);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_F0);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_PI);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_SPI);
TV_SCORE = make_PROM_ACT (TV_SCORE, i_TR);


function TV_SCORE = make_PROMSUM (TV_SCORE, i_TV, nGEST, ms_frm, last_frm)                                            
%n_frm = (last_frm)*ms_frm/wag_frm;
%***** Saltzman : make_PROM_ACT_JNT uses PROMSUM of ten different TVs differently from wag sources(PROMSUM on CSTR)
% no empty matrix allowed, PROMSUM(i_PRO) not specified optionally in TV...G should = PROMSUM(i_LA)
% the statement above is no longer valid. (11/3/2005) because 'PROMSUM' is initialized by zeros(1,n_frm) in make_gest...

for i = 1:nGEST
    TV_SCORE(i_TV).TV.PROMSUM = TV_SCORE(i_TV).TV.PROMSUM + TV_SCORE(i_TV).GEST(i).PROM;
end

function TV_SCORE = make_PROMSUM_BLEND (TV_SCORE, i_TV, nGEST)
for i = 1 : nGEST
    for j = 1 : nGEST
        TV_SCORE(i_TV).GEST(i).x.PROMSUM_BLEND = TV_SCORE(i_TV).GEST(i).x.PROMSUM_BLEND +...
            TV_SCORE(i_TV).GEST(j).x.ALPHA * TV_SCORE(i_TV).GEST(j).PROM;
        TV_SCORE(i_TV).GEST(i).k.PROMSUM_BLEND = TV_SCORE(i_TV).GEST(i).k.PROMSUM_BLEND +...
            TV_SCORE(i_TV).GEST(j).k.ALPHA * TV_SCORE(i_TV).GEST(j).PROM;
        TV_SCORE(i_TV).GEST(i).d.PROMSUM_BLEND = TV_SCORE(i_TV).GEST(i).d.PROMSUM_BLEND +...
            TV_SCORE(i_TV).GEST(j).d.ALPHA * TV_SCORE(i_TV).GEST(j).PROM;
        TV_SCORE(i_TV).GEST(i).w.PROMSUM_BLEND = TV_SCORE(i_TV).GEST(i).w.PROMSUM_BLEND +...
            TV_SCORE(i_TV).GEST(j).w.ALPHA * TV_SCORE(i_TV).GEST(j).PROM;
    end
    TV_SCORE(i_TV).GEST(i).x.PROMSUM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).x.PROMSUM_BLEND - ...
        TV_SCORE(i_TV).GEST(i).x.ALPHA * TV_SCORE(i_TV).GEST(i).PROM;
    TV_SCORE(i_TV).GEST(i).k.PROMSUM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).k.PROMSUM_BLEND - ...
        TV_SCORE(i_TV).GEST(i).k.ALPHA * TV_SCORE(i_TV).GEST(i).PROM;
    TV_SCORE(i_TV).GEST(i).d.PROMSUM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).d.PROMSUM_BLEND - ...
        TV_SCORE(i_TV).GEST(i).d.ALPHA * TV_SCORE(i_TV).GEST(i).PROM;
    TV_SCORE(i_TV).GEST(i).w.PROMSUM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).w.PROMSUM_BLEND - ...
        TV_SCORE(i_TV).GEST(i).w.ALPHA*TV_SCORE(i_TV).GEST(i).PROM;
end


function TV_SCORE = make_PROM_BLEND (TV_SCORE, i_TV, nGEST)
for i = 1:nGEST
    TV_SCORE(i_TV).GEST(i).x.PROM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).PROM./ (1+TV_SCORE(i_TV).GEST(i).x.BETA ...
        * TV_SCORE(i_TV).GEST(i).x.PROMSUM_BLEND);
    TV_SCORE(i_TV).GEST(i).k.PROM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).PROM./ (1+TV_SCORE(i_TV).GEST(i).k.BETA ...
        * TV_SCORE(i_TV).GEST(i).k.PROMSUM_BLEND);
    TV_SCORE(i_TV).GEST(i).d.PROM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).PROM./ (1+TV_SCORE(i_TV).GEST(i).d.BETA ...
        * TV_SCORE(i_TV).GEST(i).d.PROMSUM_BLEND);
    TV_SCORE(i_TV).GEST(i).w.PROM_BLEND = ...
        TV_SCORE(i_TV).GEST(i).PROM./ (1+TV_SCORE(i_TV).GEST(i).w.BETA ...
        * TV_SCORE(i_TV).GEST(i).w.PROMSUM_BLEND);
end


function TV_SCORE = make_PROMSUM_BLEND_SYN (TV_SCORE, i_TV, nGEST)
ALPHA = 1; % "gate keeper" equations omitted since "gatekeeper" = 1.0
for i = 1 : nGEST
    for j = 1 : nGEST
        TV_SCORE(i_TV).GEST(i).PROMSUM_BLEND_SYN = TV_SCORE(i_TV).GEST(i).PROMSUM_BLEND_SYN +...
            ALPHA * TV_SCORE(i_TV).GEST(j).PROM;
    end
    TV_SCORE(i_TV).GEST(i).PROMSUM_BLEND_SYN = ...
        TV_SCORE(i_TV).GEST(i).PROMSUM_BLEND_SYN - ...
        ALPHA * TV_SCORE(i_TV).GEST(i).PROM;
end


function TV_SCORE = make_PROM_BLEND_SYN (TV_SCORE, i_TV, nGEST)
BETA = 1; % "lateral inhibition" equation omitted since "lateral inhibition" = 1.0
for i = 1:nGEST
    TV_SCORE(i_TV).GEST(i).PROM_BLEND_SYN = ...
        TV_SCORE(i_TV).GEST(i).PROM./ (1+BETA ...
        * TV_SCORE(i_TV).GEST(i).PROMSUM_BLEND_SYN);
end


function TV_SCORE = make_d_BLEND (TV_SCORE, i_TV, nGEST)
for i = 1:nGEST
    TV_SCORE(i_TV).TV.d_BLEND = TV_SCORE(i_TV).TV.d_BLEND + TV_SCORE(i_TV).GEST(i).d.PROM_BLEND * TV_SCORE(i_TV).GEST(i).d.VALUE;
end


function TV_SCORE = make_k_BLEND (TV_SCORE, i_TV, nGEST)
for i = 1:nGEST
    TV_SCORE(i_TV).TV.k_BLEND = TV_SCORE(i_TV).TV.k_BLEND + TV_SCORE(i_TV).GEST(i).k.PROM_BLEND * TV_SCORE(i_TV).GEST(i).k.VALUE;
end


function TV_SCORE = make_x_BLEND (TV_SCORE, i_TV, nGEST)
% parameters initialization
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
            120; ...  %F0
            0; ...
            0; ...
            0];
        
for i = 1:nGEST
    % old x_blend 
    %TV_SCORE(i_TV).TV.x_BLEND = TV_SCORE(i_TV).TV.x_BLEND + TV_SCORE(i_TV).GEST(i).x.PROM_BLEND * (TV_SCORE(i_TV).GEST(i).x.VALUE);

    % new x_blend by Elliot
    % use this new x.PROM_BLEND... x.PROM_BLEND*(x0-neut_tv) instead of x.PROM_BLEND*x0
    % in task_dynamics.m, use this new X_BLEND ... (tv_n + x_BLEND') instead of x_BLEND'
    TV_SCORE(i_TV).TV.x_BLEND = TV_SCORE(i_TV).TV.x_BLEND + TV_SCORE(i_TV).GEST(i).x.PROM_BLEND * (TV_SCORE(i_TV).GEST(i).x.VALUE-tv_n(i_TV));
end


function TV_SCORE = make_WGT_TV (TV_SCORE, i_TV, nGEST, ms_frm, last_frm)                                            
% parameters initialization
wag_frm = 5;
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

n_frm = (last_frm)*ms_frm/wag_frm;
switch i_TV 
    %***** Saltzman : by definition, WGT_TV(i_JA/i_NA/i_GW) should be 1.
case i_JAW 
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_JA) = ones(n_frm, 1);
case i_VEL
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_NA) = ones(n_frm, 1);
case i_GLO
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_GW) = ones(n_frm, 1);
case i_F0
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_F0a) = ones(n_frm, 1);
case i_PI
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_PIa) = ones(n_frm, 1);
case i_SPI
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_SPIa) = ones(n_frm, 1);
case i_HX
    TV_SCORE(i_TV).TV.WGT_TV = zeros(n_frm, nARTIC);
    TV_SCORE(i_TV).TV.WGT_TV(:, i_HX) = ones(n_frm, 1);
otherwise
    TV_SCORE(i_TV).TV.WGT_TV = TV_SCORE(i_TV).GEST(1).PROM_BLEND_SYN' * TV_SCORE(i_TV).GEST(1).w.VALUE;
    for i = 2:nGEST
        TV_SCORE(i_TV).TV.WGT_TV = TV_SCORE(i_TV).TV.WGT_TV + TV_SCORE(i_TV).GEST(i).PROM_BLEND_SYN' * TV_SCORE(i_TV).GEST(i).w.VALUE;
    end
end


function [TV_SCORE, ART] = make_PROM_ACT_JNT(TV_SCORE, ART, i_ARTIC, i_ARTIC_TV, ms_frm, last_frm)
% parameters initialization
wag_frm = 5;

n_frm = (last_frm)*ms_frm/wag_frm;
MAXPROM_JNT = 1;
PROMSUM_sum = zeros(1,n_frm);
for i = 1:length(i_ARTIC_TV)
    PROMSUM_sum = PROMSUM_sum + TV_SCORE(i_ARTIC_TV(i)).TV.PROMSUM;
end
ART(i_ARTIC).PROM_ACT_JNT = min (MAXPROM_JNT, PROMSUM_sum);


function [TV_SCORE, ART] = make_PROM_NEUT (TV_SCORE, ART, i_ARTIC)
ART(i_ARTIC).PROM_NEUT = 1.0 - ART(i_ARTIC).PROM_ACT_JNT;


function [TV_SCORE, ART] = make_PROMSUM_JNT(TV_SCORE, ART, i_ARTIC, i_ARTIC_TV, ms_frm, last_frm)
% parameters initialization
wag_frm = 5;
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

n_frm = (last_frm)*ms_frm/wag_frm;
PROMSUM_sum = zeros(1,n_frm);
for i = 1:length(i_ARTIC_TV)
    PROMSUM_sum = PROMSUM_sum + TV_SCORE(i_ARTIC_TV(i)).TV.PROMSUM;
end
ART(i_ARTIC).PROMSUM_JNT = PROMSUM_sum + ART(i_ARTIC).PROM_NEUT;


function TV_SCORE = make_PROM_ACT(TV_SCORE, i_TV)
% parameters initialization
i_TTCR = 10;


MAXPROM = 1;
TV_SCORE(i_TV).TV.PROM_ACT = min (MAXPROM, ceil(TV_SCORE(i_TV).TV.PROMSUM));
if i_TV == i_TTCR
    TV_SCORE(i_TV).TV.PROM_ACT = zeros(1, length(TV_SCORE(i_TV).TV.PROM_ACT));
end


function [TV_SCORE, ART] = make_TOTWGT(TV_SCORE, ART, i_ARTIC, i_ARTIC_TV, ms_frm, last_frm)
% parameters initialization
wag_frm = 5;


n_frm = (last_frm)*ms_frm/wag_frm;
PROMSUM_WGT_sum = zeros(1,n_frm);
PROMSUM_sum = zeros(1,n_frm);
WGT_NEUT = 1.0;

for i = 1:length(i_ARTIC_TV)
    PROMSUM_WGT_sum = PROMSUM_WGT_sum + min(1, TV_SCORE(i_ARTIC_TV(i)).TV.PROMSUM) .* TV_SCORE(i_ARTIC_TV(i)).TV.WGT_TV(:,i_ARTIC)';
    PROMSUM_sum = PROMSUM_sum + min(1, TV_SCORE(i_ARTIC_TV(i)).TV.PROMSUM);
end
ART(i_ARTIC).TOTWGT = (PROMSUM_WGT_sum + ART(i_ARTIC).PROM_NEUT * WGT_NEUT)...
    ./(PROMSUM_sum + ART(i_ARTIC).PROM_NEUT);