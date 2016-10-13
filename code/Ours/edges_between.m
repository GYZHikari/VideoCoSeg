function edges = edges_between(inds)
if isempty(inds)
    edges = [];
end

num = length(inds);
mat = tril(ones(num), -1);
[row, col] = find(mat);
edges = [inds(row), inds(col)];
end
