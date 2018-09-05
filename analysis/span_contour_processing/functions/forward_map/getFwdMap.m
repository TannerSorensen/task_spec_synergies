function [fwd,J,resid] = getFwdMap(z,w)

nf = 8;
nz = 6;
int = ones(size(w,1),1);
fwd = zeros(nz,nf+1);

% % multiple task variables (approach A)
% fwd=lscov([int, w],z);
% fwd = fwd';

% LA ~ jaw + lips1 + lips2
LzInd = 1;
LwInd = [1 6 7];
[dLdw,~,resid1]=lscov([int,w(:,LwInd)],z(:,LzInd));
fwd(LzInd,[1 LwInd+1]) = dLdw';
% TIP,PALATE,ROOT ~ jaw + tongue1 + ... + tongue4
TRzInd = [2 3 5];
TRwInd = [1 2 3 4 5];
[dTRdw,~,resid2]=lscov([int,w(:,TRwInd)],z(:,TRzInd));
fwd(TRzInd,[1 TRwInd+1]) = dTRdw';
% DORSUM ~ jaw + tongue1 + ... + tongue4 + vel
DzInd = 4;
DwInd = [1 2 3 4 5 6];
[dDdw,~,resid3]=lscov([int,w(:,DwInd)],z(:,DzInd));
fwd(DzInd,[1 DwInd+1]) = dDdw';
% VEL ~ vel
VzInd = 6;
VwInd = 8;
[dVdw,~,resid4]=lscov([int,w(:,VwInd)],z(:,VzInd));
fwd(VzInd,[1 VwInd+1]) = dVdw';

J = fwd(:,2:end);

resid = [resid1 resid2 resid3 resid4];

end