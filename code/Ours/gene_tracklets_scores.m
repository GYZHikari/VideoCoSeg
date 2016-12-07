function scores = gene_tracklets_scores(names_out, list, trackletimgpath, imgPath, fcnPath, semantic_id, ht, wd)
scores = zeros(length(list), 1);
for trackinds = 1:length(names_out)
    if ~exist([trackletimgpath, names_out{trackinds}])
        namew = ['0', names_out{trackinds}];
    else
        namew = names_out{trackinds};
    end
    foreimg = imread([trackletimgpath, namew]);
    currimg = imread([imgPath, list(trackinds).name]);
    fcnmatname = [fcnPath, '0', list(trackinds).name(6:9), '_fcn.mat'];
    if size(currimg, 1)~=ht || size(currimg, 2)~=wd
        currimgtmp(:,:,1) = imresize(currimg(:,:,1), [ht, wd]);
        currimgtmp(:,:,2) = imresize(currimg(:,:,2), [ht, wd]);
        currimgtmp(:,:,3) = imresize(currimg(:,:,3), [ht, wd]);
        currimg = currimgtmp;
    end
    if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
        foreimg = imresize(foreimg, [ht, wd]);
    end
    load(fcnmatname);
    fcnmap = reshape(fcn(semantic_id, :, :), [size(fcn, 2), size(fcn, 3)]);
    if size(fcnmap, 1)~=ht || size(fcnmap, 2)~=wd
        fcnmap = imresize(fcnmap, [ht, wd]);
    end
    if sum(sum(im2double(foreimg))) == 0
        scores(trackinds, 1) = 0;
    else
        scores(trackinds, 1) = sum(sum(fcnmap.*im2double(foreimg)))/sum(sum(im2double(foreimg)));
    end
end