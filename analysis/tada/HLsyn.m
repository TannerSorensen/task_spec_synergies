%HLSYN  - matlab interface to HLsyn
%
%	usage:  s = HLsyn(params, sRate, isF)
%
% this procedure is a mex interface to the Sensimetrics HLsyn synthesizer (v2.2)
%
% PARAMS is an array of structs with fieldnames matching HLSYN parameter names:
%	TIME - msec offset of time these parameters become active
%	F0   - fundamental frequency in deciHertz (0 - 5000; 1000)
%	F1   - first natural frequency of the vocal tract in Hz (150 - 1300; 500)
%	F2   - second natural frequency of the vocal tract in Hz (550 - 3000; 500)
%	F3   - third natural frequency of the vocal tract in Hz (1200 - 4800; 2500)
%	F4   - fourth natural frequency of the vocal tract in Hz (2400 - 4990; 3500)
%	AG   - area of glottal opening in mm^2 (0 - 40; 4)
%	AL   - cross-sectional area of lip constriction in mm^2 (0 - 200; 100)
%	AB   - cross-sectional area of tongue blade constriction in mm^2 (0 - 200;100)
%	AN   - cross-sectional area of velopharyngeal port in mm^2 (0 - 100; 0)
%	UE   - rate of increase of VT volume controlled during obstruent in cm^3/s (-200 - 200; 0)
%	PS   - subglottal pressure in cm H20 (0 - 20; 8)
%	DC   - delta compliance as percent (-100 - 100; 0)
%	AP   - posterior glottal chink in mm^2 (0 - 40; 0)
%	
% unspecified parameters persist with their previous values (initialized to default male voice)
% duration of synthesized signal equals PARAMS(end).TIME
%
% optional SRATE specifies the sampling rate of the synthesized signal in Hz {default = 10000}
%
% specify nonzero ISF to initialize generic female voice (default generic male voice)
%
% returns the vector of synthesized samples S [nSamps x 1] (int16)
%
% Example 1:  synthesize and play a 500 ms schwa
% >> params(2).TIME = 500;
% >> s = HLsyn(params);
% >> soundsc(double(s),10000)
%
% Example 2:  synthesize schwa at 11025 Hz using generic female voice and 220 Hz F0
% >> params(1).F0 = 2200;
% >> s = HLsyn(params,11025,1);
%
% Example 3:  synthesize /uw/, /aa/, /iy/ sequence
% >> params = struct('TIME',0,'F0',1150,'F1',260,'F2',530,'F3',2670);
% >> params(2)=struct('TIME',500,'F0',1250,'F1',560,'F2',910,'F3',2200);
% >> params(3)=struct('TIME',1000,'F0',1040,'F1',300,'F2',2100,'F3',3000);        
% >> params(4).TIME=1500;
% >> s = HLsyn(params);
%
% Example 4:  synthesize "once upon a midnight dreary" (HLsyn samples xp1a, xp1aend)
% >> params = ParseHL('MidnightDreary.HL');
% >> s = HLsyn(params);

% mkt 01/09
