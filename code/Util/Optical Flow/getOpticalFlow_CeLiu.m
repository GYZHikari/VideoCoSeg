function [vx vy]=getOpticalFlow_CeLiu(im1,im2)
    %% Global parameters
    %  Set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
    alpha = 0.012;
    ratio = 0.75;
    minWidth = 20;
    nOuterFPIterations = 7;
    nInnerFPIterations = 1;
    nSORIterations = 30;
    para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
    
    %% Run
    im1=im2double(im1);
    im2=im2double(im2);
    [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);