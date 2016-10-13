function [flow flow_color]=get_optical_flow_dong(im1,im2,method)
    if nargin<2
        m_path=which('get_optical_flow_dong');
        m_dir=fileparts(m_path);
        im1=imread([m_dir '\v_shooting_20_07_1.bmp']);
        im2=imread([m_dir '\v_shooting_20_07_2.bmp']);
    end
    if nargin<3
        method=2;
    end
    figure;
    if method==1
        [opt_u opt_v]=optFlowHorn(im1,im2,1,1);
    elseif method==2
        im1=double(im1);
        im2=double(im2);
        [width height channel]=size(im1);
        flow = mex_LDOF(im1,im2);
    else
    end
    subplot(1,3,1);
    imshow(im1/max(max(max(im1))));
    subplot(1,3,2);
    imshow(im2/max(max(max(im2))));
    subplot(1,3,3);
    flow_color = flowToColor(flow);
    imshow(flow_color);