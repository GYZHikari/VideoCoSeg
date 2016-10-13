function im_output=warpByOpticalFlow_dong(im_input,vx,vy,METHOD)
    % METHOD: 'linear', 'bicubic' and so on...
    if isfloat(im_input)~=1
        im_input=im2double(im_input);
    end
    if exist('vy')~=1
        vy=vx(:,:,2);
        vx=vx(:,:,1);
    end
    nChannels=size(im_input,3);
    for i=1:nChannels
        [im,isNan]=warpFL(im_input(:,:,i),vx,vy,METHOD);
        im_output(:,:,i)=im;
    end