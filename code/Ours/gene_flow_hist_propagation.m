function [imBoxes, imLarge] = gene_flow_hist_propagation(imBoxes, meanFlows, sp_hist, histModel, ht, wd, ff, opt, sp, im)
% estimate the object location in the next frame
%% enlarge the segmentation
obj1 = imBoxes{1};
% plus average flow
if ff>1 && sum(obj1(:))==0
    obj2 = imBoxes{2};
else
    [row,col] = find(obj1);
    row = row + round(mean(meanFlows(1,:)));
    col = col + round(mean(meanFlows(2,:)));
    % remove flow ouside of image
    tmp = (col>=1 & col<=wd) & (row>=1 & row<=ht);
    col = col(tmp); row = row(tmp);
    ind = sub2ind([ht,wd],row,col);
    
    obj2 = zeros(size(obj1));
    obj2(ind) = 1;
end
% figure;imshow(uint8(cat(3, obj2, obj2, obj2)).*im,[]);
% rangeSearchEst = 3;
keepDoing = 1;
tmp = obj2;
while keepDoing
    imLarge = imdilate(tmp,strel('diamond',1));
    if sum(imLarge(:))>=sum(obj2(:))*opt.rangeSearchEst || sum(imLarge(:))==wd*ht
        keepDoing = 0;
    end
    tmp = imLarge;
end
% figure;imshow(uint8(cat(3, imLarge, imLarge, imLarge)).*im,[]);

%% pre-processing
% get pixel
pixelNum = ht*wd;
pixelMap = reshape((1:pixelNum),[ht,wd]);
segments = pixelMap;

% determine region of interest for segmentation
fgSegments = double(segments).*imLarge;
fgIdx = unique(fgSegments);
fgIdxL = fgIdx(2:end); %from 2?
if opt.supermode
fgIdxL = adjust_pixel2superpixel(fgIdxL, sp.label, sp.sizes, opt.ratio);
end
%% use the color model to filter out pixels
% Unary potentials for color
fgColorsL = double(sp_hist(fgIdxL,:));
[~, ~, fgPro] = predict(zeros(size(fgColorsL,1),1), sparse(double(fgColorsL)), histModel, '-b 1 -q');
fgPro = fgPro(:,1);
% maskPro = zeros(size(sp.label));
% for ii = 1:length(fgIdxL)
%     maskPro(sp.label == fgIdxL(ii)) = fgPro(ii);
% end
% figure;imshow(maskPro,[]);
%% use the location based on flow to filter out pixels
range = 1.5;
keepDoing = 1;
tmp = obj2;
while keepDoing
    imSmall = 1-tmp;
    imSmall = imdilate(imSmall,strel('diamond',1));
    imSmall = 1-imSmall;
    if sum(imSmall(:))*range<sum(obj2(:)) || sum(imSmall(:))==0
        keepDoing = 0;
        imSmall = tmp;
    end
    tmp = imSmall;
end

dist = double(bwdist(imSmall));
dist = dist.*imLarge; dist(imLarge==0) = max(dist(:));

pro = 1-dist/(max(dist(:)));
if opt.supermode
    fgLocPro = zeros(numel(fgIdxL), 1);
    for kk = 1:numel(fgIdxL)
        fgLocPro(kk) = mean(pro(sp.label == fgIdxL(kk)));
    end
else
    fgLocPro = pro(fgIdxL);
end



%% build the possible object mask
% fgIdxAll = fgIdxL(fgPro>=0.5 & fgLocPro>=0.5);
if isempty(fgPro)|| isempty(fgLocPro)
    imBoxes{2} = imLarge;
else
%     fgIdxAll1 = fgIdxL((fgPro+fgLocPro)/2>=0.45);
%     fgIdxAll2 = fgIdxL(fgPro >= 0.5);
%     fgIdxAll = intersect(fgIdxAll1, fgIdxAll2);
 fgIdxAll = fgIdxL((fgPro+fgLocPro)>=(0.4+0.4));
%     fgIdxAll = fgIdxL(fgPro>=0.5);
    mask = zeros(size(imLarge));
    if opt.supermode
        for ii = 1:length(fgIdxAll)
            mask((sp.label == fgIdxAll(ii))) = 1;
        end
    else
        mask(fgIdxAll) = 1;
    end
    mask = imfill(mask, 'hole');
    imBoxes{2} = logical(mask);
%     mask = imdilate(mask,strel('diamond',1));
%     [L, num] = bwlabel(imBoxes{2});
    imBoxes{2} = bwareaopen(imBoxes{2}, 5);
end



