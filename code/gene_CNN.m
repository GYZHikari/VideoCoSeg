function [feats, pad] = gene_CNN(im0, mean_pix, layers)

im = single(im0(:,:,[3 2 1]));
[im_h, im_w, im_c] = size(im);
for c = 1:3, im(:,:,c) = im(:,:,c) - mean_pix(c); end

if im_w > im_h && (im_w >= 512 || im_h >= 512)
    left = 0; right = 0;
    top = floor((im_w-im_h)/2); bottom = im_w-im_h-top;
    pad = [top, bottom, left, right];
    im = imPad(im, pad, 0);
    im = imresize(im, [512 512]);
elseif im_h > im_w && (im_w >= 512 || im_h >= 512)
    left = floor((im_h-im_w)/2); right = im_h-im_w-left;
    % setups = 0; bottom = 0;
    pad = [top, bottom, left, right];
    im = imPad(im, pad, 0);
    im = imresize(im, [512 512]);
elseif im_w <= 512 && im_h <= 512
    left = floor((512-im_w)/2); right = 512-im_w-left;
    top = floor((512-im_h)/2); bottom = 512-im_h-top;
    pad = [top, bottom, left, right];
    im = imPad(im, pad, 0);
end

[im_h,im_w,im_c] = size(im);
im = reshape(im, [im_h,im_w,im_c,1]);
im = permute(im,[2,1,3,4]);
output = caffe('forward', {im});
acts = caffe('get_all_data');

feats = cell(length(layers),1);
for j = 1:length(layers),
    act = acts(layers(j)).data;
    [n1,n2,n3] = size(act);
    act = reshape(permute(act,[3,2,1]),[n3,n2*n1]);
    feats{j} = act;
end



