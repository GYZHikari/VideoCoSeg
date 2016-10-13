function [subFeats, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, subColors, subCenters, subColors_pixel, subCenters_pixel, colors, imLarges, fgIdxL] = gene_preProcessingPixel_hist_cnn(video, imBoxes, cnnFeats, meanFlows, nFrames, ht, wd, opt, sp, cnnModel)
%% compute mean RGB colors for the video
colors = [];
colors_pixel = [];
pixelNum = ht*wd;
pixelMap = reshape((1:pixelNum),[ht,wd]);
if opt.prop_pixel
    for ii = 1:nFrames
        if opt.supermode
            im = video{ii};
            color_pixel = zeros(pixelNum,3);
            for jj = 1:3
                tmp = im(:,:,jj);
                color_pixel(:,jj) = tmp(:);
            end
        end
        color = sp{ii}.sp_hist;
        
        colors = [colors;color];
        if opt.supermode
            colors_pixel = [colors_pixel; color_pixel];
        end
    end
else
    for ii = 1:nFrames
        color = sp{ii}.sp_hist;
        colors = [colors;color];
    end
    for ii = 1:nFrames
        for jj = 1:sp{ii}.maxNum
            color_pixel = repmat(sp{ii}.sp_hist(jj, :), sp{ii}.sizes(jj), 1);
            colors_pixel = [colors_pixel; color_pixel];
        end
    end
end

if opt.supermode
    centers = [];
    for ii = 1:nFrames
        centers = [centers; sp{ii}.centers];
    end
else
    centers = zeros(pixelNum,2);
    [xx,yy] = meshgrid(1:wd,1:ht);
    centers(:,1) = xx(:);
    centers(:,2) = yy(:);
    centers = repmat(centers, [nFrames 1]);
end
centers_pixel = zeros(pixelNum,2);
[xx,yy] = meshgrid(1:wd,1:ht);
centers_pixel(:,1) = xx(:);
centers_pixel(:,2) = yy(:);
centers_pixel = repmat(centers_pixel, [nFrames 1]);
%% pre-processing data across frames
% compute CNN features for pixels
[xx,yy] = meshgrid(1:512,1:512);
xx = xx(:); yy = yy(:);
fgL = cell(nFrames,1);
fgIdxL = cell(nFrames,1);
subFeats = cell(nFrames,1);
for nn = 1:nFrames
    % get pixel
    segments = pixelMap + pixelNum*(nn-1);
    
    % determine region of interest for segmentation
    trimap = double(imBoxes{nn});
    fgL{nn} = imdilate(trimap,strel('diamond',opt.rangeL));
    fgSegments = double(segments).*fgL{nn};
    fgIdx = unique(fgSegments);
    fgIdxL_pre{nn} = fgIdx(2:end);
    tmpind = fgIdxL_pre{nn}-pixelNum*(nn-1);
    if opt.supermode
        tmpind = adjust_pixel2superpixel(tmpind, sp{nn}.label, sp{nn}.sizes, opt.ratio);
        if nn == 1
            fgIdxL{nn} = tmpind + 0;
        else
            fgIdxL{nn} = tmpind + double(max(sp{nn-1}.label(:)));
        end
    else
        fgIdxL{nn} = fgIdxL_pre{nn};
    end
    % CNN features for region of interest
    feats_fg = [];
    tmpindCNN = tmpind;%adjust_sp2pixel(tmpind, sp{nn}.label);
    tmpindCNN = sort(tmpindCNN);
    for j = 1:length(cnnFeats{nn})
        act = cnnFeats{nn}{j};
        if opt.CNNpixel
            feats_region = act(:,tmpindCNN);
        else
            feats_region = act(:,tmpind);
        end
        if opt.CNNpixel
            feats_region = bsxfun(@times, feats_region, 1./(sqrt(sum(feats_region.^2,1))+eps));
        end
        feats_fg = [feats_fg;feats_region];
    end
    subFeats{nn} = feats_fg';
end
% compute RGB colors for the video
subColors = [];
subCenters = [];
for ii = 1:nFrames
    % colors for region of interest
    subColors = [subColors;colors(fgIdxL{ii},:)];
    subCenters = [subCenters;centers(fgIdxL{ii},:)];
end

%% build location priors by shape
obj1 = imBoxes{1};

