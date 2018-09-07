function [p,t]=find_peaks(s)
% finds peaks and throughs (compute diff's sign function)

ds=diff(s);
ds=[ds(1);ds];%pad diff
zero_diff=find(ds(2:end)==0)+1; %find diff zeros
ds(zero_diff)=ds(zero_diff-1); %replace diff zeros with the earlier
ds=sign(ds);
ds=diff(ds);
t=find(ds>0);
p=find(ds<0);