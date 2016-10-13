function gtEst = draw_results_next(videoAll, gtimg, ff, ht, wd, subPixels, subPixelsNum, subPixels_mask, subPixelsNum_mask, pixelLabels2, fgIdxL, imBoxes, imLarge, gtEst, opt)
% figure
% ground truth
im = videoAll{ff+1};
trimap = gtimg;
if ~isempty(trimap)
    imGT = cat(3,trimap,trimap,trimap); imGT = im.*uint8(imGT);
end
pos_y = 3; pos_x = 3;

if opt.supermode
    mask = zeros(size(subPixels_mask{2}));
    mask(subPixels_mask{2}(:)>1) = pixelLabels2(subPixelsNum_mask(2)+1:subPixelsNum_mask(3));
else
    pixelNum = ht*wd;
    segments = subPixels{2}-1;
    idx = subPixelsNum(2)+1:subPixelsNum(3);
    mask = zeros(size(segments));
    mask(fgIdxL{2}-pixelNum) = pixelLabels2(idx);
end

mask = imfill(mask, 'hole');
gtEst{ff+1} = mask;

acc = 0;
if ~isempty(trimap)
acc = sum(logical(trimap(:)) & logical(mask(:))) / sum(logical(trimap(:)) | logical(mask(:)));
end
% figure;
if opt.seeResult == 1
    maskSeg = cat(3,mask,mask,mask);
    imSeg = im.*uint8(maskSeg);
    subplottight(pos_y,pos_x,6); imshow(imSeg); title([num2str(ff+1), '-th', 'Result']);
end

if opt.seeResult == 1
    subplottight(pos_y,pos_x,1); imshow(im); title([num2str(ff+1) '/' num2str(length(videoAll))]);
    
    if ~isempty(trimap)
        subplottight(pos_y,pos_x,2); imshow(imGT); title('FCN-Result');
    end
    
    imBox = cat(3,imBoxes{1},imBoxes{1},imBoxes{1});
    imBox = uint8(imBox).*videoAll{ff};
    subplottight(pos_y,pos_x,3); imshow(imBox); title( [num2str(ff), '-th', ' Result']);
    
    imBox = cat(3,imBoxes{2},imBoxes{2},imBoxes{2});
    imBox = uint8(imBox).*im;
    subplottight(pos_y,pos_x,5); imshow(imBox); title([num2str(ff+1), '-th', ' Object Location']);
    
    imBox = cat(3,imLarge,imLarge,imLarge);
    imBox = uint8(imBox).*im;
    subplottight(pos_y,pos_x,4); imshow(imBox); title([num2str(ff+1), '-th', ' Search Region' ]);  
    pause(0.01)
end


