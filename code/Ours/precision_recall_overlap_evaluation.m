function [precision, recall, overlap, common, over_all] = precision_recall_overlap_evaluation(gt, result)
gt = im2double(gt);
result = im2double(result);
if size(result,3) == 3
    result = rgb2gray(result);
end
if size(gt,3) == 3
    gt = rgb2gray(gt);
end
result = imresize(result, size(gt));

gt(gt>0.5) = 1;
gt(gt<=0.5) = 0;
if sum(gt(:)) == 0
    precision = -1;
    recall = -1;
    overlap = -1;
    common = 0;
    over_all= 0;
    return;
end
result(result>0.5) = 1;
result(result<=0.5) = 0;
resM =  bitand(result,gt);
resO = bitor(result, gt);
common = sum(resM(:));
over_all = sum(resO(:));
precision = common/(sum(result(:)) + eps);
recall = common/(sum(gt(:)) + eps);
overlap = common/(over_all+eps);
if (sum(gt(:))== 0) && (sum(result(:)) == 0)
    precision = 1;
    recall = 1;
    overlap = 1;
end


