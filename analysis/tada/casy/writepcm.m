% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global waveAmplitude
global sampPerSec % samples per second

factor = max( abs( waveAmplitude ) );

factor = 2048 / max( factor, 1 );

PCMwrite( waveAmplitude * factor, sampPerSec, [], 0 )
