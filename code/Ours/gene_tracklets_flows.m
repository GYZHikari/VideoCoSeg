function scores = gene_tracklets_flows(names_out, list, trackletimgpath, imgPath, flowsAll, ht, wd)
scores = zeros(length(list), 1);
se = strel('disk',10);
for trackinds = 1:length(names_out) - 1
     if ~exist([trackletimgpath, names_out{trackinds}])
        tmpgiven = ['rame', names_out{trackinds}(1:4), '_seg_fcn.png'];
    else
        tmpgiven =  names_out{trackinds};
     end
      if ~exist(tmpgiven) && strcmp(names_out{trackinds}(end - 6:end-4), 'fcn')
        tmpgiven = ['0', names_out{trackinds}];
      end
    foreimg = (imread([trackletimgpath,tmpgiven]));
%     foreimg = imread([trackletimgpath, names_out{trackinds}]);
    currimg = imread([imgPath, list(trackinds).name]);
    if size(foreimg, 3) == 3
        foreimg = im2double(foreimg);
        foreimg = foreimg(:,:,1);
    end
    if size(currimg, 1)~=ht || size(currimg, 2)~=wd
        currimgtmp(:,:,1) = imresize(currimg(:,:,1), [ht, wd]);
        currimgtmp(:,:,2) = imresize(currimg(:,:,2), [ht, wd]);
        currimgtmp(:,:,3) = imresize(currimg(:,:,3), [ht, wd]);
        currimg = currimgtmp;
    end
    if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
        foreimg = imresize(foreimg, [ht, wd]);
    end
%     [~, ~, imAround] = gene_boundary_around(foreimg, largeparam, smallparam);
    mask_dilate=imdilate(foreimg,se);
    mask_erode=imerode(foreimg,se);
    bd_around = mask_dilate - mask_erode;
    bd_around = im2double(bd_around);
    flowcur = flowsAll{trackinds, 1};
    xFlow = double(flowcur(:,:,2)); 
    xFlow = imresize(xFlow, [ht, wd]);
    yFlow = double(flowcur(:,:,1));
    yFlow = imresize(yFlow, [ht, wd]);
    xFlow = double(reshape(xFlow, ht, wd)); yFlow = double(reshape(yFlow, ht, wd)); %xflow: col yflow: row
    [vx_1 vx_2]=gradient(xFlow);
    [vy_1 vy_2]=gradient(yFlow);
    vx_1=vx_1.*bd_around;
    vx_2=vx_2.*bd_around;
    vy_1=vy_1.*bd_around;
    vy_2=vy_2.*bd_around;
    Seg_bdry_flow_grad=(vx_1.^2+vx_2.^2+vy_1.^2+vy_2.^2).^.5;
    flowAffinity=sum(Seg_bdry_flow_grad(:))/(sum(bd_around(:)) + eps); 
    scores(trackinds, 1) = flowAffinity;
end
scores(trackinds + 1, 1) = scores(trackinds, 1);
