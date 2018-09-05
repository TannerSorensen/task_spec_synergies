function jacDot = getJacDot(dzdt,dwdt)

nf = 8;
nz = 6;
jacDot = zeros(nz,nf);

% multiple task variables (approach B)
% LA ~ jaw + lips1 + lips2
LzInd = 1;
LwInd = [1 6 7];
dLdw=lscov(dwdt(:,LwInd),dzdt(:,LzInd));
jacDot(LzInd,LwInd) = dLdw';
% TIP,PALATE,ROOT ~ jaw + tongue1 + ... + tongue4
TRzInd = [2 3 5];
TRwInd = [1 2 3 4 5];
dTRdw=lscov(dwdt(:,TRwInd),dzdt(:,TRzInd));
jacDot(TRzInd,TRwInd) = dTRdw';
% DORSUM ~ jaw + tongue1 + ... + tongue4 + vel
DzInd = 4;
DwInd = [1 2 3 4 5 6];
dDdw=lscov(dwdt(:,DwInd),dzdt(:,DzInd));
jacDot(DzInd,DwInd) = dDdw';
% VEL ~ vel
VzInd = 6;
VwInd = 8;
dVdw=lscov(dwdt(:,VwInd),dzdt(:,VzInd));
jacDot(VzInd,VwInd) = dVdw';

end