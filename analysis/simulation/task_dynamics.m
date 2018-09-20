function [t,phiOut,zOut] = task_dynamics(omega,z0,h1,h2,n_frames,timepoints_per_frame,phiInit,W,nZ,nPhi,z,phi,dzdt,dphidt,f)

% Get q nearest neighbors of each articulator parameter value.
n = size(phi,1);
fn = round(f*n);
[idx, dist] = knnsearch(phi,phi,'dist','euclidean','K',fn);

plain = 1:nPhi;             % indices
dot = nPhi+1:2*nPhi;        % indices

% (i,j)-entry is 1 if weight j is used to change task variable i
zPhiRel = logical([1 0 0 0 0 1 1 0; ...
    1 1 1 1 1 0 0 0; ...
    1 1 1 1 1 0 0 0; ...
    1 1 1 1 1 0 0 1; ...
    1 1 1 1 1 0 0 0; ...
    0 0 0 0 0 0 0 1]);

% parameters of the orthogonal projection operator
G_P = diag(zPhiRel'*double(omega~=0));

% parameters of the neutral gesture
% (see Saltzman & Munhall, 1989, Appendix A)
omega_N = 10;
B_N = 2*omega_N*eye(nPhi);
K_N = omega_N^2.*eye(nPhi);
G_N = eye(nPhi)-G_P; % equiv.: diag(~(zPhiRel'*double(omega~=0)));

% parameters of flow on task mass Z
K = diag(omega.^2);
B = diag(2.*omega);

% parameters of the simulation
% parameters of articulators PHI
n_timestamps = round(h2.*n_frames./h1);
zOut = NaN(nZ,n_timestamps);
t = NaN(1,n_timestamps);
phiOut = NaN(2.*nPhi,n_timestamps);

% locally linearize the ODE over N_FRAMES frames
for i=1:n_frames
    indx = (i-1)*timepoints_per_frame+1:i*timepoints_per_frame;
    
    if indx(1)-1 > 0
        t0 = t(indx(1)-1);
        phiInit = phiOut(:,indx(1)-1);
    else
        t0 = 0;
    end
    t1 = t0+h2-h1;
    tspan = t0:h1:t1;
    
    % get forward kinematic map and jacobian matrix
    J_t = zeros(nZ,nPhi);
    indx2 = knnsearch(phi,phiInit(1:nPhi)','dist','euclidean','K',1);
    F = lscov([ones(length(idx(indx2,:)),1) phi(idx(indx2,:),:)], z(idx(indx2,:),:), ...
        arrayfun(@(u) weight_fun(u), dist(indx2,:)./dist(indx2,end)));
    F = F';
    J = F(:,2:end);
    Jstar = jacStar(J,W,diag(omega~=0),nZ); % weighted pseudoinverse
    
    % flow on Z
    flow=@(t,phi)[phi(dot);Jstar*(-B*J*phi(dot)-K*(F*[1;phi(plain)]-z0)-J_t*phi(dot))-(G_P-Jstar*J)*B_N*phi(dot)+G_N*(-B_N*phi(dot)-K_N*phi(plain))];
    
    % solve ODE
    [tNew,phiNew] = ode45(flow,tspan,phiInit);
    
    % save result
    t(indx) = tNew;
    phiOut(:,indx) = phiNew';
    zOut(:,indx) = F*[ones(1,size(phiNew,1));phiNew(:,1:nPhi)'];
end

end