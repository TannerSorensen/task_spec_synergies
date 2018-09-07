function dy = t_ode(t, a_state, adotdot)
% Copyright Haskins Laboratories, Inc., 2000-2004
% 270 Crown Street, New Haven, CT 06514, USA
% coded by Hosung Nam (hosung.nam@yale.edu)
%

%=== RUNGE-KUTTA===%
adot = a_state(15:28);
dy = [adot; adotdot];