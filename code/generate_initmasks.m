function [gt_mask] = generate_initmasks(vid_info, visual_cluster_path, cluster_names, trackind)
ht = vid_info.ht;
wd = vid_info.wd;
gt_mask = cell(vid_info.framenum,1);
for ii = 1:length(trackind)
    tmp = im2double(imread([visual_cluster_path '/' cluster_names(trackind(ii).name)]);
    tmp = imresize(tmp, [ht,wd]);
    tmp(tmp >= 0.5) = 1;
    tmp(tmp < 0.5) = 0;
    gt_mask{trackind(ii), 1} = tmp;
end

