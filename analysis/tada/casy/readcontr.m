% read contour outline

% Copyright Haskins Laboratories, Inc., 2001-2004
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function readcontr( fileName )

global allAxes


if ~isstruct(allAxes) || ~isfield( allAxes, 'contourAxes' ) ...
   || isempty( allAxes.contourAxes ) ...
   || ~ishandle( allAxes.contourAxes )
  GUI
end


if nargin < 1, fileName = []; end;

mask = '*.mat';

if isempty( fileName )
  [file, pathName] = ...
     uigetfile(mask, ...
         'Select Matlab data file (*.mat) with XY contour coordinates');
  if file == 0 % the 'Cancel" button was hit
    return 
  else
    fileName = [pathName file];
  end
end



if strcmpi( fileName, 'off' ) % delete plots
  ch = get( allAxes.contourAxes, 'Children' );
  if ~isempty( ch );
    for h = ch
      delete( h )
    end
  end
  return
end

stmp = load( fileName );

% data error processing 
if ~isstruct( stmp )
  msgbox( 'Data file must be in Matlab format *.mat', ...
          'Error in data file format', 'warn' );
  return 
end    

if ~isfield( stmp, 'XY' )
   msgbox( 'Data file must contain a variable named XY', ...
           'Error in data file content', 'warn' );
   return
end

if ~isnumeric( stmp.XY )       % numbers to plot
  msgbox( 'XY data must be numeric', ...
          'Error in data file content', 'warn' );
  return
end

if size( size( stmp.XY ) ) ~= 2 % XY must be a 2-dim array
  msgbox( 'XY must be a 2-dimensional array', ...
          'Error in data file content', 'warn' );
  return
end

s1 = size( stmp.XY );
if s1(1)  ~= 2  % XY must hold exactly 2 variables
  msgbox( 'XY must be an array of size [2, n]', ...
          'Error in data file content', 'warn' );
  return
end


% Data formats are OK
line( 'XData', stmp.XY(1,:), 'YData', stmp.XY(2,:), ...
      'Parent', allAxes.contourAxes )

% plot( stmp.XY(1,:), stmp.XY(2,:), ...
%      'Parent', allAxes.contourAxes )

