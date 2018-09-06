% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global waveAmplitude
global sampPerSec % samples per second
global waveTime       % sample timing in ms.


[waveAmplitude, sampPerSec] = PCMread;
waveAmplitude = waveAmplitude / 2048; % normalization
waveTime = ( 0:length( waveAmplitude )-1 ) / sampPerSec * 1000;
