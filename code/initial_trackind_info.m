function sp = initial_trackind_info(vid_info, trackind, sp)
for ff = 1:length(trackind)
    im = vid_info.trackind{trackind(ff)}.name;
    if param_track.supermode
        sp{trackind(ff)}.regionSize = round(sqrt(size(im,1)*size(im,2)/param_track.numSuperpixel));
        sp{trackind(ff)}.label,  ~] = slicmex1(im,param_track.numSuperpixel,10);%numlabels is the same as number of superpixels
        sp{trackind(ff)}.label = uint32(sp{trackind(ff)}.label) + 1;
        sp{trackind(ff)}.maxNum = double(max(sp{trackind(ff)}.label(:)));
        [sp{trackind(ff)}.colors, sp{trackind(ff)}.centers, sp{trackind(ff)}.sizes] = getSuperpixelStats({im}, {sp{trackind(ff)}.label}, sp{trackind(ff)}.maxNum);
        if numel(find(sp{trackind(ff)}.sizes == 0)) > 0
            sp{trackind(ff)} = tidy_superpixel(sp{trackind(ff)});
        end
        for kk = 1:sp{trackind(ff)}.maxNum
            sp{trackind(ff)}.spPix{kk} = find(sp{trackind(ff)}.label == kk);
        end
        sp{trackind(ff)}.sizes = doublsete(sp{trackind(ff)}.sizes);
        sp{trackind(ff)}.centers = double(sp{trackind(ff)}.centers);
        [~, sp_hist] = t1_cal_hsi_hist(im2double(im), param_track.ch_bins_num, sp{trackind(ff)}.maxNum, sp{trackind(ff)}.label);
        sp_hist = sp_hist';
        sp{trackind(ff)}.sp_hist = sp_hist;
    else
        sp{trackind(ff)}.sizes = ones(ht*wd, 1);
        ccount = 1;
        [subx, suby] = ind2sub([ht, wd], [1:ht*wd]);
        sp{trackind(ff)}.centers(:, 1) = subx';
        sp{trackind(ff)}.centers(:, 2) = suby';
        sp{trackind(ff)}.colors(:, 1) = reshape(im(:,:,1), ht*wd, 1);
        sp{trackind(ff)}.colors(:, 2) = reshape(im(:,:,2), ht*wd, 1);
        sp{trackind(ff)}.colors(:, 3) = reshape(im(:,:,3), ht*wd, 1);
        sp{trackind(ff)}.label = reshape([1:ht*wd], ht, wd);
        sp{trackind(ff)}.maxNum = double(max(sp{trackind(ff)}.label(:)));%
        
        
        [tempsp.label,  ~] = slicmex1(im,param_track.numSuperpixel,10);%numlabels is the same as number of superpixels
        tempsp.label = uint32(tempsp.label) + 1;
        [~, sp_hist] = t1_cal_hsi_hist(im2double(im), param_track.ch_bins_num, max(tempsp.label(:)), tempsp.label);
       
        sp_hist = sp_hist';
        sp{trackind(ff)}.sp_hist =  sp_hist(reshape(tempsp.label, ht*wd, 1), :);
        sp_hist =  sp{trackind(ff)};
    end
end