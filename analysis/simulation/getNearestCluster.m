function indx = getNearestCluster(w,centers,nf,varargin)

if nargin < 4
    dist = sqrt(sum((centers-(ones(size(centers,1),1)*w(1:nf)')).^2,2));
    [~,indx] = min(dist);
elseif ischar(varargin{1}) && strcmp(varargin{1},'all')
    % get all the clusters whose centers are less than CRIT distance away
    dist = sqrt(sum((centers-(ones(size(centers,1),1)*w(1:nf)')).^2,2));
    crit = varargin{2};
    indx = find(dist < crit);
elseif isnumeric(varargin{1})
    % get the NBEST clusters
    dist = sqrt(sum((centers-(ones(size(centers,1),1)*w(1:nf)')).^2,2));
    n_best = varargin{1};
    [~,indx] = sort(dist);
    indx = indx(1:n_best);
elseif ischar(varargin{1}) && strcmp(varargin{1},'z')
    
    F = varargin{2};
    zInit = varargin{3};
    zInd = ~isnan(zInit);
    nClusters = length(F);
    
    z_centers=zeros(6,nClusters);
    for i=1:nClusters
        z_centers(:,i) = F{i}*[1 centers(i,:)]';
    end
    
    dist = sqrt(sum((z_centers(zInd,:)-repmat(zInit(zInd),1,size(z_centers,2))).^2,1));
    n_best = varargin{4};
    [~,indx] = sort(dist);
    indx = indx(1:n_best);
end

end