function BW = getBandwidths (F)

% getBandwidths.m
% Louis Goldstein
% March 30, 1999
%
% use Fant's (1985) approximation to compute Bandwidth
% as a function of frequency, when Formants are known.
% see p. 62, equation (35)
%
% Fant, G. (1985) The vocal tract in your pocket calculator in 
% Fromkin, V. (ed). Phonetic Linguistics. (pp. 55-77).
% New York: Academic Press

if (length(F) < 4)
	disp ('*** Error! At least four formant frequencies are required to compute bandwidths')
	return
end
for i=1:length(F)
	term1 = 15*(500/F(i))^2;
	term2 = 20*(F(i)/500)^.5;
	ratio = (F(3)-F(2))/(F(4)-F(3));
	term3 = (F(2)/2000) * (1 + (ratio * 2)) * ((F(i)^2)/((500^2)));
	
	BW(i) = term1 + term2 + term3;
end
