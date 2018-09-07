%[source, time] = make_buzz_time(srate,f0,tot_dur);
f0 = 100;
AV = ones(1,100);
srate = 10000;
tot_dur = 1;
synfrm_dur = 10;

voiced = make_impulse (f0,srate, synfrm_dur,AV, tot_dur);
tot_samples = length(voiced);
tot_frames = length(AV);

% glottal resonator
% According to Klatt (1980), the -12DB/octave spectral roll-off
% of glottal pulse can be achieved with a glottal resonator 
% with the following characteristics:
RG = 0;							% RG is the frequency of the Glottal Resonator
BWG = 100;						% BWG is the bandwidth of the Glottal Resonator
[b_glo, a_glo]=resonance(srate,RG,BWG);
voiced=filter(b_glo,a_glo,voiced);		  
% aa
% Formant      frequency(Hz)     amplitude(dB)     bandwith(Hz)
% F1            671            29.78            34
% F2            1248            27.62            43
% F3            2458            21.90            55
% F4            3378            14.55            144
% F5            4281            18.46            87

% F = [671 1248 2458 3378 4281];
% BW = [34 43 55 144 87];
%  F = [584 1216 1649 2253 3419];
%  BW = [23.86 26.24 7.08 22.39 24.48];
F = [527 1395 1727 1989 2672];
BW = [21.16 25.20 21.45 23.99 24.00];
% F = [358 650 1437 1617 2693];
% BW = [11.49 13.65 -15.56 13.90 11.18];

in = voiced;

for i = 5:-1:1
[b,a]=resonance(srate,F(i),BW(i));
z = [];
[out, z]=filter(b,a,in, z);
end

b_rad = [.5 -.5];
a_rad = .5;
out = filter(b_rad,a_rad,out);

% m
% F1            527            21.16            47
% F2            1395            25.20            26
% F3            1727            21.45            34
% F4            1989            23.99            32
% F5            2672            24.00            38

% ng
% F1            584            23.86            45
% F2            1216            26.24            32
% F3            1649            7.08            39
% F4            2253            22.39            37
% F5            3419            25.58            48

% l
% F1            358            11.49            83
% F2            650            13.65            41
% F3            1437            -15.56            55
% F4            1617            -13.90            48
% F5            2693            -11.18            40