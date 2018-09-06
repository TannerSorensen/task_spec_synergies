function [Fout, BWout] = formants (acoef, srate, BWcutoff)
% FORMANTS
% Louis Goldstein
% April 19, 1999
% Get formant frequencies and bandwiths
% from a coefficients and sampling rate
% function [F, BW] = formants (acoef, srate)
% Input arguments:
% acoef		vector of a filter coefficients
% srate		sampling rate (in Hz)
% BWcutoff	cutoff Bandwidth of valid formant (HZ)
%           formant with a bandwidth wider than BWcutoff
%           will be deleted from the formant vector
% Output arguments:
% Fout		vector of formant frequencies
% BWout		vector of bandwidths

% formants frequencies (in radians/sample) correspond 
% to the angle of the roots of the a polynomial
% get these angles, and sort them into rank order.

if nargin < 3,  BWcutoff = 5000;end;
	
[F, order] = sort(angle(roots(acoef)));

% convert from radians/sample to Hz
F = F*srate/(2*pi);

% compute bandwidths from the magnitude of the roots, and
% convert to Hz
BW = -2*log(abs(roots(acoef)))*srate/(2*pi);

% reorder bandwidths into the same order as the frequencies
BW = BW(order);

% find positive frequencies with bandwidths less than cutoff

Fout = F( (F>0) & (BW<BWcutoff)  );
BWout = BW( (F>0) & (BW<BWcutoff) );
