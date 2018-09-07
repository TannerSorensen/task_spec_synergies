
% plotting outline on graphic window

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

function drawVT


global allAxes

if  ~isstruct(allAxes) || ~isfield( allAxes, 'VTAxes' ) || isempty( allAxes.VTAxes ) || ~ishandle( allAxes.VTAxes )
  GUI
end

% plot outlines

global UpperOutline
global BottomOutline 

global KeyPts
global GeoPts

% global SEG_Bezier_fix_Velum_VelMax
% global SEG_Bezier_fix_VelMax_Maxilla
% global SEG_Bezier_fix_Maxilla_Alveolus


% next operation will erase the plot of vocal tract
set( allAxes.VTAxes, 'NextPlot', 'replacechildren' )

plot( UpperOutline(:,1), UpperOutline(:,2), 'c-', 'Parent', allAxes.VTAxes )
     % upper outline: red,  star  markers

% subsecond plots will not destroy the pevious ones 
set( allAxes.VTAxes, 'NextPlot', 'add' )


if ~isreal( BottomOutline )
  BottomOutline
end   

plot( BottomOutline(:,1), BottomOutline(:,2), 'c-', 'Parent', allAxes.VTAxes )   
     % lower outline: cyan, cross markers

% global CMP_TipCircle
%   plot( CMP_TipCircle(1), CMP_TipCircle(2), 'g+', 'MarkerSize',20, ...
% 'Parent', allAxes.VTAxes  )


global gridLines

for i = 1:size(gridLines,1)
  temp = squeeze(gridLines(i,:,:));
  plot( temp(1,:), temp(2,:), 'g', 'Parent', allAxes.VTAxes )
end


global midPoints

if ~isempty( midPoints )
  plot( midPoints(1,:), midPoints(2,:), 'o', 'Color', [1 0.65 0 ], ...
        'MarkerFaceColor', [1 0.65 0 ], 'Parent', allAxes.VTAxes  )
end


global crossSection

if ~isempty( crossSection )
  delta = 0.5* crossSection';
  a = midPoints - delta; 
  b = midPoints + delta;

  for i = 1:size( midPoints, 2 )
    plot( [a(1,i) b(1,i)], [a(2,i) b(2,i)], '-', 'Color', [1 0.65 0 ], 'Parent', allAxes.VTAxes  )
  end
end

for i = GeoPts
  plot( i.coords(1), i.coords(2), 'go', 'MarkerSize',12, ...
        'MarkerFaceColor','g', ...
        'ButtonDownFcn', ['starts ' 'GEO_' i.Tags], 'Parent', allAxes.VTAxes )
end

for i = KeyPts
  plot( i.coords(1), i.coords(2), 'r+', 'MarkerSize',12, ...
        'ButtonDownFcn', ['starts ' 'KEY_' i.Tags], 'Parent', allAxes.VTAxes )
end

global TUN_GridCenter

plot(  TUN_GridCenter(1),  TUN_GridCenter(2), 'ms', 'MarkerSize', 6, ...
         'MarkerFaceColor','m', ...
         'ButtonDownFcn', [ 'starts ' 'TUN_GridCenter'], 'Parent', allAxes.VTAxes )

