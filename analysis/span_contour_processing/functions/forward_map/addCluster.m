function [centers,fwd,jac,jacDot,clusterInd,linInd] = addCluster(curCluster,dzdt,dwdt,z,w,dzdw,resid,centers,fwd,jac,jacDot,clusterInd,linInd,linear)

% add center to container
centers = cat(1,centers,mean(w(curCluster,:),1));
% add forward map to container
fwd = cat(1,fwd,getFwdMap(z(curCluster,:),w(curCluster,:)));
% add jacobian to container
jac = cat(1,jac,dzdw);
% add time-derivative of jacobian to container
jacDot = cat(1,jacDot,getJacDot(dzdt(curCluster,:),dwdt(curCluster,:)));
% record data points in this cluster
clusterInd = clusterInd + (max(clusterInd)+1).*curCluster;
% record whether this cluster is truly linear
linInd = cat(1,linInd,linear);
% print
fprintf(1,'size: %d\nsqrt(MSE)=%.2f\nlinear: %d\n\n',sum(curCluster),resid,linear)

end