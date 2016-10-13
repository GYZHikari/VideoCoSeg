function affmat = gene_weight( feature, nodes, theta)
affmat = zeros(numel(nodes), numel(nodes));
%% attach addtional connection/edge
edges = edges_between(nodes);

%% compute affinity matrix value
row = edges(:,1); col = edges(:,2);
ind = sub2ind(size(affmat), row, col); 

        tmp = sum( (feature(row,:) - feature(col,:)).^2, 2);
        valDistances = sqrt(tmp)+eps;        
   

minVal = min(valDistances);
valDistances=(valDistances-minVal)/(max(valDistances)-minVal);


weights=exp(-theta*valDistances);
affmat(ind) = weights;
ind = sub2ind(size(affmat), col, row); 
affmat(ind) = weights;

end

function edges = edges_between(inds)
    if isempty(inds)
        edges = [];
    end
    
    num = length(inds);   
    mat = tril(ones(num), -1);
    [row, col] = find(mat);
    edges = [inds(row), inds(col)];  
end

