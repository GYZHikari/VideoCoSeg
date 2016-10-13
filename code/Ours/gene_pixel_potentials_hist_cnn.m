function [unaryPixelPotentials, pairPixelPotentials] = gene_pixel_potentials_hist_cnn(subFeats, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, subColors, subCenters, subColors_pixel, subCenters_pixel, sp_hist, imLarges, flows, cnnModel, histModel, fgIdxL, nFrames, ht, wd, opt, enopt, sp)
% compute unary potentials
pixelNum = ht*wd;
unaryPixelPotentials = [];
show = 1;
for ii = 1:nFrames
    % Unary potentials for CNN features
    testData = subFeats{ii};
    [~, ~, prob] = predict(zeros(size(testData,1),1), sparse(double(testData)), cnnModel, '-b 1 -q');
    fgCNNPro = prob(:,1);
    bgCNNPro = prob(:,2);
    
    fgCNNPro(fgCNNPro==0) = 10e-5; fgCNNPro(fgCNNPro==1) = 1-10e-5;
    bgCNNPro(bgCNNPro==0) = 10e-5; bgCNNPro(bgCNNPro==1) = 1-10e-5;
    
    % Unary potentials for color
    fgColorsL = double(sp_hist(fgIdxL{ii}, :));
    [~, ~, Pro] = predict(zeros(size(fgColorsL,1), 1), sparse(double(fgColorsL)), histModel, '-b 1 -q');
    fgPro = Pro(:, 1);
    bgPro = Pro(:, 2);
    
    % Unary potentials for location (distance transform)  add one here
    % responese cow layer normalize 0~1 ave superpixels ave 0~1 
    dist = double(bwdist(1-imLarges{ii}));
    pro = dist/(max(dist(:)));    
    pro(pro==0) = 10e-5; pro(pro==1) = 1-10e-5;
    
    
    if opt.supermode
        fgLocPro = zeros(length(fgIdxL{ii}), 1);
        for kk = 1:length(fgIdxL{ii})
            if ii == 1
                ind_tmp = find(sp{ii}.label == fgIdxL{ii}(kk));
            else
                ind_tmp = find(sp{ii}.label == (fgIdxL{ii}(kk) - max(sp{ii-1}.label(:))));
            end
            fgLocPro(kk, 1) = mean(pro(ind_tmp));
        end
        bgLocPro = 1-fgLocPro;
        idx_mask = subPixels{ii}(:);
        idx_mask(idx_mask==1) = [];
        
        if ~opt.CNNpixel
        fgCNNPro = fgCNNPro(idx_mask-1);
        bgCNNPro = bgCNNPro(idx_mask-1);
        end
        fgLocPro = fgLocPro(idx_mask-1);
        bgLocPro = bgLocPro(idx_mask-1);
        fgPro = fgPro(idx_mask-1);
        bgPro = bgPro(idx_mask-1);
    else
        fgLocPro = pro(fgIdxL{ii}-pixelNum*(ii-1));
        bgLocPro = 1-fgLocPro;
    end
    

    % Unary potentials
    tmp = [-log(fgCNNPro)*enopt.CNNPixelWeight-log(fgPro)*enopt.colorPixelWeight-log(fgLocPro)*enopt.locPixelWeight -log(bgCNNPro)*enopt.CNNPixelWeight-log(bgPro)*enopt.colorPixelWeight-log(bgLocPro)*enopt.locPixelWeight];
    unaryPixelPotentials = [unaryPixelPotentials;tmp];
end
if opt.show
im2show = zeros(ht, wd);
ind2show = find(subPixels{ii}(:)~=1);
im2show(ind2show) = fgCNNPro;
figure;imshow(im2show,[]);
im2show(ind2show) = fgPro;
figure;imshow(im2show,[]);
im2show(ind2show) = fgLocPro;
figure;imshow(im2show,[]);
im2show(ind2show) = fgResPro;
figure;imshow(im2show,[]);
end
% spatial pairwise potentials
if opt.supermode
    [sSource, sDestination] = getSpatialConnections(subPixels_mask, subPixelsNum_mask(end)+1);
else
    [sSource, sDestination] = getSpatialConnections(subPixels, subPixelsNum(end)+1);
end
sDestination(sSource==0) = [];
sSource(sSource==0) = [];
sSource = sSource-1; sDestination = sDestination-1;

if opt.supermode
subColors = subColors_pixel;
subCenters = subCenters_pixel;
end

sSqrColourDistance = sum((subColors(sSource+1,:) - subColors(sDestination+1,:)).^ 2,2);
sCentreDistance = sqrt(sum((subCenters(sSource+1,:) - subCenters(sDestination+1,:)).^ 2,2));

sBeta = 0.5/(mean( sSqrColourDistance ./ (sCentreDistance+10e-5) ) + 10e-5);
sPixelValue = exp(-sBeta*sSqrColourDistance)./sCentreDistance;

% temporal pairwise potentials
if opt.supermode
    [tSource, tDestination, tConnections ] = getTemporalConnections(flows, subPixels_mask, subPixelsNum_mask(end)+1);
else
    [tSource, tDestination, tConnections ] = getTemporalConnections(flows, subPixels, subPixelsNum(end)+1);
end

indS = find(tSource==0);
indD = find(tDestination==0);
ind = union(indS,indD);
tSource(ind) = []; tDestination(ind) = []; tConnections(ind) = [];
tSource = tSource-1; tDestination = tDestination-1;
tSqrColourDistance = sum((subColors(tSource+1,:) - subColors(tDestination+1,:)).^2,2);
tBeta = 0.5 / (mean( tSqrColourDistance .* tConnections ) + 10e-5);
tPixelValue = tConnections .* exp( -tBeta * tSqrColourDistance );

pairPixelPotentials.source = [sSource;tSource];
pairPixelPotentials.destination = [sDestination;tDestination];
pairPixelPotentials.value = [single(sPixelValue*enopt.spatialPixelWeight);single(tPixelValue*enopt.temporalPixelWeight)];
