function y = weightfun(u)
%WEIGHTFUN - weight function for the locally weighted linear regression,
%used to estimate the jacobian of the forward kinematic map
% 
% INPUT: 
%  u - input distance
% 
% FUNCTION OUTPUT: 
%  y - output weight
% 
% SAVED OUTPUT: 
%  none
% 
% Tanner Sorensen
% Signal Analysis and Interpretation Laboratory
% Apr. 16, 2017

    if u<=1
        y = (1-u^3)^3;
    else
        y = 0;
    end

end

