function spmask = adjust_pixel2superpixel(mask, label, spsize, ratio)

if size(mask, 1)>1&&size(mask, 2)>1
    mask = reshape(mask, numel(mask), 1);
end
label = reshape(label, numel(label), 1);
maskind = label(mask);
mask_sizes = zeros(max(label(:)), 1);
for ii = 1:max(label(:))
    mask_sizes(ii) = numel(find(maskind == ii));
end
rate = mask_sizes./spsize;
spmask = find(rate > ratio);