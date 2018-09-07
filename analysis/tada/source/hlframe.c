/*****************************************************************************/
/**  HLsyn - Version 2.2                                                    **/
/**                                                                         **/
/** Copyright (c) 1993-1998 by Sensimetrics Corporation                     **/
/** All rights reserved.                                                    **/
/**                                                                         **/
/*****************************************************************************/

/*
 *  hlframe.c - map one frame of HL parameters to LL parameters
 *
 *  coded by J. Erik Moore, 12/93
 *
 *  Modification History:
 *
 *   9 Dec 1998  reb:  adjust f0 to get F0 only if f0 > 0 (otherwise let 
 *                     F0 = 0) and do not let adjustments make F0 < 0; 
 *                     adjust f1c rather than F1 for tracheal coupling, and 
 *                     do so only when agf (not agx) exceeds agm; similarly, 
 *                     adjust B3, B4, B5 for tracheal coupling only when 
 *                     agf (rather than agx) exceeds agm.
 *   6 Oct 1997  reb:  calculate adjustments to F1, B3, B4, B5 using agf 
 *                     rather than agx; fixed comment describing adjustment 
 *                     of spectral tilt for ap, made local routines static, 
 *                     do not set AV, AF or AH to zero just because ag (or 
 *                     ag + ap) is zero.
 *   2 Jun 1997  reb:  allow AF, AH (but not AV) nonzero when ag <= 0 but 
 *                     ap > 0; fixed bug in adjustment of TL for ap (convert 
 *                     ap to cgs units).
 *  30 Apr 1997  reb:  changed amount of adjustment of F0 for transglottal 
 *                     pressure (do not divide by the default subglottal 
 *                     pressure); changed sign of adjustment of F0 for 
 *                     compliance/stiffness; corrected amount of adjustment 
 *                     of TL for ap to have correct behavior as ap --> 0 by 
 *                     including a term for viscous resistance; calculate B1 
 *                     and B2 using transglottal pressure instead of ps; set 
 *                     AV to zero if ps < Pm; used absolute value of trans-
 *                     glottal pressure to calculate AH (to avoid logs of 
 *                     negatives); used HLSYNAPI instead of FLAV_STDCALL; 
 *                     introduced FLOAT_EPS and used it to keep from taking log 0.
 *  13 Nov 1996  reb:  moved ps from HLSpeaker to HLFrame, changed instances 
 *                     of Ps to ps to reflect this; set AV = 0 when 
 *                     transglottal pressure is below AVPressureThreshold 
 *                     minus KdPTdc times dc; put decl of Tongue_acx_f1c under 
 *                     control of FLAV_NO_ACXF1C; call MapGlottalFormantsNotF1 
 *                     after Speech Circuit and include adjustments in F0 for 
 *                     vowel height, transglottal pressure, and stiffness; in 
 *                     SourceAmplitudes calculate AH based on agf rather than 
 *                     agx; in SourceSpecifics add a correction term to TL based 
 *                     on ap and ps; in GlottalInteraction use new formula for 
 *                     B1 and B2 based on agf and ps.  
 *  09 Sep 1996  reb:  bug fix in new calculation of AV from agx
 *                     (removed a discontinuity in the graph).
 *  27 Aug 1996  reb:  new calculation of AV from agm (added 
 *                     AVPressureThreshold, KdAV0, KdAV1);
 *                     if ag >= agHiKLSourceCutoff then AV = AH = AF = 0; 
 *                     included flavor.h, checked FLAV_STDCALL in def'n 
 *                     of HLSynthesizeLLFrame, checked FLAV_NO_ACXF1C.
 *  08 Aug 1996  reb:  archived as version 2.2 (no changes).
 *  27 Mar 1995  Win32 MSVC version; B6 = 1000 (epc)
 *  20 Sep 1995  if (ag <= 0.), then AV = AH = AF = 0;
 *               if (AV == 0), then F0 = 0 (epc)
 *
 */

#include "flavor.h"

#if defined(DEBUG) || defined(WARNINGS)
#include <stdio.h>	/* for printf on error */
#include <stdlib.h>	/* for exit on error */
#include <process.h>	/* for exit on error */
#endif

