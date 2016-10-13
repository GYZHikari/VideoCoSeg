function [cur_pos_inds, obj_val, save_vals] = submodularFunc(affmat, candi_inds_all, response, motion, shape_variance, opt)
cur_pos_inds = [];
obj_val = [];
save_vals = [];
gamma = opt.gamma;
% lambda = opt.lambda;
type = opt.type;
if length(candi_inds_all) <= 2 && ~strcmp(opt.seedNum, 'all')
    seedNum = 1;
else
    switch lower(opt.seedNum)
        case 'one'
            seedNum = 1;
        case 'adaptive'
            seedNum = floor(length(candi_inds_all)./1.2);
        case 'all'
            seedNum = length(candi_inds_all);
        otherwise
            error('No such seed number');
    end
end

for i= 1:seedNum
    cand_pos_label_inds = setdiff(candi_inds_all, cur_pos_inds);
    
    num_cand = length(cand_pos_label_inds);
    cand_ranks = zeros(num_cand, 1);
    cand_obj_val = zeros(num_cand, 1);
    for j = 1:num_cand
        pos_label_inds = [cur_pos_inds; cand_pos_label_inds(j)];
        [cand_obj_val(j), save_obj_sub(j)] = gene_obj_val(affmat, pos_label_inds, response(pos_label_inds), ...
            motion(pos_label_inds), shape_variance(pos_label_inds),gamma, opt, type);
    end
    [max_val, max_ind] = max(cand_obj_val);
    if ~strcmp(opt.seedNum, 'all')
    if i > 1 && max_val < obj_val(i - 1)
        break;
    end
    if i > 2 && (max_val - obj_val(i - 1)) < (obj_val(i - 1) - obj_val(i - 2))*0.8
        break;
    end
    end
    cur_pos_inds = [cur_pos_inds; cand_pos_label_inds(max_ind)];
    obj_val = [obj_val; max_val];
    save_vals = [save_vals; save_obj_sub(max_ind)];
end

if opt.show
    plot([1:length(obj_val)], obj_val);
end
