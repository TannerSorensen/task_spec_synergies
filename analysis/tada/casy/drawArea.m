function drawArea

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu



global crossArea
global areaIterpolated
global area
global tubeLengthSmooth
global tubeLengthGeometric


if isempty( area ) || isempty( tubeLengthSmooth ) || ...
    isempty( areaIterpolated ) || ... 
    isempty( crossArea  ) || isempty( tubeLengthGeometric ) || ...
    ~isequal( size( crossArea ), size( tubeLengthGeometric )) || ...
    length( areaIterpolated ) > length( tubeLengthSmooth ) || ...
    ~isequal( size( area ), size( tubeLengthSmooth ))
  return
end

global allAxes

if  ~isstruct(allAxes) || ~isfield( allAxes, 'areaAxes' ) || isempty( allAxes.areaAxes )  || ~ishandle( allAxes.areaAxes )
  GUI
end


set( allAxes.areaAxes, 'NextPlot', 'replacechildren' )
plot( tubeLengthGeometric, crossArea,'r-',  'Parent', allAxes.areaAxes  )

set( allAxes.areaAxes, 'NextPlot', 'add' )
plot( tubeLengthSmooth(1:length(areaIterpolated)), areaIterpolated, ... 
      'g--', 'Parent', allAxes.areaAxes  )
plot( tubeLengthSmooth, area, 'b-', 'Parent', allAxes.areaAxes  )

legend( allAxes.areaAxes, 'Section Areas', 'Interpolated Areas', 'Smoothed Areas', 0 )
