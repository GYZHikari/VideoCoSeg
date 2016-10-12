function vid_info = generate_fcns(vid_info, data_info, caffe_info, param_mode)

vid_info.fcnnames = dir([vid_info.fcnpath, '*_fcn.png']);
if length(vid_info.fcnnames) ~= vid_info.framenum    
    for ii = 1:length(vid_info.list)
        imgname = vid_info.list(ii).name;
        fcnname = [vid_info.fcnpath imgname]; %00001.jpg
        if ~exist(fcnname)||param_mode.rewrite
            system(['/usr/bin/python2.7', ' ', caffe_info.pyname, ' ', vid_info.inputpath, ' ', imgname,...
                ' ', fcnname, ' ', [fcnname(1:end-4), '.mat'], ' ', num2str(vid_info.ht), ' ', num2str(vid_info.wd)]);
        end
        catorimg = imread(fcnname);
        singleimg = zeros(size(catorimg));
        singleimg(catorimg == vid_info.id) = 1;
        if (size(singleimg, 1)~=vid_info.ht || size(singleimg, 2)~=vid_info.wd)
            singleimg = imresize(singleimg, [vid_info.ht, vid_info.wd]);
        end
        singleimg(singleimg >= 0.5) = 1;
        singleimg(singleimg < 0.5) = 0;
        singlename = [vid_info.fcnpath vid_info.cator_name '/' imgname(1:end-4) '_obj.png']; %00001.jpg
        imwrite(singleimg, singlename);
    end	
end
vid_info.singles = dir([vid_info.fcnpath, '*_obj.png']);

