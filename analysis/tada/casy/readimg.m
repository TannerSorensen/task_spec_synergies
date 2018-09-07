% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function readimg( fileName )

if nargin < 1, fileName = []; end;

if strcmpi( fileName, 'off' )
  imageMatrix = [];
else
  imageMatrix  = rot90( IMGread(fileName)', 2 );
end

global allAxes

if ~isstruct(allAxes) || ~isfield( allAxes, 'imgAxes' ) || isempty( allAxes.imgAxes ) || ~ishandle( allAxes.imgAxes )
  GUI
end


% plot MRI image on background
global minXPict
global maxXPict
global minYPict
global maxYPict


persistent MRI

% next operation will erase the plot of vocal tract

if ~isempty( MRI ) && ishandle( MRI )
   delete( MRI )
   MRI = [];
end


if ~isempty ( imageMatrix )   
  MRI = image( 'CData', imageMatrix, ...
         'Parent', allAxes.imgAxes, ...
         'XData', [minXPict maxXPict], 'YData', [minYPict maxYPict], ...
         'CDataMapping', 'scaled', 'Visible', 'on' ...
        );
end
