function [t,phi,z,clusterID] = task_dynamics_normalized(omega,z0,dt,deltat,n_frames,phiInit,W,centers,fwd,jac,jacDot,Nz,Nphi,names)

plain = 1:Nphi;             % indices
dot = Nphi+1:2*Nphi;        % indices

% (i,j)-entry is 1 if weight j is used to change task variable i
zPhiRel = [1 0 0 0 0 1 1 0; ...
    1 1 1 1 1 0 0 0; ...
    1 1 1 1 1 0 0 0; ...
    1 1 1 1 1 0 0 1; ...
    1 1 1 1 1 0 0 0; ...
    0 0 0 0 0 0 0 1];

% parameters of the orthogonal projection operator
G_P = diag(zPhiRel'*double(omega~=0));

% parameters of the neutral gesture
% (see Saltzman & Munhall, 1989, Appendix A)
omega_N = 10;
B_N = 2*omega_N*eye(Nphi);
K_N = omega_N^2.*eye(Nphi);
G_N = eye(Nphi)-G_P; % equiv.: diag(~(zPhiRel'*double(omega~=0)));

% parameters of flow on task mass Z
K = diag(omega.^2);
B = diag(2.*omega);

% parameters of the simulation
% parameters of articulators PHI
indx = getNearestCluster(phiInit,centers,names);

% locally linearize the ODE over N_FRAMES frames
for i=1:n_frames
    
    F = fwd{indx};
    J = jac{indx};
    J_t = jacDot{indx};
    Jstar = jacStar(J,W,diag(omega~=0),Nz); % weighted pseudoinverse
    
    % flow on Z
    f=@(t,phi)[phi(dot);Jstar*(-B*J*phi(dot)-K*(F*[1;phi(plain)]-z0)-J_t*phi(dot))-(G_P-Jstar*J)*B_N*phi(dot)+G_N*(-B_N*phi(dot)-K_N*phi(plain))];
    
    % solve ODE
    if i==1
        [tNew,phiNew] = ode45(f,dt:dt:deltat,phiInit);
    else
        [tNew,phiNew] = ode45(f,dt:dt:deltat,phi(:,end));
    end
    
    % save result
    
    if i==1
        clusterID = indx*ones(length(tNew),1);
        t = tNew;
        phi = phiNew';
        z = F*[ones(1,size(phiNew,1));phiNew(:,1:Nphi)'];
    else
        t(end) = [];
        phi(:,end) = [];
        clusterID(end) = [];
        z(:,end) = [];
        clusterID = cat(1,clusterID,indx*ones(length(tNew),1));
        t = cat(1,t,t(end)+tNew);
        phi = cat(2,phi,phiNew');
        z = cat(2,z,F*[ones(1,size(phiNew,1));phiNew(:,1:Nphi)']);
    end
    
    %indx = getNearestCluster(phi(:,end),centers,names);
    indx = getNearestCluster([],centers,names,'z',fwd,z(:,end),1);
end

end