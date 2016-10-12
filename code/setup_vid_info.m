function vid_info = setup_vid_info(vid_info, vid_ind, data_info)

vid_info.semantic_name = vid_info.cator_name;
vid_info.inputpath = [data_info.inputpath, vid_info.cator_name, 'data', '/', vid_info.videos(vid_ind).name, '/shots/001/'];
vid_info.list = dir([vid_info.inputpath, '*.jpg']);
vid_info.framenum = length(vid_info.list);
tmpimg = imread([vid_info.inputpath, vid_info.list(1).name]);
[ht, wd, ~] = size(tmpimg);
vid_info.ht = ht;a
vid_info.wd = wd;
vid_info.id = mapping_catorid(vid_info.cator_name);
% paths
vid_info.featpath = [data_info.featpath, vid_info.cator_name, '/', vid_info.videos(vid_ind).name, '/'];
vid_info.flowpath = [data_info.flowpath, vid_info.cator_name, '/', vid_info.videos(vid_ind).name, '/'];
vid_info.clusterpath = [data_info.clusterpath, vid_info.cator_name, '/', vid_info.videos(vid_ind).name, '/'];
vid_info.fcnpath = [data_info.fcnpath, vid_info.cator_name, '/', vid_info.videos(vid_ind).name, '/'];

if ~isdir(vid_info.featpath)
	mkdir(vid_info.featpath);
end

if ~isdir(vid_info.flowpath)
	mkdir(vid_info.flowpath);
end

if ~isdir(vid_info.clusterpath)
	mkdir(vid_info.clusterpath);
end

if ~isdir(vid_info.fcnpath)
	mkdir(vid_info.fcnpath);
end