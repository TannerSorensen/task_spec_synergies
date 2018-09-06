function [F, BW, a, srate] = tubeResonances(area, tube_length)
% tubeResonances
% Louis Goldstein
% April 23 1996
% Calculate the resonances of an area function with
% an arbitary number of sections, and an arbitary length
% function [F, BW, a, srate] = tubeResonances(area, tube_length)
% Input arguments:
% area			vector of areas (in cm^2)
% tube_length	overall length of tube (in cm)
% Output arguments:
% F 			vector of formant frequencies
% BW			vector of bandwidths
% a				vector of filter coefficients
% srate			sampling rate
		
m = length(area);		% m is the number of area sections

% calculate the distance of each section from the glottis
section = 1:m;
dist = section*tube_length/m;

% plot distance from glottis against area
% subplot (2,1,1), plot (dist,area, 'o')
% hold
% subplot (2,1,1), plot (dist,area)
% xlabel ('Distance from glottis (cm)')
% ylabel ('Area in cm^2')
% hold
%pause

% sampling period has to be equal to the time it would take
% for a wave to travel from one section to the next
% and back
c = 35000;				 % speed of sound in cm/sec
T = (tube_length/m)*2/c; % time = distance / velocity
srate = 1/T;

% calculate the reflection coefficient between pairs of sections
for i = 1:m-1
    % debug 
  k(i) = (area(i+1) - area(i))/(area(i+1) + area(i));
end

% the last reflection coefficient is 1, since it the tube area
% is assumed to be small compared to the open air
% this represents lossless case.
k(m) = 1;

% calculate a filter coefficients from the reflection coefficients
a = rc2poly(k);
b =1;

% Plot Transfer function magnitude up to maxfreq
%
nfreqs = 512;
% maxfreq = 5000;
[h,w] = freqz(b,a,nfreqs);	%freqz returns the frequency response

% global freq
% global magnitude

% freq = w*srate/(2*pi);


% for i = 1:nfreqs
%   if (freq(i) > maxfreq)
%   		last_freq = i-1
% 		break;
%   end
% end
 

% indexFreq = freq <= maxfreq;
% magnitude = abs( h( indexFreq ) );
% freq = freq( indexFreq );



%subplot (2,1,2), plot (freq(1:last_freq), 10*log(abs(h(1:last_freq))))
%xlabel ('Frequency in Hz')
%ylabel ('DB')

% calculate formant frequencies and bandwiths from a coefficients
% and srate

% debug
[F, BW] = formants (a, srate);


%title (['F1 = ', int2str(F(1)), '  F2 = ', int2str(F(2)),'  F3 = ', int2str(F(3)),'  F4 = ', int2str(F(4)), '  F5 = ', int2str(F(5))])
 %    pause(.11)
