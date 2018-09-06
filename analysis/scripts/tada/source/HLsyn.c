/*
  ================================================================================================
    H L S Y N   - mex implementation of the Sensimetrics HL synthesizer
  ------------------------------------------------------------------------------------------------

	usage:  s = HLsyn(params, sRate, isF)
	
	where
	
		PARAMS is an array of structs with fieldnames matching HLsyn parameter names:
			TIME - msec offset of time these parameters become active
			F0	 - fundamental frequency in deciHertz (1000)
			F1,F2,F3,F4  - first four natural frequencies of the vocal tract in Hz (500,1500,2500,3500)
			AG	 - area of glottal opening in mm^2 (4)
			AL	 - cross-sectional area of lip constriction in mm^2 (100)
			AB	 - cross-sectional area of tongue blade constriction in mm^2 (100)
			AN	 - cross-sectional area of velopharyngeal port in mm^2 (0)
			UE	 - rate of increase of VT volume controlled during obstruent in cm^3/s (0)
			PS	 - subglottal pressure in cm H20 (8)
			DC	 - delta compliance as percent (0)
			AP	 - posterior glottal chink in mm^2 (0)
			
		unspecified parameters persist with their previous values (initialized to default male voice)
		duration of synthesized signal equals PARAMS(end).TIME
		
		optional SRATE specifies the sampling rate of the synthesized signal in Hz (default = 10000)
		
		optional ISF is nonzero to initialize generic female voice
	
	returns the vector of synthesized samples S [nSamps x 1] (int16)
		
  ------------------------------------------------------------------------------------------------
	mkt 01/18/09 using HLsyn v2.2
	mkt 02/06/09 fixed 16 bit limitation on utterance duration
  ================================================================================================
*/

#include <stdio.h>
#include <string.h>

#include "mex.h"

#include "hlsyn.h"

/* ***  arguments  *** */

#define	PARAMS	prhs[0]
#define SRATE	prhs[1]
#define ISF		prhs[2]

#define SYNSIG	plhs[0]

static const char *parNames[] = {
	"TIME","F0","F1","F2","F3","F4","AG","AL","AB","AN","UE","PS","DC","AP"
};
#define NPARS sizeof(parNames)/sizeof(char*)

extern void HLDefaults(Speaker*, LLFrame*, HLFrame*, HLState*);

#define SCORE(R,C) ((score+(R)*NPARS)[C])

/*
  ============================================================================================
	M E X   G A T E W A Y   R O U T I N E
  ============================================================================================
*/

