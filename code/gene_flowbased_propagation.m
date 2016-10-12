function [meanFlows, flowMask] = gene_flowbased_propagation(imBoxes, flows)

% propagate the flow to the next frame
% segmentation for the current frame
% figure;imshow(uint8(cat(3, imBoxes{1}, imBoxes{1}, imBoxes{1})).*im, []);
ind = find(imBoxes{1}(:)==1);

% optical flow
xFlow = flows{1}(:,:,2); yFlow = flows{1}(:,:,1);
% SIFT flow
%     xFlow = SIFTflows(:,:,2); yFlow = SIFTflows(:,:,1);

xFlow = double(xFlow(:)); yFlow = double(yFlow(:));

% superpixels inside the mask
[ht, wd] = size(imBoxes{1});
pixelNum = ht*wd;
pixelMap = reshape((1:pixelNum),[ht,wd]);
segments = double(pixelMap);
   
mask = segments.*imBoxes{1};
idxSP = unique(mask(:));
idxSP = idxSP(2:end);

% compute the average flow of each superpixel
colNew = []; rowNew = [];
meanFlows = [];
for jj = 1:length(idxSP);
    %     tmp = find(segments(:)==idxSP(jj));
    indSP = idxSP(jj);
    meanFlow = zeros(2,1);
    meanFlow(1) = yFlow(indSP); meanFlow(2) = xFlow(indSP);
    
    [row,col] = ind2sub([ht,wd],indSP);
    colNew = [colNew;round(col+meanFlow(2))]; rowNew = [rowNew;round(row+meanFlow(1))];
    meanFlows = [meanFlows meanFlow];
end

% remove flow ouside of image
tmp = (colNew>=1 & colNew<=wd) & (rowNew>=1 & rowNew<=ht);
colNew = colNew(tmp); rowNew = rowNew(tmp);

% current segmentation based on flow
mask = zeros(ht,wd); mask = mask(:);
ind = sub2ind([ht,wd],rowNew,colNew);
mask(ind) = 1; mask = reshape(mask,[ht,wd]);
flowMask = mask;
