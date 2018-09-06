function [H, w]= freqresp_v3 (b, nfreqs)
% Hosung Nam
% 16 Feb. 2002
% input : b (filter coefficient vector)
% output : H (frequency response), w (freqeuncy)

nfreqs = 512;
w = linspace(0, pi, nfreqs);

len = length(b);
H = 0;
for n = 1:len
     H = H + b(n)*exp(-(n-1)*j*w);
end