void 
mexFunction(
	int				nlhs,
	mxArray			*plhs[],
	int				nrhs,
	const mxArray	*prhs[])
{
	int i, k, n, N, np, frameLen, dur;
	short *s;
	const char *fn;
	mxArray *fp;
	float *score;
	int isMale = 1;
	int sRate = 10000;

	Speaker llSpeaker;
	LLSynth llSynth;
	LLFrame llFrame;
	HLSpeaker speaker;
	HLState	oldState, state;
	HLFrame oldFrame, frame;

/* parse arguments */
	switch (nrhs) {

/* isF specified */
		case 3:
			if (!mxIsEmpty(ISF)) {
				if ((mxGetM(ISF) > 1) || (mxGetN(ISF) > 1))
					mexErrMsgTxt("expecting scalar for SRATE");
				isMale = (mxGetScalar(ISF) ? 0 : 1);
			}
			
/* sampling rate specified */
		case 2:
			if (!mxIsEmpty(SRATE)) {
				if ((mxGetM(SRATE) > 1) || (mxGetN(SRATE) > 1))
					mexErrMsgTxt("expecting scalar for SRATE");
				sRate = (int)(.5 + mxGetScalar(SRATE));
			}
	
/* parse PARAMS */
		case 1:		/* fall thru */
			if (!mxIsStruct(PARAMS)) 
				mexErrMsgTxt("expecting struct argument for PARAMS");
			N = mxGetNumberOfElements(PARAMS);						/* number of distinct time/parameter frames */
			score = (float *)mxCalloc(N*NPARS,sizeof(float));		/* time-varying parameters; columns correspond to PARNAMES */

/* initialize score with default values */
			HLDefaults(&llSpeaker, &llFrame, &frame, &state);
			SCORE(0,0) = 0;			/* time */
			SCORE(0,1) = frame.f0;
			SCORE(0,2) = frame.f1;
			SCORE(0,3) = frame.f2;
			SCORE(0,4) = frame.f3;
			SCORE(0,5) = frame.f4;
			SCORE(0,6) = frame.ag;
			SCORE(0,7) = frame.al;
			SCORE(0,8) = frame.ab;
			SCORE(0,9) = frame.an;
			SCORE(0,10) = frame.ue;
			SCORE(0,11) = frame.ps;
			SCORE(0,12) = frame.dc;
			SCORE(0,13) = frame.ap;
			
			np = mxGetNumberOfFields(PARAMS);	/* number of specified parameters */
			for (i=0; i<N; i++) {
				if (i > 0) 		/* copy previous values to current frame */
					memcpy(&SCORE(i,0),&SCORE(i-1,0),NPARS*sizeof(float));
				for (k=0; k<np; k++) {
					fn = mxGetFieldNameByNumber(PARAMS,k);
					for (n=0; n<NPARS; n++) 
						if (!strcmp(fn,parNames[n])) break;
					if (n >= NPARS)
						mexErrMsgIdAndTxt("HLSYN:badName","%s is not a recognized parameter name",fn);
					fp = mxGetFieldByNumber(PARAMS,i,k);
					if ((fp != NULL) && mxIsNumeric(fp) && (mxGetNumberOfElements(fp)>0)) {	/* ignore empty fields (inherit previous value) */
						if (mxGetNumberOfElements(fp) > 1)
							mexErrMsgIdAndTxt("HLSYN:badVal","params(%d) has bad parameter value for %s (expecting scalar)",i+1,fn);
						SCORE(i,n) = (float)mxGetScalar(fp);
					}
				}
			}
			break;
			
		default:
			if (nlhs < 1) {
				mexEvalString("help HLsyn");
				return;
			}
	} /* switch */

/* initialize first frame */
	dur = (int)((1. + SCORE(N-1,0)*(float)sRate/1000.));	/* duration (samples) */
	llSpeaker.DU = MIN(dur,10000);
	llSpeaker.SR = sRate;
	llSynth.spkr = llSpeaker;
	LLInit(&llSynth, &llSpeaker);
	InitializeHLSynthesizer(&oldFrame, &speaker, &oldState, isMale);
	SYNSIG = mxCreateNumericMatrix(dur, 1, mxINT16_CLASS, mxREAL);
	s = (short *)mxGetPr(SYNSIG);

/* synthesize */
	for (k=0; k<N-1; k++) {
		frame.f0 = SCORE(k,1);			/* update HL frame values for next time offset */
		frame.f1 = SCORE(k,2);
		frame.f2 = SCORE(k,3);
		frame.f3 = SCORE(k,4);
		frame.f4 = SCORE(k,5);
		frame.ag = SCORE(k,6);
		frame.al = SCORE(k,7);
		frame.ab = SCORE(k,8);
		frame.an = SCORE(k,9);
		frame.ue = SCORE(k,10);
		frame.ps = SCORE(k,11);
		frame.dc = SCORE(k,12);
		frame.ap = SCORE(k,13);
		llSynth.spkr.UI = frameLen = (int)((SCORE(k+1,0)-SCORE(k,0))*(float)sRate/1000.);
		HLSynthesizeLLFrame(&frame, &oldFrame, &speaker, &state, &oldState, &llFrame);
		oldFrame = frame;
		oldState = state;
		LLSynthesize(&llSynth, &llFrame, s);
		s += frameLen;
	}
	
/* clean up */
	mxFree((void *)score);

} /* mexFunction */