#include <math.h>	/* for log10 */
#include "hlsyn.h"

/*****
    External function declarations
*****/
#ifndef FLAV_NO_ACXF1C
void Tongue_acx_f1c(HLFrame *frame,HLSpeaker *speaker,HLState *state);
#endif
void SpeechCircuit(HLFrame *frame,HLFrame *oldframe,HLSpeaker *speaker,
		   HLState *state,HLState *oldstate);
void SetNasals_f1x(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe);

/*****
    Module function declarations
*****/

static void MapGlottalFormantsNotF1(HLFrame *frame,HLSpeaker *speaker,
    HLState *state,LLFrame *llframe);
static void FricativeFilters(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe);
static void SourceAmplitudes(HLFrame *frame,HLSpeaker *speaker,HLState *state,
		      HLState *oldstate,LLFrame *llframe);
static float InterpolateAF(HLSpeaker *speaker,HLState *state,HLState *oldstate);
static void GlottalInteraction(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe);
static void SourceSpecifics(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe);
static void UnusedLLParameters(LLFrame *llframe);

void
HLSynthesizeLLFrame(HLFrame *frame, HLFrame *oldframe, HLSpeaker *speaker,
					       HLState *state, HLState *oldstate, LLFrame *llframe)

{
  #ifdef FLAV_NO_ACXF1C
  state->f1c = frame->f1;
  #else
  /* acxf1c.c */
  Tongue_acx_f1c(frame,speaker,state);
  #endif

  /* circuit.c */
  SpeechCircuit(frame,oldframe,speaker,state,oldstate);

  /* hlframe.c */
  MapGlottalFormantsNotF1(frame,speaker,state,llframe);

  /* nasalf1x.c */
  SetNasals_f1x(frame,speaker,state,llframe);

  /* hlframe.c */
  SourceAmplitudes(frame,speaker,state,oldstate,llframe);

  /* hlframe.c, depends on value of AF */
  FricativeFilters(frame,speaker,state,llframe);

  /* hlframe.c */
  GlottalInteraction(frame,speaker,state,llframe);

  /* hlframe.c */
  SourceSpecifics(frame,speaker,state,llframe);

  /* hlframe.c */
  UnusedLLParameters(llframe);
}

static void
MapGlottalFormantsNotF1(HLFrame *frame,HLSpeaker *speaker,
    HLState *state,LLFrame *llframe)

{
  if( frame->f0 > 0.0f ) {
    llframe->F0 = (short)(
      frame->f0 + 0.5f /* round, not truncate */

      /* Correction term for vowel height */ 
      + (frame->f1 <= speaker->f0_vowelshift_f1_break ?
          speaker->Kf1 * frame->f0 * (speaker->f1_neutral - speaker->f0_vowelshift_f1_break) : 
          (frame->f1 < speaker->f1_neutral ?
            speaker->Kf1 * frame->f0 * (speaker->f1_neutral - frame->f1) : 
            0.0f))

      /* Correction term for transglottal pressure */
      + speaker->Kpd * (frame->ps - CGS_TO_CMWATER(state->Pm) - speaker->Psm)

      /* Correction term for glottal stiffness */
      - speaker->Kdf0dc * frame->dc
      );

    if( llframe->F0 < 0 ) /* don't let it go negative! */
      llframe->F0 = 0;
  }
  else
    llframe->F0 = 0;

  /* Adjust f1c for tracheal coupling */
  if( state->agf > speaker->agm )
    state->f1c += speaker->KdF * (1.0f - state->f1c/speaker->F1T) * (state->agf - speaker->agm);

  llframe->F2 = (short)frame->f2;
  llframe->F3 = (short)frame->f3;
  llframe->F4 = (short)frame->f4;
  llframe->F5 = (short)speaker->F5;
}

static void
FricativeFilters(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe)

