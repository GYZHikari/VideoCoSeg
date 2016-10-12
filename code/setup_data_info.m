function data_info = setup_data_info(data_info)


data_info.respath = ['../coseg_result/', data_info.dataset, '/'];
data_info.datapath = ['../data/', data_info.dataset, '/'];
data_info.featpath = [data_info.datapath, 'cnn', '/'];
data_info.flowpath = [data_info.datapath, 'flow', '/'];
data_info.clusterpath = [data_info.datapath, 'cluster', '/'];
data_info.fcnpath = [data_info.datapath, 'fcn', '/'];
if ~isdir(data_info.respath)
	mkdir(data_info.respath);
end

if ~isdir(data_info.featpath)
	mkdir(data_info.featpath);
end

if ~isdir(data_info.flowpath)
	mkdir(data_info.flowpath);
end

if ~isdir(data_info.clusterpath)
	mkdir(data_info.clusterpath);
end

if ~isdir(data_info.fcnpath)
	mkdir(data_info.fcnpath);
end