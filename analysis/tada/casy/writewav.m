% write sound into file in *.wav format

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function writewav( fileName )

% check for arguments:
if nargin < 1
  fileName = [];
end

% get file name, if necessary
if isempty( fileName )
  [ file, path ] = uiputfile([[], '.wav'], 'Save data to WAV file');
  if file == 0 
    return; 
  end;
  fileName = [path file];
end 

global waveAmplitude
global sampPerSec % samples per second

factor = max( abs( waveAmplitude ) );

factor = 1.0 / max( factor, 1 );


audiowrite( waveAmplitude * factor, sampPerSec, 16, fileName )