{
  /*****
    Zero all of the gains initially
  *****/

  llframe->A2F = 0;
  llframe->A3F = 0;
  llframe->A4F = 0;
  llframe->A5F = 0;
  llframe->A6F = 0;
  llframe->AB = 0;

  /*****
    First, set the gains of the parallel fricative filter
  *****/

  if(llframe->AF > speaker->AFThreshold){
    switch (state->loc){
      case LIPS: /* Labial */
        llframe->AB = (short)speaker->LabialAB;
        break;

      case BLADE: /* Alveolar */
	/*****
	  It seems that one may want to specify f2,f3 out of the
	  region defined in the f2,f3 plane.  In the instance that
	  this occurs, this routine sets the gains to zero.
	*****/

	if(   frame->f2>ALV_F2_MAX || frame->f3>ALV_F3_MAX
	  || frame->f2<ALV_F2_MIN || frame->f3<ALV_F3_MIN){
	  llframe->A2F = 0;
	  llframe->A3F = 0;
	  llframe->A4F = 0;
	  llframe->A5F = 0;
	  llframe->AB = 0;
	}

	else{
	  llframe->A2F = (short)ALVEOLAR(frame->f2,frame->f3).A2F;
	  llframe->A3F = (short)ALVEOLAR(frame->f2,frame->f3).A3F;
	  llframe->A4F = (short)ALVEOLAR(frame->f2,frame->f3).A4F;
	  llframe->A5F = (short)ALVEOLAR(frame->f2,frame->f3).A5F;
	  llframe->AB = (short)ALVEOLAR(frame->f2,frame->f3).AB;
	}
        break;

      case DORSUM: /* Pal/Velar */
        if(frame->f2 > (speaker->PalVelar_f2Offset 
	  + speaker->PalVelar_f2Overf3_Slope * frame->f3))
	  llframe->A3F = (short)speaker->PalVelarA3F;

        else{
	  llframe->A2F = (short)speaker->PalVelarA2F;
	  llframe->A5F = (short)speaker->PalVelarA5F;
        }
        break;

      case LIQUID: /* Lateral/Retroflex */
	if(frame->f3<speaker->f3RetroflexMax)
	  /* Retroflex */
	  llframe->A3F = (short)speaker->RetroflexA3F;
	else
	  /* Must be lateral */
	  llframe->A3F = (short)speaker->LateralA3F;
        break;
      
#ifdef DEBUG
      default:
        printf(" Should not reach default (FricativeGains)");
        exit(1);
        break;
#endif
    }
    
    /*****
      The sixth formant is a loose end.  It is not used by the HLSyn code
      but is by the LLsyn code.  The gain is set to the Klatt default value.
    *****/
    
    llframe->A6F = (short)speaker->A6F;
  }

  /*****
    The 6th formant is a loose end.  It is not used especially
    by HLSYN but is by LLSYN and cannot
    really be removed so is set to Klatt defaults.
  *****/

  llframe->F6 = (short)speaker->F6;

  /*****
    Then set the bandwidths of the fricative filter to default values.  
    OR do we set them to the values of the regular bandwidths.
  *****/

  llframe->B2F = (short)speaker->B2F;
  llframe->B3F = (short)speaker->B3F;
  llframe->B4F = (short)speaker->B4F;
  llframe->B5F = (short)speaker->B5F;
  llframe->B6F = (short)speaker->B6F;
}

static void
SourceAmplitudes(HLFrame *frame,HLSpeaker *speaker,HLState *state,
		      HLState *oldstate,LLFrame *llframe)

