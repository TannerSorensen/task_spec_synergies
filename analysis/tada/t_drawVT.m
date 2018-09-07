function t_drawVT
% plotting outline on graphic window
%
% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu
%
% modified by Hosung Nam (hosung.nam@yale.edu)

persistent VTWindow
persistent VTAxes

if isempty( VTWindow ) || ~ishandle( VTWindow )
  VTWindow = figure( 'Name', 'Vocal Tract', ...
                     'NumberTitle', 'off', ...
                     'IntegerHandle', 'off', ...
                     'HandleVisibility', 'on' );
                 
end

if isempty( VTAxes ) || ~ishandle( VTAxes )
  VTAxes = axes( 'Parent', VTWindow ,...
               'HandleVisibility', 'on' );
  set(get( VTAxes,'XLabel'),'String','in mm')
  set(get( VTAxes,'YLabel'),'String','in mm')
end

% plot outlines
global UpperOutline
global BottomOutline 

global KeyPts
global GeoPts

% global SEG_Bezier_fix_Velum_VelMax
% global SEG_Bezier_fix_VelMax_Maxilla
% global SEG_Bezier_fix_Maxilla_Alveolus


% next operation will erase picture
set( VTAxes, 'NextPlot', 'replacechildren' )

plot( UpperOutline(:,1), UpperOutline(:,2), 'b-', 'Parent', VTAxes )    
     % upper outline: red,  star  markers


% subsecond plots not destroy the pevious 
set( VTAxes, 'NextPlot', 'add' )


if ~isreal( BottomOutline )
  BottomOutline
end   

plot( BottomOutline(:,1), BottomOutline(:,2), 'b-', 'Parent', VTAxes )   
     % lower outline: cyan, cross markers