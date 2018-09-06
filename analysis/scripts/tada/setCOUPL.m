function [relphase_a, relphase_targ] = setCOUPL(couplOSC, a, targ, relphase_a, relphase_targ)
nCOUPL = length(relphase_a);
nOSC = round(roots([1, -1, -nCOUPL*2]));
nOSC = nOSC(find(nOSC>0));

for n =1:size(couplOSC,1)
    if couplOSC(n,1) > couplOSC(n,2)
        targ = -targ;
        tmp=[couplOSC(n,1) couplOSC(n,2)]; couplOSC(n,1) = tmp(2); couplOSC(n,2) = tmp(1);
    end
    iCOUPL = 0;
    for i = 1:nOSC
        for j=i+1:nOSC
            iCOUPL = iCOUPL+1;
            if i == couplOSC(n,1) & j == couplOSC(n,2)
                isetCOUPL = iCOUPL;
            end
        end
    end
    relphase_a(isetCOUPL) = 1; %relphase_a(isetCOUPL) = a(n);
    relphase_a(isetCOUPL) = ~isempty(find(a(:,n)>0));
    relphase_targ(isetCOUPL) = targ(n);
end

