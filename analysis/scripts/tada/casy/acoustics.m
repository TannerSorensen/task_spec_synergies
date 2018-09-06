% acoustics

function acoustics

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global area
global tubeLengthSmooth

global bandwidths
global formantFreq

global waveAmplitude
global waveTime % sample timing in ms.

global freq
global magnitude


bandwidths = [];
formantFreq = [];
waveAmplitude = [];
waveTime = [];
freq = [];
magnitude = [];


if isempty( area ) || isempty( tubeLengthSmooth ) 
  return
end

tubeLength = tubeLengthSmooth;

[formantFreq, bandwidths] = tubeResonances( 0.01*area, 0.1*tubeLength(end) ); % mm to cm


bandwidths = getBandwidths( formantFreq ); % July 03, 2003

global soundDuration % seconds 
global sampPerSec % samples per second
global SRC_F0 % fundamental frequency, in Hz, usually 100 Hz.


[waveAmplitude, waveTime, freq, magnitude ] = ...
  syn_buzz( sampPerSec, formantFreq, bandwidths, SRC_F0, soundDuration );

maxfreq = 5000;
indexFreq = freq <= maxfreq;
magnitude = magnitude( indexFreq );
freq = freq( indexFreq );

