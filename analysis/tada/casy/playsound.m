% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global waveAmplitude
global sampPerSec % samples per second

% closest (relatively) standard frequency
stdSampl = [ 8000 11025 22050 44100 ];
[ relFreq freqIndx ] = min( abs( log( stdSampl ) - log( sampPerSec ) ) );
sampl = stdSampl( freqIndx );  

% interpolate to the closest standard frequency
step  = 1/sampPerSec;
arg = step * ( 0 : length( waveAmplitude )-1 );
stepI = 1/sampl;
maxI = round( arg( end ) * sampl );
argI = stepI * ( 0:maxI );
 

waveAmplitudeI = interp1( arg, waveAmplitude, argI, 'cubic' );

sound( waveAmplitudeI, sampl, 16 )

% sound( waveAmplitude, sampl, 16 )
