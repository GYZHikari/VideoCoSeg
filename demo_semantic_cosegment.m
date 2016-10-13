% The implementation for the work 
% Semantic Co-segmentation in Videos
% Yi-Hsuan Tsai* Guangyu Zhong* and Ming-Hsuan Yang 
% 
% Guangyu Zhong & Yi-Hsuan Tsai @ 2016
% Dalian University of Technology
% UC Merced

%% Step 0: generate forward & backward trackltes
clear;
close all;
addpath(genpath('code'));
%% data params
data_info.dataset = 'Youtube_Objects';
data_info.maskpath = 'youtube_masks/';
data_info.inputpath = 'youtube_input/';
data_info.catornames = {'aeroplane','bird','boat','car','cat','cow','dog','horse','motorbike','train'};
data_info = setup_data_info(data_info);

%% caffe param: fcn && vgg
caffe_info.pyname = '/home/guangyuzhong/caffe-future/python/demo_single_segment_resize.py';
caffe_path = ['../caffe-cedn-dev', '/', 'matlab',  '/', 'caffe', '/'];
addpath(caffe_path);
model_def_file = '../caffe-cedn-dev/examples/pascal_segmentation/fcn-vgg-feature-solver.prototxt';
use_gpu = true;
matcaffe_init(use_gpu, model_def_file, []);
weights0 = caffe('get_weights');
load(['../caffe-cedn-dev/examples/pascal_segmentation/fcn-8s-pascal-weights.mat']);
for i=1:15, weights0(i).weights = weights(i).weights; end
caffe('set_weights', weights0);
%% mode params
param_track.show = 0;
param_track.rewrite = 0;

%% track params
param_track.histnum = 10;
param_track.bandwidth = 0.1;
param_track.bw1 = 0.2;
param_track.bw2 = 0.1;
param_track.gap = 10;
param_track.tnum = 5;

param_track.level = 15;
param_track.rangeS = 1;
param_track.rangeL = 1;
param_track.rangeSearch = 3.5;
param_track.rangeSearchEst = 3;
param_track.ratio = 0.01;

param_track.prop_pixel = 1;
param_track.seeResult = 1;

param_track.supermode = 1;
param_track.CNNpixel = 0;
param_track.numSuperpixel = 1000;
param_track.ch_bins_num = 10;


enopt.CNNPixelWeight = 1;
enopt.colorPixelWeight = 1;
enopt.responsePixelWeight = 0.5;
enopt.locPixelWeight = 0.5;
enopt.spatialPixelWeight = 1.5;
enopt.temporalPixelWeight = 0.5;% initial is 0.2
enopt.unaryPixelWeight = 1;

cnn_opt.layers = [3,6,10];
cnn_opt.mean_pix = [103.939, 116.779, 123.68];
cnn_opt.scales = [1,2,4];

%% pipeline
for cator_ind = 1:length(data_info.catornames)
    vid_info.cator_name = data_info.catornames{cator_ind};
    vid_info.cator_path = [data_info.maskpath, '/', vid_info.cator_name, '/', 'data', '/'];
    vid_info.videos = dir(vid_info.cator_path);
    vid_info.videos(1:2) = [];
    for vid_ind = 1:length(vid_info.videos)
        vid_info = setup_vid_info(vid_info, vid_ind, data_info);
        %% generate fcn results for each frame in current videos
        vid_info = generate_fcns(vid_info, data_info, caffe_info, param_track);
        %% cluster fcn objects results
        vid_info = generate_clusters(vid_info, param_track);
        [flowsAll, flowsAll_Inv] = generate_flows(vid_info);
        videoAll = load_video_frames(vid_info);
        %% tracklet generation for each cluster results
        for clus_ind = 2:length(vid_info.clusters)
            visual_cluster_path = [vid_info.clusterpath, 'visual_cluster_', num2str(clus_ind), '/'];
            
            res_cluster_path = [data_info.respath, vid_info.semantic_name, '/', vid_info.clusters(clus_ind).name, '/'];
            cluster_names = dir([visual_cluster_path, '*_mask.png']);
            [trackind, totalmaxnum] = cal_tracklet_ind(cluster_names, vid_info.framenum);
            [gt_mask] = generate_initmasks(vid_info, visual_cluster_path, vid_info.fcnpath, vid_info.list, trackind);
            gt_est = cell(vid_info.framenum, 1);
            sp = cell(vid_info.framenum, 1);
            %% initialization for start frames
            sp = initial_trackind_info(videoAll, trackind, sp, param_track);
            %% start generating each tracklets: forward & backword
            for listnum = 1:totalmaxnum
                ff_initial = trackind(listnum);
                script_prepare_tracking;
                script_segment_foreward;
                if (listnum == totalmaxnum && trackind(end)~=vid_info.framenum) || numel(trackind) ==1
                    continue;
                end
                if (trackind(end) == vid_info.framenum) || (listnum ~= length(trackind))
                    backbegin = listnum + 1;
                    back_start = trackind(backbegin);
                    back_end = ff_initial+1;
                    script_segment_backward;
                end
            end
            ff_initial = trackind(1);
            if ff_initial==1
                continue;
            end
            back_start = ff_initial;
            back_end = 2;
            script_prepare_tracking;
            script_segment_backward;
        end
    end
end
