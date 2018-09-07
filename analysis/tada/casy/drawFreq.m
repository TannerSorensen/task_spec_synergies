function drawFreq

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global allAxes

if ~isstruct( allAxes ) || ~isfield( allAxes, 'freqAxes' ) || isempty( allAxes.freqAxes )  || ~ishandle( allAxes.freqAxes )
  GUI
end

global freq
global magnitude

if isempty( freq ) || isempty( magnitude ) || ...
    ~isempty( find( size( freq ) ~= size( magnitude ) ))
  return
end

plot( freq, 10*log(magnitude), 'Parent', allAxes.freqAxes )
