% read sound from *.wav file

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function readwav( fileName )

% check for arguments:
if nargin < 1
  fileName = [];
end

mask = '*.wav';
if findstr(fileName, '*'),
  mask = fileName;
  fileName = [];
end;


% get file name, if necessary
if isempty( fileName )
  [ file, path ] = uigetfile( mask, 'Get data from WAV file');
  if file == 0 
    return; 
  end;
  fileName = [path file];
end 



global waveAmplitude
global sampPerSec % samples per second
global waveTime       % sample timing in ms.


[waveAmplitude, sampPerSec, bits] = audioresd( fileName );
waveTime = ( 0:length( waveAmplitude )-1 ) / sampPerSec * 1000;
