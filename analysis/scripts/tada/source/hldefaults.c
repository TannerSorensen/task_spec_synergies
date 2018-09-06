/*
  ------------------------------------------------------------------------------------------------------------------
	H L D E F A U L T S . C   - initialize HLsyn to default values
 
    This procedure sets initial values for the low level (Klatt) and high level synthesizer
	based on default values obtained from the interactive version of HLsyn
 
	mkt 01/09
  ------------------------------------------------------------------------------------------------------------------ 
*/

#include "hlsyn.h"

/* low level speaker (KLS) */

Speaker defLLSpeaker = {
	550,	/* DU */
	55,		/* UI */
	11025,	/* SR */
	5,		/* NF */
	2,		/* SS */
	8,		/* RS */
	1,		/* SB */
	0,		/* CP */
	0,		/* OS */
	60,		/* GV */
	60,		/* GH */
	60		/* GF */
};

/* low level frame (KL) */

LLFrame defLLFrame = {
	1000.0,	/* F0 */
	60.0,	/* AV */
	50.0,	/* OQ */
	0.0,	/* SQ */
	5.0,	/* TL */
	0.0,	/* FL */
	0.0,	/* DI */
	40.0,	/* AH */
	0.0,	/* AF */
	500.0,	/* F1 */
	80.0,	/* B1 */
	0.0,	/* DF1 */
	0.0,	/* DB1 */
	1500.0,	/* F2 */
	90.0,	/* B2 */
	2500.0,	/* F3 */
	150.0,	/* B3 */
	3500.0,	/* F4 */
	350.0,	/* B4 */
	4500.0,	/* F5 */
	500.0,	/* B5 */
	4990.0,	/* F6 */
	1000.0,	/* B6 */
	500.0,	/* FNP */
	200.0,	/* BNP */
	500.0,	/* FNZ */
	200.0,	/* BNZ */
	1000.0,	/* FTP */
	200.0,	/* BTP */
	1000.0,	/* FTZ */
	200.0,	/* BTZ */
	0.0,	/* A2F */
	0.0,	/* A3F */
	0.0,	/* A4F */
	0.0,	/* A5F */
	0.0,	/* A6F */
	0.0,	/* AB */
	250.0,	/* B2F */
	320.0,	/* B3F */
	350.0,	/* B4F */
	500.0,	/* B5F */
	1500.0,	/* B6F */
	0.0,	/* ANV */
	0.0,	/* A1V */
	0.0,	/* A2V */
	0.0,	/* A3V */
	0.0,	/* A4V */
	0.0		/* ATV */
};

/* high level frame (HL) */

HLFrame defHLFrame = {
	4.0,	/* ag */
	100.0,	/* al */
	100.0,	/* ab */
	0.0,	/* an */
	0.0,	/* ue */
	1000.0,	/* f0 */
	500.0,	/* f1 */
	1500.0,	/* f2 */
	2500.0,	/* f3 */
	3500.0,	/* f4 */
	8.0,	/* ps */
	0.0,	/* dc */
	0.0		/* ap */
};

/* high level state (PF) */

HLState defHLState = {
	-1.0,	/* acl */
	100.0,	/* acd */
	3.0,	/* loc */
	100.0,	/* acx */
	4.0,	/* agx */
	0.0,	/* Pm */
	0.0,	/* Pcw */
	148.0,	/* Ug */
	147.0,	/* Uacx */
	0.0,	/* Un */
	0.0,	/* Uw */
	500.0,	/* f1c */
	500.0,	/* f1x */
	80.0,	/* b1x */
	0.0,	/* Cw */
	0.0,	/* Cg */
	4.0		/* agf */
};

/* 
	HLDEFAULTS  - called from mex implementation of HLsyn 

	note that initialization of HLSpeaker is done from InitializeHLSynthesizer() in inithl.c 
 */
 
void
HLDefaults(Speaker *llSpeaker, LLFrame *llFrame, HLFrame *hlFrame, HLState *hlState) {
	*llSpeaker = defLLSpeaker;
	*llFrame = defLLFrame;
	*hlFrame = defHLFrame;
	*hlState = defHLState;
}