{
  /*****
    The pressures in this routine need to be in CM H20.
    Pm is stored in dynes/cm^2 and ps is stored in CM H20.
    The areas used in this routine must be in cm^2.  Recall that
    all of the areas are stored in mm^2.
  *****/

  if (frame->ag >= speaker->agHiKLSourceCutoff)
  	llframe->AF = 0;
  else
  	llframe->AF = (short)InterpolateAF(speaker,state,oldstate);

  /*****
    Compute AV dependent on the actual size of the glottal opening (agx).  
    NOTE: 20. log10( (ps-Pm) ^ (3/2)) is equivalent to: 30. log10( ps-Pm )
  *****/

  if( state->agx < speaker->agMin 
   || state->agx > speaker->agAVModalOffsetMax + speaker->agm 
   || frame->ag >= speaker->agHiKLSourceCutoff
   || frame->ps - CGS_TO_CMWATER(state->Pm) < FLOAT_EPS
   || frame->ps - CGS_TO_CMWATER(state->Pm) < 
        speaker->AVPressureThreshold 
        - speaker->KdPTdc * frame->dc )
    llframe->AV = 0;

  else if (state->agx < speaker->agm) 
    llframe->AV = (short)(
      30. * log10(frame->ps - CGS_TO_CMWATER(state->Pm)) 
      + speaker->Kv 
      - speaker->KdAV0 * MMSQ_TO_CMSQ(speaker->agm - state->agx)
      );
  
  else if (state->agx < speaker->agm + speaker->agAVModalOffsetOnOff) 
    llframe->AV = (short)(
      30. * log10(frame->ps - CGS_TO_CMWATER(state->Pm)) 
      + speaker->Kv 
      - speaker->KdAV * MMSQ_TO_CMSQ(state->agx - speaker->agm)
      );
  
  else
    llframe->AV = (short)(
      30. * log10(frame->ps - CGS_TO_CMWATER(state->Pm)) 
      + speaker->Kv 
      - speaker->KdAV * MMSQ_TO_CMSQ(speaker->agAVModalOffsetOnOff)
      - speaker->KdAV1 * MMSQ_TO_CMSQ(state->agx - speaker->agm 
                                       -speaker->agAVModalOffsetOnOff)
      );
  
  /*****
    Must not be negative. From Williams.
  *****/
  
  if(llframe->AV < 0)
    llframe->AV = 0;

  if(llframe->AV == 0)
    llframe->F0 = 0;

  /*****
    Compute AH, conditions are from Dave Williams code hlkl.c
  *****/

  if(state->agf < speaker->agMin
    || frame->ag >= speaker->agHiKLSourceCutoff
    || (frame->an <= 0. && state->acx <= 0.)
    || fabs(frame->ps - CGS_TO_CMWATER(state->Pm)) < FLOAT_EPS
    || state->agf < FLOAT_EPS )
    llframe->AH = 0;

  else
    llframe->AH = (short)(
      30. * log10(fabs(frame->ps - CGS_TO_CMWATER(state->Pm)))
      + 10. * log10(MMSQ_TO_CMSQ(state->agf))
      + speaker->Ka
      );

  /*****
    Must not be negative. From Williams.
  *****/
      
  if(llframe->AH < 0)
    llframe->AH = 0;

}


static float
InterpolateAF(HLSpeaker *speaker,HLState *state,HLState *oldstate)

{
  short i;
  int NumberAFInterpolations;
  float acx,Pm,AF;
  float acxPrev,acxStep,PmPrev,PmStep,MaxAF;

  /*****
    Set up the interpolation on acx and Pm.  The interpolation
    is in between the previous frame and the current frame.
    Pm must be in CM H20.  acx must be in cm^2.
  *****/

  if(state->agx <= 0.0 || state->acx <= 0.0) /* From hlkl.c */
    return 0.0f;

  NumberAFInterpolations = round(speaker->UpdateInterval
    / speaker->AFInterpTimeStep);
  
  acxPrev = MMSQ_TO_CMSQ(oldstate->acx);
  acxStep = ( MMSQ_TO_CMSQ(state->acx) - acxPrev )
    / (float) NumberAFInterpolations;

  PmPrev = CGS_TO_CMWATER(oldstate->Pm);
  PmStep = (CGS_TO_CMWATER(state->Pm) - PmPrev) 
    / (float) NumberAFInterpolations;

  for(i=1;i <= NumberAFInterpolations; ++i){
    acx = acxPrev + i * acxStep;
    Pm = PmPrev + i * PmStep;

    /*****
      Must find the maximum in the interpolation of:

      AF = 20 log10 ( Pm ^ (3/2) * acx ^ (1/2) ) + Kf
    *****/

    /*****
      If there is no pressure in the mouth then there
      will be no fricative.  Also complete closure will
      not cause frication.
    *****/

    if(Pm < FLOAT_EPS || acx < FLOAT_EPS){
#ifdef WARNINGS
	printf(" Pm or acx non-positive in InterpolateAF");
#endif
	AF=0.0f;
    }
    else
      AF = (float)(30. * log10(Pm) + 10. * log10(acx) + speaker->Kf);

    if(i==1)
      MaxAF = AF;

    else if(AF > MaxAF)
      MaxAF = AF;
  }

  /*****
    Must not be negative. from Williams
  *****/
  
  if(MaxAF < 0)
    MaxAF = 0.0f;
  
  return MaxAF;
}

