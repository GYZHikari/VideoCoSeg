function [gt_mask] = generate_initmasks(vid_info, visual_cluster_path, visual_fcn_path, names, trackind)
ht = vid_info.ht;
wd = vid_info.wd;
gt_mask = cell(vid_info.framenum,1);

for ii = 1:vid_info.framenum
    if intersect(ii, trackind)
        tmp = im2double(imread([visual_cluster_path '/' names(ii).name(1:end-4), '_mask.png']));
        tmp = imresize(tmp, [ht,wd]);
        tmp(tmp >= 0.5) = 1;
        tmp(tmp < 0.5) = 0;
        gt_mask{ii, 1} = tmp;
    else
        tmp = im2double(imread([visual_fcn_path '/' names(ii).name(1:end-4), '_obj.png']));
        tmp = imresize(tmp, [ht,wd]);
        tmp(tmp >= 0.5) = 1;
        tmp(tmp < 0.5) = 0;
        gt_mask{ii, 1} = tmp;
    end
    
end

