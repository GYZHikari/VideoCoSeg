
for ff = back_start : -1 : back_end
    sp = generate_sp_state(sp, videoAll, ff - 1, param_track, vid_info.ht, vid_info.wd);
    cnnFeats{1} = cnnFeats{2};
    [feats, pad] = gene_CNN(videoAll{ff - 1}, cnn_opt.mean_pix, cnn_opt.layers);
    cnnFeats{2} = reshapeCNNFeature(feats,pad,vid_info.wd,vid_info.ht,cnn_opt.layers, cnn_opt.scales);
    if ~param_track.CNNpixel
        cnnFeats{2} = cnnfea_pixel2sp(cnnFeats{2}, sp{ff-1}.spPix);
    end
    if ff <= back_start
        cnn_model = geneCNN_SVM_v1(cnnFeats, gt_est, feats_fg_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
        hist_model = gene_histSVM_v1( sp{ff}.sp_hist, gt_est, fg_colorsS_init, ff, vid_info.ht, vid_info.wd, param_track, sp{ff});
    end
    video{1} = cell2mat(videoAll(ff)); video{2} = cell2mat(videoAll(ff-1));
    flows = {flowsAll_Inv(:,:,:,ff - 1)};
    nFrames = 2;
    spdata{1} = cell2mat(sp(ff));
    spdata{2} = cell2mat(sp(ff - 1));
    imBoxes{1} = gt_est{ff};
    [meanFlows, flowMask] = gene_flowbased_propagation(imBoxes, flows); 
    [imBoxes, imLarge] = gene_flow_hist_propagation(imBoxes, meanFlows, sp{ff - 1}.sp_hist, hist_initModel, vid_info.ht, vid_info.wd, ff, param_track, sp{ff - 1});    
    [subFeats, subPixels, subPixelsNum, ...
        subPixels_mask, subPixelsNum_mask, ...
        subColors, subCenters, subColors_pixel, ...
        subCenters_pixel, colors, imLarges, fgIdxL] = gene_preProcessingPixel_hist_cnn(video, imBoxes, cnnFeats, ...
        meanFlows, nFrames, vid_info.ht, vid_info.wd, param_track, spdata, cnn_model);
    [unaryPixelPotentials, pairPixelPotentials] = gene_pixel_potentials_hist_cnn(subFeats, subPixels, subPixelsNum,...
        subPixels_mask, subPixelsNum_mask, subColors,...
        subCenters, subColors_pixel, subCenters_pixel,...
        colors, imLarges, flows, cnn_model, hist_model,...
        fgIdxL, nFrames, vid_info.ht, vid_info.wd, param_track, enopt, spdata);
    unaryPotentials = unaryPixelPotentials;
    pairPotentials.source = pairPixelPotentials.source;
    pairPotentials.destination = pairPixelPotentials.destination;
    pairPotentials.value = pairPixelPotentials.value;
    [~,labels] = maxflow_mex_optimisedWrapper(pairPotentials, single(unaryPotentials));
    pixelLabels2 = labels;
    gt_est = draw_results(videoAll, gt_mask{ff}, ff, vid_info.ht, vid_info.wd, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, pixelLabels2, fgIdxL, imBoxes, imLarge, gt_est, param_track);
    imwrite(gt_est{ff - 1}, [res_cluster_path '/' sprintf('%04d_mask_inverse.png',ff - 1)]);
end