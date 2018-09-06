function [H, w]= transfer_v2 (b, a, nfreqs)
% Hosung Nam
% 16 Feb. 2002
% input : b, a (coefficient b, a vector)
% output : H (frequency response), w (freqeuncy)

[Hb wb] = freqresp_v3(b, nfreqs);
[Ha wa] = freqresp_v3(a, nfreqs);


if wa == wb
    w = wb;
else
    error('wa \=wb');
end

H = Hb./Ha;