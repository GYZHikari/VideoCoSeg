ff_initial = List(1);
if ff_initial==1
	continue;
end
gtEst{ff_initial} = gtMask{ff_initial};
im = videoAll{ff_initial};
trimap = double(gtEst{ff_initial});
sp = generate_sp_state(videoAll, ff_initial, param_track, vid_info.ht, vid_info.wd);
[histModel, fg_colorsL, fg_colorsS, bg_colorsS, fgIdxS, fgIdxL, bgIdx] = gene_histSVM(sp{ff_initial}.sp_hist, trimap, vid_info.ht, vid_info.wd, sp{ff_initial}, param_track);
histInitModel = histModel;
[fgIdxCNN, mask] = gene_CNN_Hist_region(fgColorsL, histInitModel, sp{ff_initial}.label, fgIdxL);
mask = imfill(mask, 'hole');
if sum(sum(mask)) < (0.01*vid_info.ht*vid_info.wd)
    mask = trimap;
    fgIdxCNN = fgIdxL;
end
triObjRate = numel(find(trimap~=0))./numel(trimap);
if triObjRate <= 0.01
    mask = trimap;
    fgIdxCNN = fgIdxL;
end
gt_est{ff_initial} = mask;
if ~exist(listpath,'dir'), mkdir(listpath); end;
imwrite(gt_est{ff_initial}, [listpath '/' sprintf('%04d_mask.png',ff_initial)]);
if triObjRate > 0.01
    [histModel, fg_colorsL, fg_colorsS, bg_colorsS, fgIdxS, fgIdxL, bgIdx] = gene_histSVM(sp{ff_initial}.sp_hist, mask, vid_info.ht, vid_info.wd, sp{ff_initial}, param_track);
end
fg_colorsS_init = fg_colorsS; bg_colorS_init = bg_colorsS;
fg_colorsS_all = []; bg_colorS_all = [];
[feats, pad] = gene_CNN(im, cnn_opt.mean_pix, cnn_opt.layers);
cnnFeats{1}= reshapeCNNFeature(feats,pad,vid_info.wd,vid_info.ht,cnn_opt.layers,cnn_opt.scales);
if ~opt.CNNpixel
   cnnFeats{1} = cnnfea_pixel2sp(cnnFeats{1}, sp{ff_initial}.spPix);
end
cnnFeats{2} = cnnFeats{1};
if opt.CNNpixel
    fgIdxCNN = adjust_sp2pixel(fgIdxS, sp{ff_initial}.label);
    bgIdx = adjust_sp2pixel(bgIdx, sp{ff_initial}.label);
end
[cnnModel, feats_fg, feats_bg] = gene_CNNSVM(cnnFeats, fgIdxCNN, bgIdx, param_track);
feats_fg_init = feats_fg; feats_bg_init = feats_bg;
for ff = ff_initial : -1 : 2
    sp = generate_sp_state(videoAll, ff-1, param_track, vid_info.ht, vid_info.wd);
    cnnFeats{1} = cnnFeats{2};
    [feats, pad] = gene_CNN(videoAll{ff - 1}, cnn_opt.mean_pix, cnn_opt.layers);
    cnnFeats{2} = reshapeCNNFeature(feats,pad,vid_info.wd,vid_info.ht,cnn_opt.layers,cnn_opt.scales);
    if ~opt.CNNpixel
        cnnFeats{2} = cnnfea_pixel2sp(cnnFeats{2}, sp{ff-1}.spPix);
    end
    %% reinitialize
    %% update models
    if ff < ff_initial
        cnnModel = geneCNN_SVM_v1(cnnFeats, gt_est, feats_fg_init, feats_bg_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
        histModel = gene_histSVM_v1( sp{ff}.sp_hist, gt_est, fg_colorsS_init, bg_colorS_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
    end
    
    %% flow estimation for previous frame object region
    video{1} = cell2mat(videoAll(ff)); video{2} = cell2mat(videoAll(ff-1));
    flows = flowsAll_Inv(ff - 1);
    nFrames = 2;
    spdata{1} = cell2mat(sp(ff));
    spdata{2} = cell2mat(sp(ff - 1));
    imBoxes{1} = gtEst{ff};
    [meanFlows, flowMask] = gene_flowbased_propagation(imBoxes, flows);
    [imBoxes, imLarge] = gene_flow_hist_propagation(imBoxes, meanFlows, sp_hist, histInitModel, vid_info.ht, vid_info.wd, ff, param_track, sp{ff - 1}, video{2});
    [subFeats, subPixels, subPixelsNum, ...
        subPixels_mask, subPixelsNum_mask, ...
        subColors, subCenters, subColors_pixel, ...
        subCenters_pixel, colors, imLarges, fgIdxL] = gene_preProcessingPixel_hist_cnn(video, imBoxes, cnnFeats, ...
        meanFlows, nFrames, vid_info.ht, vid_info.wd, param_track, spdata, cnnModel);
    [unaryPixelPotentials, pairPixelPotentials] = gene_pixel_potentials_hist_cnn(subFeats, subPixels, subPixelsNum,...
        subPixels_mask, subPixelsNum_mask, subColors,...
        subCenters, subColors_pixel, subCenters_pixel,...
        colors, imLarges, flows, cnnModel, histModel,...
        fgIdxL, nFrames, vid_info.ht, vid_info.wd, param_track, enopt, spdata);
    unaryPotentials = unaryPixelPotentials;
    pairPotentials.source = pairPixelPotentials.source;
    pairPotentials.destination = pairPixelPotentials.destination;
    pairPotentials.value = pairPixelPotentials.value;
    [~,labels] = maxflow_mex_optimisedWrapper(pairPotentials, single(unaryPotentials));
    pixelLabels2 = labels;
    gt_est = draw_results(videoAll, [], ff, vid_info.ht, vid_info.wd, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, pixelLabels2, fgIdxL, imBoxes, imLarge, gt_est, param_track);
end