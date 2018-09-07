function drawWave

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global allAxes

if ~isstruct(allAxes) || ~isfield( allAxes, 'waveAxes' ) || isempty( allAxes.waveAxes )  || ~ishandle( allAxes.waveAxes )
  GUI
end


global waveAmplitude
global waveTime       % sample timing in ms.

if isempty( waveAmplitude ) || isempty( waveTime ) 
  return
end

set( allAxes.waveAxes, 'NextPlot', 'replacechildren' )
plot( waveTime, waveAmplitude, 'b', 'Parent', allAxes.waveAxes )

