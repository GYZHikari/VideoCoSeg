function histModel = gene_histSVM_v1(sp_hist, gtEst, feats_fg_init, feats_bg_init, ff, ht, wd, opt, sp)
% positive samples: update every frame, add initial samples
% negative samples: within a range near the estimated object mask
% get pixel
pixelNum = ht*wd;
pixelMap = reshape((1:pixelNum),[ht,wd]);
segments = pixelMap;
allIdx = unique(segments);

% determine region for fg SVM
trimap = double(gtEst{ff});
tmp = 1-trimap;
fg = imdilate(tmp,strel('diamond',opt.rangeS));
fgS = 1-fg;
fgSegments = double(segments).*fgS;
fgIdx = unique(fgSegments);
fgIdxS = fgIdx(2:end);

% randon sample region for bg SVM
fgL = imdilate(trimap,strel('diamond',opt.rangeS));
fgSegments = double(segments).*fgL;
fgIdx = unique(fgSegments);
fgIdxL = fgIdx(2:end);

% rangeSearch = 3;
keepDoing = 1;
tmp = trimap;
while keepDoing
    imLarge = imdilate(tmp,strel('diamond',1));
    if sum(imLarge(:))>=sum(trimap(:))*opt.rangeSearch || sum(imLarge(:))==wd*ht
        keepDoing = 0;
    end
    tmp = imLarge;
end
bg = imLarge;

% bg = imdilate(trimap,strel('diamond',10));
bgL = 1-bg;
fgSegments = double(segments).*bgL;
bgIdx = unique(fgSegments);
bgIdxL = bgIdx(2:end);
% allIdx([fgIdxL]) = [];
allIdx([bgIdxL;fgIdxL]) = [];
bgIdx = allIdx;
% learn SVM

fgIdxS = adjust_pixel2superpixel(fgIdxS, sp.label, sp.sizes, opt.ratio);
bgIdx = adjust_pixel2superpixel(bgIdx, sp.label, sp.sizes, opt.ratio);
feats_fg = sp_hist(fgIdxS, :);
feats_bg = sp_hist(bgIdx, :);

switch opt.CNNSVM_v1Mode
    case 'init_bgfg'
        trainLabel = [ones(size(feats_fg_init,1)+size(feats_fg,1),1);zeros(size(feats_bg,1) + size(feats_bg_init, 1),1)];
        trainData = [feats_fg_init;feats_fg;feats_bg; feats_bg_init];
    case 'init_fg'       
        trainLabel = [ones(size(feats_fg_init,1)+size(feats_fg,1),1);zeros(size(feats_bg,1),1)];
        trainData = [feats_fg_init;feats_fg;feats_bg];
end
% trainLabel = [ones(size(feats_fg_init,2)+size(feats_fg,2),1);zeros(size(feats_bg_init,2),1)];
% trainData = [feats_fg_init';feats_fg';feats_bg_init'];
w1 = length(find(trainLabel == 1));
w2 = length(find(trainLabel == 0));
% histModel = train(trainLabel, sparse(double(trainData)), ['-s 0 -B 1 -q -w1 ', num2str(w2/w1)]);
histModel = train(trainLabel, sparse(double(trainData)), '-s 0 -B 1 -q');
[~, acc, Pro] = predict(trainLabel, sparse(double(trainData)), histModel, '-b 1 -q');

