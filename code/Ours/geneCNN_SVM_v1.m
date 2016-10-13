function cnnModel = geneCNN_SVM_v1(cnnFeats, gtEst, feats_fg_init, ff, ht, wd, opt, sp)
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
fgL = imdilate(trimap,strel('diamond',opt.rangeL));
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
bgL = 1-bg;
fgSegments = double(segments).*bgL;
bgIdx = unique(fgSegments);
bgIdxL = bgIdx(2:end);
allIdx([bgIdxL;fgIdxL]) = [];
bgIdx = allIdx;

feats_fg = [];
feats_bg = [];

if ~opt.CNNpixel
    fgIdxS = adjust_pixel2superpixel(fgIdxS, sp.label, sp.sizes, opt.ratio);
    bgIdx = adjust_pixel2superpixel(bgIdx, sp.label, sp.sizes, opt.ratio);
end

for j = 1:length(cnnFeats{1})
    % fg
    feats_region = cnnFeats{1}{j}(:,fgIdxS);
    if opt.CNNpixel
        feats_region = bsxfun(@times, feats_region, 1./(sqrt(sum(feats_region.^2,1))+eps));
    end
    feats_fg = [feats_fg;feats_region];
    
    % bg
    feats_region = cnnFeats{1}{j}(:,bgIdx);
    if opt.CNNpixel
        feats_region = bsxfun(@times, feats_region, 1./(sqrt(sum(feats_region.^2,1))+eps));
    end
    feats_bg = [feats_bg;feats_region];
end

trainLabel = [ones(size(feats_fg_init,2)+size(feats_fg,2),1);zeros(size(feats_bg,2),1)];
trainData = [feats_fg_init';feats_fg';feats_bg'];

w1 = length(find(trainLabel == 1));
w2 = length(find(trainLabel == 0));
cnnModel = train(trainLabel, sparse(double(trainData)), '-s 0 -B 1 -q');

