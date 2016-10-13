function [histModel, fgColorsL, fgColorsS, bgColorsS, fgIdxS, fgIdxL, bgIdx] = gene_histSVM(sp_hist, trimap, ht, wd, sp, opt, im)
% learn SVM
pixelNum = ht*wd;
pixelMap = reshape((1:pixelNum),[ht,wd]);

% get pixel
segments = pixelMap;
allIdx = unique(segments);

% determine region for fg GMM
tmp = 1-trimap;
fg = imdilate(tmp,strel('diamond',opt.rangeS));
fgS = 1-fg;
fgSegments = double(segments).*fgS;
fgIdx = unique(fgSegments);
fgIdxS = fgIdx(2:end);

% randon sample region for bg GMM
fgL = imdilate(trimap,strel('diamond',opt.rangeL));
fgSegments = double(segments).*fgL;
fgIdx = unique(fgSegments);
fgIdxL = fgIdx(2:end);

keepDoing = 1;
tmp = trimap;
while keepDoing
    imLarge = imdilate(tmp,strel('diamond',1));
    if sum(imLarge(:))>=sum(trimap(:))*opt.rangeSearch || sum(imLarge(:))>=(wd*ht *0.9)
        keepDoing = 0;
    end
    tmp = imLarge;
end
bg = imLarge;
bgL = 1-bg;
fgSegments = double(segments).*bgL;
bgIdx = unique(fgSegments);
bgIdxL = bgIdx(2:end);
allIdx([bgIdxL; fgIdxL]) = [];
bgIdx = allIdx;
maskbg = zeros(size(trimap));
maskbg(bgIdx) = 1;
% figure;imshow(uint8(cat(3, maskbg, maskbg, maskbg)).*im, []);
if opt.supermode
    fgIdxS = adjust_pixel2superpixel(fgIdxS, sp.label, sp.sizes, opt.ratio);
    fgIdxL = adjust_pixel2superpixel(fgIdxL, sp.label, sp.sizes, opt.ratio);
    bgIdx = adjust_pixel2superpixel(bgIdx, sp.label, sp.sizes, opt.ratio);
end

fgColorsL = double(sp_hist(fgIdxL, :));
fgColorsS = double(sp_hist(fgIdxS, :));
bgColorsS = double(sp_hist(bgIdx, :));
feats_fg = fgColorsS;
feats_bg = bgColorsS;

trainLabel = [ones(size(feats_fg,1),1);zeros(size(feats_bg,1),1)];
trainData = [feats_fg;feats_bg];
if size(feats_fg, 1)*2.4 < size(feats_bg, 1)
    tmp = 1-trimap;
    fg = imdilate(tmp,strel('diamond',2));
    fgS = 1-fg;
    fgSegments = double(segments).*fgS;
    fgIdx = unique(fgSegments);
    fgIdxSS = fgIdx(2:end);
    fgIdxSS = adjust_pixel2superpixel(fgIdxSS, sp.label, sp.sizes, opt.ratio);
    fgColorsSS = double(sp_hist(fgIdxSS, :));
    trainData = [fgColorsSS; feats_fg;feats_bg];
    trainLabel = [ones(size(fgColorsSS,1),1); ones(size(feats_fg,1),1); zeros(size(feats_bg,1),1)];
else
    trainLabel = [ones(size(feats_fg,1),1);zeros(size(feats_bg,1),1)];
    trainData = [feats_fg;feats_bg];
end
histModel = train(trainLabel, sparse(double(trainData)), '-s 0 -B 1 -q');


