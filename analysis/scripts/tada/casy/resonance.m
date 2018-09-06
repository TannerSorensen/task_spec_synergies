function [b,a] = resonance (srate,F,BW)
% resonance.m
% Louis Goldstein
% Compute the three coeficients of a digital resonator
% Use the equation in Klatt(1980)
% Usage:
% [b,a] = resonance (srate,F,BW)
% Input arguments:
% srate		sampling rate (in Hz)
% F			resonator frequency (in Hz)
% BW		resonator bandwidth (in Hz)
% Output arguments:
% b			coefficients of numerator of H(z)
% a	 		coefficients of denominator of H(z)

T = 1/srate;				% T is the sample period
a(3) = -exp(-2*pi*BW*T);
a(2) = 2*exp(-pi*BW*T)*cos(2*pi*F*T);
a(1) = 1;
b = 1-a(2)-a(3);
% we have to take the negative of a(2) and a(3)
% because of how MATLAB's filter() function is written
a(2) = -a(2);
a(3) = -a(3);
