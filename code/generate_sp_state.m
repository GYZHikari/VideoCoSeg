function sp = generate_sp_state(videoAll, ind, param_track, ht, wd)
if param_track.supermode
    sp{ind}.regionSize = round(sqrt(size(videoAll{ind},1)*size(videoAll{ind},2)/param_track.numSuperpixel));
    [sp{ind}.label,  ~] = slicmex1(videoAll{ind},param_track.numSuperpixel,10);%numlabels is the same as number of superpixels
    sp{ind}.label = uint32(sp{ind}.label) + 1;        
    sp{ind}.maxNum = double(max(sp{ind}.label(:)));
    [sp{ind}.colors, sp{ind}.centers, sp{ind}.sizes] = getSuperpixelStats({videoAll{ind}}, {sp{ind}.label}, sp{ind}.maxNum);
    
    if numel(find(sp{ind}.sizes == 0)) > 0
        sp{ind} = tidy_superpixel(sp{ind});
    end
    for kk = 1:sp{ind}.maxNum
        sp{ind}.spPix{kk} = find(sp{ind}.label == kk);
    end
    sp{ind}.sizes = double(sp{ind}.sizes);
    sp{ind}.centers = double(sp{ind}.centers);
    [~, sp_hist] = t1_cal_hsi_hist(im2double(videoAll{ind}), param_track.ch_bins_num, sp{ind}.maxNum, sp{ind}.label);
    sp_hist = sp_hist';
    sp{ind}.sp_hist = sp_hist;
else
    sp{ind}.sizes = ones(ht*wd, 1);
    [subx, suby] = ind2sub([ht, wd], [1:ht*wd]);
    sp{ind}.centers(:, 1) = subx';
    sp{ind}.centers(:, 2) = suby';
    
    %                     sp{List(ff)}.centers = [];
    sp{ind}.colors(:, 1) = reshape(videoAll{ind}(:,:,1), ht*wd, 1);
    sp{ind}.colors(:, 2) = reshape(videoAll{ind}(:,:,2), ht*wd, 1);
    sp{ind}.colors(:, 3) = reshape(videoAll{ind}(:,:,3), ht*wd, 1);
    sp{ind}.label = reshape([1:ht*wd], ht, wd);
    sp{ind}.maxNum = double(max(sp{ind}.label(:)));

    [tempsp.label,  ~] = slicmex1(videoAll{ind}, param_track.numSuperpixel, 10);%numlabels is the same as number of superpixels
    tempsp.label = uint32(tempsp.label) + 1;
    [~, sp_hist] = t1_cal_hsi_hist(im2double(videoAll{ind}), opt.ch_bins_num, max(tempsp.label(:)), tempsp.label);
    sp_hist = sp_hist';
    sp{ind}.sp_hist =  sp_hist(reshape(tempsp.label, vid_info.ht*vid_info.wd, 1), :);
end