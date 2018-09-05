function [linear,dzdw,resid] = linearityTest(z,w,crit)

[~,dzdw,resid] = getFwdMap(z,w);
resid = mean(sqrt(resid));
linear = resid < crit;

end