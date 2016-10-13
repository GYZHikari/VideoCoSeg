function feats = spm_pooling(fea, idx, pyramid, im_w, im_h)

[y,x] = ind2sub([im_h,im_w], idx);

numLayers = length(pyramid);
numGroups = zeros(numLayers,1);
for ii = 1:numLayers
    numGroups(ii) = pyramid{ii}(1)*pyramid{ii}(2);
end
numBins = sum(numGroups);

feats = [];
for ii = 1:numLayers
    nBins = numGroups(ii);
    wUnit = im_w / pyramid{ii}(1);
    hUnit = im_h / pyramid{ii}(2);
    
    xBin = ceil(x / wUnit);
    yBin = ceil(y / hUnit);
    idxBin = (yBin-1)*pyramid{ii}(1) + xBin;
    
    for jj = 1:nBins
        sidxBin = find(idxBin == jj);
        if isempty(sidxBin)
           fea_sub = zeros(size(fea,1),1);
        else
            fea_sub = fea(:,idx(sidxBin));
            fea_sub = sum(fea_sub,2)/length(sidxBin);
            fea_sub = fea_sub ./ (norm(fea_sub)+eps);
        end
        feats = [feats;fea_sub];
    end
end