
for ff = ff_initial:endlist_num
    sp = generate_sp_state(videoAll, ff+1, param_track, vid_info.ht, vid_info.wd);
    %% load and reshape CNN features
    cnnFeats{1} = cnnFeats{2};
    [feats, pad] = gene_CNN(videoAll{ff + 1}, cnn_opt.mean_pix, cnn_opt.layers);
    cnnFeats{2} = reshapeCNNFeature(feats,pad, vid_info.wd, vid_info.ht, cnn_opt.layers, cnn_opt.scales);
    if ~param_track.CNNpixel
        cnnFeats{2} = cnnfea_pixel2sp(cnnFeats{2}, sp{ff+1}.spPix);
    end
  
    if ff > ff_initial
        cnnModel = geneCNN_SVM_v1(cnnFeats, gt_est, feats_fg_init, feats_bg_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
        histModel = gene_histSVM_v1( sp{ff}.sp_hist , gt_est, fg_colorsS_init, bg_colorS_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
    end
    
    %% flow estimation for next frame object region
    video = videoAll(ff:ff+1); flows = flowsAll(ff); nFrames = 2;
    spdata = sp(ff:ff+1);
    imBoxes{1} = gtEst{ff};
    [meanFlows, flowMask] = gene_flowbased_propagation(imBoxes, flows); 
    [imBoxes, imLarge] = gene_flow_hist_propagation(imBoxes, meanFlows, sp{ff + 1}.sp_hist, histInitModel, vid_info.ht, vid_info.wd, ff, param_track, sp{ff + 1});
    [subFeats, subPixels, subPixelsNum, ...
        subPixels_mask, subPixelsNum_mask, ...
        subColors, subCenters, subColors_pixel, ...
        subCenters_pixel, colors, imLarges, fgIdxL] = gene_preProcessingPixel_hist_cnn(video, imBoxes, cnnFeats, ...
        meanFlows, nFrames, vid_info.ht, vid_info.wd, param_track, spdata, cnnModel); 
%     toc
    
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
    gt_est = draw_results_next(videoAll, []], ff, ht, wd, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, pixelLabels2, fgIdxL, imBoxes, imLarge, gt_est, param_track);
    imwrite(gt_est{ff + 1}, [res_cluster_path '/' sprintf('%04d_mask.png',ff+1)]);
end