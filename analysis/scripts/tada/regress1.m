function [b, res] = regress1(y, X)
N = size(X);
X = [ones(N(1),1) X];
[b, bint, res] = regress(y,X,0.05);