% coupling.ph
%
% 2009/02/17 Hosung Nam
%
% standard phasing syntax file to generate ph.o file in gest.m

%%%%%%% oscillatory parameters and activation portion in cycle
v\d+ 2 1 4 1 NaN / 10 200 210			% vowel
v_rnd\d+ 2 1 4 1 NaN / 10 200 210		% rounding
ons\d*_CLO 2 1 4 1 NaN / 5 60 65		% CLO constriction
ons\d*_REL 2 1 4 1 NaN / 5 20 25		% REL constriction

ons\d*_CRT 2 1 4 1 NaN / 5 60 65		% CRT constriction
ons\d*_NAR 2 1 4 1 NaN / 5 60 65		% NAR constriction
ons\d*_VOC 2 1 4 1 NaN / 5 60 65		% VOC constriction

cod\d*_CLO 2 1 4 1 NaN / 5 55 60		% CLO constriction
cod\d*_REL 2 1 4 1 NaN / 5 20 25		% REL constriction
cod\d*_CRT 2 1 4 1 NaN / 5 55 60		% CRT constriction
cod\d*_NAR 2 1 4 1 NaN / 5 55 60		% NAR constriction
cod\d*_VOC 2 1 4 1 NaN / 5 55 60		% VOC constriction

ons\d*_h\d+ 2 1 4 1 NaN / 5 60 65   	% glottal abduction
cod\d*_h\d+ 2 1 4 1 NaN / 5 55 60   	% glottal abduction
ons\d*_n\d+$ 2 1 4 1 NaN / 5 60 65  	% onset nasal 
cod\d*_n\d+$ 2 1 4 1 NaN / 5 85 90  	% coda nasal 
DFLT 2 1 4 1 NaN / 5 40 45			% others


/coupling/

% C		= (clo | crt | nar | voc)
% CNS	= (clo | crt | nar)
% OBS	= (clo | crt)

ONS_OBS ONS_CNS 1 1 90		% anti-phase relation in onset clusters

ONS_VOC ONS_NAR 1 1 0		% VOC gesture of /r/, /l/ sychronous with primary NAR constriction

ONS_CNS ONS_REL 1 1 65		% REL is anti-phase with respect to Constriction

ONS_CRT ONS_H 1 1 20			% GLO gesture is synchronous with frics
ONS_CLO ONS_H 1 1 20		% else GLO gesture is delayed for stops
ONS_CLO ONS_N 1 1 0			% VEL gesture synchronous wih oral constr.

ONS_CNS* V 1 1 0			% all CNS gestures synchronous with V
ONS_H V 1 1 0				% GLO synchronous with V, if not coupled to CNS

% vowel
V_RND V 1 1 0				%rounding synchronous with V tongue constr.

% coda
COD_C COD_C 1 1 45		% C in coda are phased 180 degrees
% COD_VOC COD_NAR 1 1 45		% VOC gesture anti-phase to NAR constr.

COD_CNS COD_REL 1 1 60		% REL is anti-phase with respect to Constriction

COD_CLO COD_H 1 1 20		% GLO gesture is delayed for stops
COD_CRT COD_H 1 1 20			% else GLO gesture is synchronous with frics
COD_N COD_CNS 1 1 45		% VEL gesture anti-phase to oral constr.

V COD_C 1 1 180			% first coda CNS anti-phase to V

/cross-syllable/
COD_C ONS_CNS 1 1 45		% applies if boundary is C$C
V ONS_CNS 1 1 180			% applies if boundary is V$C
COD_C V 1 1 0				% applies if boundary is C$V
V V 1 1 180					% applies if boundary is V$V

/cross-word/
COD_REL ONS_CNS 1 1 45		% applies if boundary is C#C
COD_C ONS_CNS 1 1 45		% applies if boundary is C#C
V ONS_CNS 1 1 180			% applies if boundary is V#C
COD_C V 1 1 0				% applies if boundary is C#V
V V 1 1 180					% applies if boundary is V#V