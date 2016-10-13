function weights = gene_sub_weight(indNum, feature, shape, opt)

inds = [1:indNum]';
edges = edges_between(inds);
row = edges(:,1); col = edges(:,2);

switch lower(opt.edge_type)
    case 'cnn'
        if strcmp(opt.normal_feat, 'norm')%norm or none
            for jj = 1:size(feature, 1)
                feature(jj, :) = normal_gyz(feature(jj, :) );
            end
        end
        weights{1} = gene_distance_feature(feature(row, :), feature(col, :), opt.dis_type);
    case 'shape'
        if strcmp(opt.normal_feat, 'norm')%norm or none
            for jj = 1:size(feature, 1)
                shape(jj, :) = normal_gyz(shape(jj, :) );
            end
        end
        weights{1} = gene_distance_feature(shape(row, :), shape(col, :), opt.dis_type);
    case 'intra-inter'
        if strcmp(opt.normal_feat, 'norm')%norm or none
            for jj = 1:size(feature, 1)
                feature(jj, :) = normal_gyz(feature(jj, :) );
                shape(jj, :) = normal_gyz(shape(jj, :) );
            end
        end
        weights{1} = gene_distance_feature(feature(row, :), feature(col, :), opt.dis_type);
        weights{2} = gene_distance_feature(shape(row, :), shape(col, :), opt.dis_type);
end