function [flowsAll, flowsAll_Inv] = generate_flows(vid_info, param_track)
if ~exist([vid_info.flowpath, 'flowsAll.mat']) || ~exist([vid_info.flowpath, 'flowsAll_Inv.mat'])
	for ii = 1:length(vid_info.list)-1
	    imgname_front = [vid_info.inputpath, vid_info.list(ii).name];
	    imgname_back = [vid_info.inputpath, vid_info.list(ii+1).name];
	    ht = vid_info.ht;
	    wd = vid_info.wd;
	    fprintf('Computing optical flow: %d/%d\n',ii,totalFrame-1);
	    im1 = im2double(imread(imgname_front));
	    im2 = im2double(imread(imgname_back));
	    [uv1 uv2] = getOpticalFlow_CeLiu(im1,im2);
	    flowsAll(:,:,1, ii) = int16(uv2);
	    flowsAll(:,:,2, ii) = int16(uv1);
	    [in_uv1 in_uv2] = getOpticalFlow_CeLiu(im2,im1);
	    flowsAll_Inv(:,:,1, ii) = int16(in_uv1);
	    flowsAll_Inv(:,:,2, ii) = int16(in_uv2);
	end
	save([vid_info.flowpath, 'flowsAll.mat'], 'flowsAll');
	save([vid_info.flowpath, 'flowsAll_Inv.mat'], 'flowsAll_Inv');
else
	load([vid_info.flowpath, 'flowsAll.mat']);
	load([vid_info.flowpath, 'flowsAll_Inv.mat']);
end
