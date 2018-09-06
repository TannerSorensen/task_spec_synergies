function [out, time, freq, magnitude] = syn_buzz (srate,F,BW,f0,dur)
% syn_buzz.m
% Louis Goldstein
% 26 Feb 2003
% formant synthesizer
% calculate waveform based on input specification
% usage:
% [out, t] = syn_buzz (srate,F,BW,f0,dur)
% input arguments:
% srate	sampling rate (in Hz)
% F     vector of formant frequencies (use 4 or 5 for 10K srate)
% BW    vector of formant bandwidths  (use 4 or 5 for 10K srate)
% f0    fundamental frequency (in Hz)
% dur   duration (in secs)
% nf	number of formants
%returned arguments:
% out	vector with synthesized waveform samples
% time		vector with time values (in ms) of each successive sample
% freq  transfer function frequencies
% magnitude transfer function magnitudes

% set amplitude and generate impulse train for source
% impulse train has one sample with value=1 for each pitch period
% all other values are zero

nf = length (F);
amp = 100;						% arbitary scaling of source
[source, time] = make_buzz_time(srate,f0,dur);
source = source*amp;
time = time*1000;						% give time in milliseconds
% 
% figure (1) 
% plot (time(1001:1500),source(1001:1500));
% xlabel ('Time in milliseconds')
% title ('Glottal Source Wave');
% figure (2)
% spectrum (source, srate)
% soundsc (source, srate)
% pause

% filter impulse train thru low-pass filter 
% to get approximation to shape of glottal pulse
% According to Klatt (1980), the -12DB/octave spectral roll-off
% of glottal pulse can be achieved with a glottal resonator 
% with the following characteristics:
RG = 0;							% RG is the frequency of the Glottal Resonator
BWG = 100;						% BWG is the bandwidth of the Glottal Resonator
[b,a]=resonance(srate,RG,BWG);	
out=filter(b,a,source);			
source=out;
% figure (1) 
% plot (time(1001:1500),source(1001:1500));
% xlabel ('Time in milliseconds')
% title ('Glottal Source Wave');
% figure (2)
% spectrum (source, srate)
% soundsc (source, srate)
% pause
% filter souce waveform thru VT formant cascade
% filter thru the nf resonators in sequence
in = source;
for i = nf:-1:1
   [b,a]=resonance(srate,F(i),BW(i));	
   out = filter(b,a,in);
%    figure (1) 
% 	plot (time(1001:1200),out(1001:1200));
% 	xlabel ('Time in milliseconds')
% 	title (['Filtered output after F' num2str(i)]);
% 	figure (2)
% 	spectrum (out, srate)
% 	soundsc (out, srate)
% 	pause
   in = out;
end
%
% set coefficients of high pass radiation filter and filter
% this calculates volume velocity at a distance from the the mouth,
% rather than at the mouth;
% based on equation in Klatt (1980)
b_rad = [1 -1];
a_rad = 1;
out = filter(b_rad,a_rad,in);

% figure(1)
% plot (time(1001:1200),out(1001:1200));
% xlabel ('Time in milliseconds')
% title (['Filtered output after Radiation filter']);
% figure (2)
% spectrum (out, srate)
% soundsc (out, srate)
% pause

% plot output waveform and play it

% Now we are done with synthesis, and we could stop now.
% But first let us compute the overall transfer function H(z)
% of the vocal tract, as specified by the entire set of nf
% formant resonators.
% This is just the product of the all the individual transfer
% functions

% set numerator and denominator of H(z) to 1 at the beginning of the loop
VT_num = 1;	% VT transfer function numerator
VT_den = 1; % VT transfer function denominator

% Loop through nf formants (as above), this time multiplying the 
% numerator and denominator of the transfer function 
% Since the denominator is a vector representing the coeffients of
% a polynomial, multiplication is achieved by the conv() function
% which performs a "convolution" of two vectors, which is the technical
% term for this operation.

for i = 1:nf
   [b,a]=resonance(srate,F(i),BW(i));
   VT_num = VT_num .* b;
   VT_den = conv(VT_den,a);		%conv muliplies two polynomials
end

% Note that the above loop could be combined, in a maximally compact program
% with the synthesis loop above.
% They have been separated to show that this H(z) calculation is irrelevant
% to the actual synthesis, and to keep the synthesis loop maximally simple.

% Plot Transfer function magnitude
%
[h,w] = freqz(VT_num,VT_den,100);	%freqz returns the frequency response
freq = w*srate/(2.*pi);
magnitude = abs(h);
% figure (5)
% plot (w*srate/(2.*pi), 10*log(abs(h)))
% ylabel ('DB')
% xlabel ('Frequency in Hz')
% title ('Vocal Tract Transfer Function')