static void
GlottalInteraction(HLFrame *frame,HLSpeaker *speaker,HLState *state,LLFrame *llframe)

{
  llframe->F1 = (short)state->f1x;  /* glottal coupling is accounted for in f1c */

  if(state->agf > speaker->agm){
    llframe->B3 = (short)(speaker->B3m 
      + (state->agf - speaker->agm) * speaker->KB3);
    llframe->B4 = (short)(speaker->B4m 
      + (state->agf - speaker->agm) * speaker->KB4);
    llframe->B5 = (short)(speaker->B5m 
      + (state->agf - speaker->agm) * speaker->KB5);
  }

  else{
    llframe->B3 = (short)speaker->B3m;
    llframe->B4 = (short)speaker->B4m;
    llframe->B5 = (short)speaker->B5m;
  }	
  
  if( state->agf > speaker->agm ) {
    float a,b,Ptransg;
    
    a = (float) (SPEEDSOUND * SPEEDSOUND * sqrt(RHO / 2.0) / PI);
    a /= speaker->Av > L_EPS * L_EPS ?
            speaker->Av :
            (
#ifdef WARNINGS
            printf("GlottalInteraction:  used default cross-sectional area of vocal tract."),
#endif
            3.5f
            );

    a /= speaker->Lv > L_EPS ?
            speaker->Lv :
            (
#ifdef WARNINGS
            printf("GlottalInteraction:  used default length of vocal tract."),
#endif
            17.0f
            );
  
    b = (float)(2.0 * PI * PI * RHO) * speaker->Lvg * speaker->Lvg;
    Ptransg = (float) fabs(CMWATER_TO_CGS(frame->ps) - state->Pm);
  
    llframe->B1 = (short)(
      state->b1x
      + a * MMSQ_TO_CMSQ(state->agf - speaker->agm) 
          * sqrt(Ptransg) / (Ptransg + b * state->f1x * state->f1x)
      );
    llframe->B2 = (short)(
      speaker->B2m 
      + a * MMSQ_TO_CMSQ(state->agf - speaker->agm) 
          * sqrt(Ptransg) / (Ptransg + b * frame->f2 * frame->f2)
      );
  }
  
  else {
    llframe->B1 = (short)state->b1x;
    llframe->B2 = (short)speaker->B2m;
  }
}

static void
SourceSpecifics(HLFrame *frame,HLSpeaker *speaker,HLState *state,
    LLFrame *llframe)