% enlarge regions
imLarges = cell(nFrames,1);
range = 2;
keepDoing = 1;
tmp = obj1;
while keepDoing
    imLarges{1} = imdilate(tmp,strel('diamond',1));
    if sum(imLarges{1}(:))>=sum(obj1(:))*range || sum(imLarges{1}(:))>=wd*ht*0.9
        keepDoing = 0;
    end
    tmp = imLarges{1};
end

% shrink regions
imSmalls = cell(nFrames,1);
range = 1.5;
keepDoing = 1;
tmp = obj1;
while keepDoing
    imSmalls{1} = 1-tmp;
    imSmalls{1} = imdilate(imSmalls{1},strel('diamond',1));
    imSmalls{1} = 1-imSmalls{1};
    if sum(imSmalls{1}(:))*range<sum(obj1(:)) || sum(imSmalls{1}(:))==0
        keepDoing = 0;
        imSmalls{1} = tmp;
    end
    tmp = imSmalls{1};
end


% t1 = clock;
% plus average flow
if sum(obj1(:))==0
    imLarges{2} = imLarges{1};
    imSmalls{2} = imSmalls{1};
else
    [row,col] = find(imLarges{1});
    row = row + round(mean(meanFlows(1,:)));
    col = col + round(mean(meanFlows(2,:)));
    % remove flow ouside of image
    tmp = (col>=1 & col<=wd) & (row>=1 & row<=ht);
    col = col(tmp); row = row(tmp);
    ind = sub2ind([ht,wd],row,col);
    
    obj2 = zeros(size(obj1));
    obj2(ind) = 1;
    imLarges{2} = obj2;
    
    [row,col] = find(imSmalls{1});
    row = row + round(mean(meanFlows(1,:)));
    col = col + round(mean(meanFlows(2,:)));
    % remove flow ouside of image
    tmp = (col>=1 & col<=wd) & (row>=1 & row<=ht);
    col = col(tmp); row = row(tmp);
    ind = sub2ind([ht,wd],row,col);
    
    obj2 = zeros(size(obj1));
    obj2(ind) = 1;
    imSmalls{2} = obj2;
end

%% re-build sub graph
subPixels = cell(nFrames,1);
subPixelsNum = zeros(nFrames+1,1);
if opt.supermode
    segmentsTmp = zeros(size(segments));
    idx = fgIdxL{1};
    segments = sp{1}.label;
    subPixelsNum(2) = length(idx);
    
    for jj = 1:length(idx)
        segmentsTmp(segments==idx(jj)) = jj;
    end
    subPixels{1} = uint32(segmentsTmp+1);
    for ii = 2:nFrames
        idx = fgIdxL{ii};
        subPixelsNum(ii+1) = length(idx) + subPixelsNum(ii);
        segments = sp{ii}.label;
        segmentsTmp = zeros(size(segments));
        for jj = 1:length(idx)
            segmentsTmp(segments== (idx(jj) - max(max(sp{ii - 1}.label)))) = jj + subPixelsNum(ii-1);
        end
        subPixels{ii} = uint32(segmentsTmp+1);
    end
    subColors_pixel = [];
    subCenters_pixel = [];
    % superpixel to pixel
    subPixels_mask = cell(nFrames,1);
    subPixelsNum_mask =  zeros(nFrames+1,1);
    for ii = 1:nFrames
        mask = zeros(size(subPixels{ii}));
        mask(subPixels{ii}>1) = 1;
        idx = find(mask);
        
        % colors for region of interest
        subColors_pixel = [subColors_pixel; colors_pixel(idx + (ii-1) * pixelNum,:)];
        subCenters_pixel = [subCenters_pixel; centers_pixel(idx + (ii-1) * pixelNum,:)];
        segmentsTmp = zeros(size(subPixels{ii}));
        segmentsTmp(idx) = (1:length(idx)) + subPixelsNum(ii);
        subPixels_mask{ii} = uint32(segmentsTmp+1);
        subPixelsNum_mask(ii+1) = subPixelsNum_mask(ii) + length(idx);
    end
else
    for ii = 1:nFrames
        idx = fgIdxL{ii};
        subPixelsNum(ii+1) = length(idx) + subPixelsNum(ii);
        segmentsTmp = zeros(size(segments));
        segmentsTmp(idx-pixelNum*(ii-1)) = (1:length(idx))+subPixelsNum(ii);
        subPixels{ii} = uint32(segmentsTmp+1);
    end
    subPixels_mask = [];
    subPixelsNum_mask = [];
    subColors_pixel = [];
    subCenters_pixel = [];
end
