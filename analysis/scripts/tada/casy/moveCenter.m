function moveCenter

% Copyright Haskins Laboratories, Inc., 2001-2003
% 270 Crown Street, New Haven, CT 06514, USA
% programmer Yuriy Koblents-Mishke
% e-mail koblents@haskins.yale.edu

global TUN_GridCenter 

coords0 = get(gca,'CurrentPoint');
TUN_GridCenter = coords0(1, 1:2); % the screen cursor points here

refresh
