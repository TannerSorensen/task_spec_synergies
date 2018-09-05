function [U,V,varpercent,m]=span_pca(X,L)
  
  % Performs PCA on dataset X, outputing L components. X is the table of
  % components (each column a component), V is the eigenvalues, and
  % varpercent the percentage of variance explained. If L is omitted full
  % PCA is returned (L=dimensionality)
    % asterios.toutios, 27/5/2008

[N,D] = size(X);
m = mean(X);                     
X = X - ones(N,1)*m;  

% Covariance matrix
S = X'*X/N;

if nargin<2 
  L=D;
end;

% PCA by SVD on the covariance matrix
[U,Vtemp,U1] = svds(S,L);

% Keep L components
U = U(:,1:L);
Vtemp = diag(Vtemp);
V = Vtemp(1:L);

if nargout>2
  for i=1:L
    %varpercent(i)=sum(Vtemp(1:i))/sum(Vtemp)*100;
    varpercent(i)=Vtemp(i)/sum(Vtemp)*100;
  end;
end;
