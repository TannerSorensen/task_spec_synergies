function [lib,centers,fwd,jac,jacDot,clusterInd,linInd] = breakCluster(curCluster,lib,dzdt,dwdt,z,w,k,minSize,centers,fwd,jac,jacDot,clusterInd,dzdw,resid,linInd,linear)

% break the current cluster into k clusters
idx = kmeans(w(curCluster,:),k);
if sum(idx==1)>minSize && sum(idx==2)>minSize
    % put broken clusters in library
    tmp = zeros(length(curCluster),1);
    tmp(curCluster==1) = idx;
    for i=1:k
        lib=cat(1,lib,logical(tmp==i));
    end
else
    % add center, jac, and jacDot to containers
    [centers,fwd,jac,jacDot,clusterInd,linInd] = addCluster(curCluster,dzdt,dwdt,z,w,dzdw,resid,centers,fwd,jac,jacDot,clusterInd,linInd,linear);
end

end