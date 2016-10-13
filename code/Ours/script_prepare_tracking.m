sp = generate_sp_state(sp, videoAll, ff_initial, param_track, vid_info.ht, vid_info.wd);    
gt_est{ff_initial} = gt_mask{ff_initial};
trimap = double(gt_est{ff_initial});
im = videoAll{ff_initial};
[hist_model, fg_colorsL, fg_colorsS, bg_Colorss, fg_idxS,...
 fg_idxL, bg_idx] = gene_histSVM(sp{ff_initial}.sp_hist, trimap, vid_info.ht, vid_info.wd, sp{ff_initial}, param_track);
hist_initModel = hist_model;
[fg_idxCNN, mask] = gene_CNN_Hist_region(fg_colorsL, hist_initModel, sp{ff_initial}.label, fg_idxL);
mask = imfill(mask, 'hole');
if sum(sum(mask)) < (0.01*vid_info.ht*vid_info.wd)
    mask = trimap;
    fg_idxCNN = fg_idxL;
end
tri_objRate = numel(find(trimap~=0))./numel(trimap);
if tri_objRate <= 0.01
    mask = trimap;
    fg_idxCNN = fg_idxL;
end
gt_est{ff_initial} = mask;

if ~exist(res_cluster_path,'dir'), mkdir(res_cluster_path); end;
imwrite(gt_est{ff_initial}, [res_cluster_path '/' sprintf('%04d_mask.png',ff_initial)]);
if tri_objRate > 0.01
	[hist_model, fg_colorsL, fg_colorsS, bg_colorsS, fg_idx,...
 	fg_idxL, bg_idx] = gene_histSVM(sp{ff_initial}.sp_hist, mask, vid_info.ht, vid_info.wd, sp{ff_initial}, param_track);
end

fg_colorsS_init = fg_colorsS; bg_colorS_init = bg_colorsS;
fg_colorsS_all = []; bg_colorS_all = [];
[feats, pad] = gene_CNN(im, cnn_opt.mean_pix, cnn_opt.layers);                
cnnFeats{1}= reshapeCNNFeature(feats, pad, vid_info.wd, vid_info.ht, cnn_opt.layers, cnn_opt.scales);
if ~param_track.CNNpixel
    cnnFeats{1} = cnnfea_pixel2sp(cnnFeats{1}, sp{ff_initial}.spPix);
end
cnnFeats{2} = cnnFeats{1};
if param_track.CNNpixel
    fg_idxCNN = adjust_sp2pixel(fg_idxS, sp{ff_initial}.label);
    bg_idx = adjust_sp2pixel(bg_idx, sp{ff_initial}.label);
end
[cnn_model, feats_fg, feats_bg] = gene_CNNSVM(cnnFeats, fg_idxCNN, bg_idx, param_track);
feats_fg_init = feats_fg; feats_bg_init = feats_bg;
if listnum == totalmaxnum
    endlist_num = vid_info.framenum-1;
else
    endlist_num = trackind(listnum + 1) - 1;
end                      