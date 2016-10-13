function  affmat = gene_sub_graph(weights, ind1, ind2, indNum, type)
% all graphs

switch lower(type)
    case 'cnn'
        affmat = zeros(indNum, indNum);
        affmat(ind1{1}) = weights{1};
        affmat(ind1{2}) = weights{1};
    case 'shape'
        affmat = zeros(indNum, indNum);
        affmat(ind1{1}) = weights{2};
        affmat(ind1{2}) = weights{2};
    case 'intra-inter'
        affmat = zeros(indNum, indNum);
        affmat(ind1{1}) = weights{1};
        affmat(ind1{2}) = weights{1};
        [value, index] = intersect(ind1{1}, ind2{1});
%         affmat(ind2{1}) = weights{1}(index).* weights{2}(index);
         affmat(ind2{1}) = weights{1}(index) + weights{2}(index);
        [value, index] = intersect(ind1{2}, ind2{2});
%         affmat(ind2{2}) = weights{1}(index).* weights{2}(index);
         affmat(ind2{2}) = weights{1}(index) + weights{2}(index);
    case 'intra-inter-0'
        affmat = zeros(indNum, indNum);
        [value, index] = intersect(ind1{1}, ind2{1});
        affmat(ind2{1}) = weights{1}(index);
        [value, index] = intersect(ind1{2}, ind2{2});
        affmat(ind2{2}) = weights{1}(index);
    otherwise
        error('No Such graph type!!');
end