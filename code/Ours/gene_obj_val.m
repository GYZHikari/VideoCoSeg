function [cand_obj_val, save_score] = gene_obj_val(affmat, pos_label_inds, response, motion, shape_variance, gamma, opt, type)
lambda_fcn = opt.lambda_fcn;
lambda_motion = opt.lambda_motion;
lambda_shape = opt.lambda_shape;
alpha = opt.alpha;
switch lower(type)
    case 'naive'
        cand_obj_val = alpha.*sum(sum(affmat(pos_label_inds, :))) - sum(gamma*length(pos_label_inds)) ;
    case 'fcn'
        cand_obj_val = alpha.*sum(sum(affmat(pos_label_inds, :))) - sum(gamma*length(pos_label_inds)) + lambda_fcn.*sum(response);%.*size(affmat, 1)
    case 'motion'
        cand_obj_val = alpha.*sum(sum(affmat(pos_label_inds, :))) - sum(gamma*length(pos_label_inds)) + lambda_motion.*sum(motion);
    case 'fcn-motion'
        cand_obj_val = alpha.*sum(sum(affmat(pos_label_inds, :))) - sum(gamma*length(pos_label_inds)) + lambda_fcn.*sum(response)+ lambda_motion.*sum(motion);
    case 'fcn-motion-shape'
        cand_obj_val = alpha.*sum(sum(affmat(pos_label_inds, :))) -  sum(gamma*length(pos_label_inds)) + ...
            lambda_fcn.*sum(response)+ lambda_motion.*sum(motion) - lambda_shape.*sum(shape_variance);
    otherwise
        error('No such opt.type!!!');
end

save_score.sum = sum(sum(affmat(pos_label_inds, :)));
save_score.fcn = sum(response);
save_score.motion = sum(motion);
save_score.variance = sum(shape_variance);
save_score.motionminvar = sum(motion) - sum(shape_variance);
