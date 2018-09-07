function startKey( s ) 

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

  set(gcbf,'WindowButtonMotionFcn',['modkey ' s] )
  set(gcbf,'WindowButtonUpFcn', ... 
           'set(gcbf,''WindowButtonMotionFcn'','''')')
 
