function [cnnModel, feats_fg, feats_bg] = gene_CNNSVM(cnnFeats, fgIdxS, bgIdx, opt)
% learn SVM
if nargin < 4
    opt.CNNpixel = 0;
end
feats_fg = [];
feats_bg = [];
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

trainLabel = [ones(size(feats_fg,2),1);zeros(size(feats_bg,2),1)];
trainData = [feats_fg';feats_bg'];
% w1 = size(feats_fg', 1);
% w2 = size(feats_bg', 1);
% cnnModel = train(trainLabel, sparse(double(trainData)), ['-s 0 -B 1 -q -w1 ', num2str(w2/w1)]);
cnnModel = train(trainLabel, sparse(double(trainData)), '-s 0 -B 1 -q');
