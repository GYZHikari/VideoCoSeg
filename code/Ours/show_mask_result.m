function mask = show_mask_result(label, sp)
mask = zeros(size(label));
for ii = 1:length(sp)
    mask(label == sp(ii)) = 1;
end