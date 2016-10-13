function [vx vy]=getOpticalFlow_Brox(im1,im2)
    
    im1 = double(im1);
    im2 = double(im2);
    flow = mex_LDOF(im1,im2);
    vx = flow(:,:,1);
    vy = flow(:,:,2);