{
  float acx_anMax,TLFloat,m,RkApCubedOverRho,RvApCubedOverRho,SixkHzpiT, apCgs;

  /*****
    Compute OQ
  *****/

  llframe->OQ = (short)(speaker->OQm + (state->agx - speaker->agm)
    * speaker->KOQ);
  
  if(llframe->OQ > speaker->OQMax)
    llframe->OQ = (short)speaker->OQMax;
  
  else if(llframe->OQ < speaker->OQMin)
    llframe->OQ = (short)speaker->OQMin;

  /*****
    Compute TL
  *****/

  acx_anMax = state->acx > frame->an ? state->acx : frame->an;
  
  if( acx_anMax < speaker->TLBreakArea ){
    TLFloat = speaker->TLm + ( (speaker->TLBreakArea - acx_anMax)
       + (state->agx - speaker->agm) ) * speaker->KTL;
  }

  else
    TLFloat = speaker->TLm + (state->agx - speaker->agm) * speaker->KTL;

  /*****
    Include posterior glottal opening correction on TL.
  *****/
  
  m = fabs(speaker->At) > L_EPS * L_EPS ? 
        speaker->Lt / speaker->At :
        (
#ifdef WARNINGS
        printf("SourceSpecifics:  used default area of trachea."),
#endif
        speaker->Lt / 2.5f
        );
  
  m += fabs(speaker->Av) > L_EPS ?
        speaker->Lv / speaker->Av :
        (
#ifdef WARNINGS
        printf("SourceSpecifics:  used default cross-sectional area of vocal tract."),
#endif
        speaker->Lv / 3.5f
        );
  
  /* The additional tilt at 3kHz is 20 log10 (6kHz pi T), assuming 1/(2 pi T) <= 3kHz, 
     where 
                         RHO (m + (Lvg/ap))
                    T = --------------------                       (a time constant),
                             Rk  +  Rv
        
                         RHO  U     sqrt(2 RHO / |ps - Pm|)
                   Rk = -------- = -------------------------       (kinematic resistance),
                          ap^2               ap
        
                         12 MU Lvg Lhp^2
                   Rv = -----------------                          (viscous resistance).
                              ap^3
     
     and if 1/(2 pi T) > 3kHz, i.e. T < 1/(6 pi kHz) then we replace T by 1/(6 pi kHz).  */

  apCgs = MMSQ_TO_CMSQ(frame->ap);
  RkApCubedOverRho = (float) sqrt(2.0 * fabs(CMWATER_TO_CGS(frame->ps) - state->Pm) / RHO)
                              * apCgs * apCgs;
  RvApCubedOverRho = 12.0f * (float)(MU/RHO) * speaker->Lvg * speaker->Lhp * speaker->Lhp;
  SixkHzpiT = 6000.0f * (float)PI * apCgs * apCgs * (m*apCgs + speaker->Lvg)
               / (RkApCubedOverRho + RvApCubedOverRho);
  
  TLFloat += 20.0f * (float) log10(SixkHzpiT < 1.0 ?  1.0 : SixkHzpiT);

  /*****
    Include formant spacing correction on TL
  *****/
  
  llframe->TL = (short)(TLFloat + (speaker->SFromf4 * frame->f4 
    - speaker->SDefault) * speaker->dBTLforPctS
      / (speaker->PctSfordBTL * speaker->SDefault));
    
  if(llframe->TL > speaker->TLMax)
    llframe->TL = (short)speaker->TLMax;

  else if(llframe->TL < speaker->TLMin)
    llframe->TL = (short)speaker->TLMin;

  /*****
    Compute DI, note range expression is different from
    hlkl.c
  *****/

  if(state->agx > speaker->agDIMin && state->agx < speaker->agm)
    llframe->DI = (short)(((speaker->agm - state->agx)/state->agx) * speaker->KDI);

  else
    llframe->DI = 0;
}

static void
UnusedLLParameters(LLFrame *llframe)

{
  /*****
    The current version of HLSYN does not compute
    values for the tracheal pole/zero pair.  They
    are eliminated by setting them equal to one
    another.
  *****/

  llframe->FTP = llframe->FTZ = REMOVE_FORMANT;
  llframe->BTP = llframe->BTZ = REMOVE_BANDWIDTH;

  /*****
    Only the Klatt natural source is used so the
    LF source parameter SQ is set to 0.
  *****/

  llframe->SQ = 0;

  /*****
    The flutter is not set by HLSYN
  *****/

  llframe->FL = 0;

  /*****
    The two first formant modifiers DF1 and DB1 are not used
  *****/

  llframe->DF1 = 0;
  llframe->DB1 = 0;

  /*****
    The special parallel synthesizer for voiced speech is
    not used by the HL synthesizer.  Its gains are set
    to zero.
  *****/

  llframe->ANV = 0;
  llframe->A1V = 0;
  llframe->A2V = 0;
  llframe->A3V = 0;
  llframe->A4V = 0;
  llframe->ATV = 0;
  
  /*****
    Set B6, it is not used in ll but aesthetically set to 0
  *****/
  
  llframe->B6 = 1000;
}
