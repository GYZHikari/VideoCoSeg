function tracklets_feats = gene_tracklets_avepool_v1(names_out, list, trackletimgpath, imgPath, mean_pix, layers, scales, pyramid, ht, wd)
% trackletimgpath: mask path
% imgPath:

tracklets_feats = cell(length(list), 1);
for trackinds = 1:length(names_out)
    if ~exist([trackletimgpath, names_out{trackinds}])
        
        tmpgiven = ['rame', names_out{trackinds}(1:4), '_seg_fcn.png'];
    else
        tmpgiven =  names_out{trackinds};
    end
    
    if ~exist(tmpgiven) && strcmp(names_out{trackinds}(end - 6:end-4), 'fcn')
        tmpgiven = ['0', names_out{trackinds}];
    end
    foreimg = im2double(imread([trackletimgpath,tmpgiven]));
    foreimg = foreimg(:,:,1);
    if unique(foreimg) == 1
        foreimg = zeros(size(foreimg));
    end
    currimg = imread([imgPath, list(trackinds).name]);
    if size(currimg, 1)~=ht || size(currimg, 2)~=wd
        currimgtmp(:,:,1) = imresize(currimg(:,:,1), [ht, wd]);
        currimgtmp(:,:,2) = imresize(currimg(:,:,2), [ht, wd]);
        currimgtmp(:,:,3) = imresize(currimg(:,:,3), [ht, wd]);
        currimg = currimgtmp;
    end
    if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
        foreimg = imresize(foreimg, [ht, wd]);
    end
    [feats, pad] = gene_CNN(currimg, mean_pix, layers);
    feats_reshape= reshapeCNNFeature(feats,pad,wd,ht,layers,scales);
    % apply on thresholded regions
    idx = find(foreimg);
    feats = [];
    
    for jj = 1:length(feats_reshape)
        if ~pyramid{1}(1) == 1 && pyramid{1}(2) == 1
            feats_spm = spm_pooling(feats_reshape{jj}, idx, pyramid, wd, ht);
        else
            fea = feats_reshape{jj};
            fea_sub = fea(:,idx);
            fea_sub = sum(fea_sub,2)/length(idx);
            fea_sub = fea_sub ./ (norm(fea_sub)+eps);
            feats = [feats;fea_sub];
        end
    end
    tracklets_feats{trackinds} = feats;
end