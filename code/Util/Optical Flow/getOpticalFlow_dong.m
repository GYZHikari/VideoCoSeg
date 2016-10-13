function [vx vy]=getOpticalFlow_dong(im1,im2,flow_type)
    if nargin<3
        flow_type='Ce Liu';
    end
    
    if (sum(size(im1)==size(im2))==length(size(im1)))...
            &&(sum(size(im1)==size(im2))==length(size(im2)))
        if strcmp(flow_type,'Ce Liu')
            [vx vy]=getOpticalFlow_CeLiu(im1,im2);
        elseif strcmp(flow_type,'Brox')
            [vx vy]=getOpticalFlow_Brox(im1,im2);
        else
            error('getOpticalFlow_dong: Unknow flow type!');
        end
    else
        error('getOpticalFlow_dong: Input images are not same size!');
    end