function [fgIdxCNN, mask] = gene_CNN_Hist_region(fgColorsL, histInitModel, label, fgIdxL)


[~, ~, fgPro] = predict(zeros(size(fgColorsL,1),1), sparse(double(fgColorsL)), histInitModel, '-b 1 -q');
fgIdxCNN = fgIdxL(fgPro(:,1)>=0.4);
mask = show_mask_result(label, fgIdxCNN);

