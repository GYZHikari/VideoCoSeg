% The implementation for the work 
% Semantic Co-segmentation in Videos
% Yi-Hsuan Tsai* Guangyu Zhong* and Ming-Hsuan Yang 
% 
% Guangyu Zhong & Yi-Hsuan Tsai @ 2016
% UC Merced

%% Step 2: feature extraction for each tracklet
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

layers = [3,6,10];
mean_pix = [103.939, 116.779, 123.68];
scales = [1,2,4];


rewrite_feat = 0;
rewrite_score = 0;
rewrite_fcn = 0;
rewrite_flow = 0;
rewrite_shape = 0;
%% dirs
dataset = data_info.dataset;
datasetPath = data_info.maskpath;
sub_info = setup_res_info(data_info);
opt.shapetype = '360';

%% extract features and scores
for cator_ind = 1:length(data_info.catornames)
    vid_info.cator_name = data_info.catornames{cator_ind};
    objName = vid_info.cator_name;
    vid_info.cator_path = [data_info.maskpath, '/', vid_info.cator_name, '/', 'data', '/'];
    vid_info.videos = dir(vid_info.cator_path);
    vid_info.videos(1:2) = [];
    for vid_ind = 1:length(vid_info.videos)
        vid_info = setup_vid_info(vid_info, vid_ind, data_info);
        ht = vid_info.ht;
        wd = vid_info.wd;
        list = vid_info.list;
        for clus_ind = 1:length(vid_info.clusters)
            semantic_name = vid_info.semantic_name;
            disp(['generating: ', vid_info.semantic_name, ' ', vid_info.videos(vid_ind).name, ' ', vid_info.clusters(clus_ind).name]);
            res_cluster_path = [data_info.respath, vid_info.semantic_name, '/', vid_info.clusters(clus_ind).name, '/'];
            %% save pathes
            saveCNNPath = [sub_info.resultCNNPath, '/', objName, '/'];
            saveScrorePath = [sub_info.resultScorePath, '/', objName, '/'];
            saveFlowPath = [sub_info.resultFlowPath, '/', objName, '/'];
            saveShapePath = [sub_info.resultShapePath, '/', objName, '/'];
            saveVarianPath = [sub_info.resultVarianPath, '/', objName, '/'];

            if ~isdir(saveCNNPath), mkdir(saveCNNPath); end
            if ~isdir(saveScrorePath), mkdir(saveScrorePath); end
            if ~isdir(saveFlowPath), mkdir(saveFlowPath); end
            if ~isdir(saveShapePath), mkdir(saveShapePath); end
            foretrackimgs = dir([res_cluster_path, '*_mask.png']);
            backtrackimgs = dir([res_cluster_path, '*_mask_inverse.png']);
            %% save names
            rawforename = [saveCNNPath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_rawforefeat.mat'];
            rawbackname = [saveCNNPath, objName, '_',  vid_info.videos(vid_ind).name '_cluster_', num2str(clus_ind), '_rawbackfeat.mat'];
            scoreforename = [saveScrorePath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_forescore.mat'];
            scorebackname = [saveScrorePath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_backscore.mat'];
            flowforename =  [saveFlowPath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_foreflow.mat'];
            flowbackname =  [saveFlowPath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_backflow.mat'];
            shapeforename =  [saveShapePath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_foreshape.mat'];
            shapebackname =  [saveShapePath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_backshape.mat'];
            varianforename =  [saveVarianPath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_forevarian.mat'];
            varianbackname =  [saveVarianPath, objName, '_',  vid_info.videos(vid_ind).name, '_cluster_', num2str(clus_ind), '_backvarian.mat'];
            if exist(rawforename) && exist(rawbackname) &&...
                    exist(scoreforename) && exist(scorebackname) && ...
                    exist(flowforename)&& exist(flowbackname)&&...
                    exist(shapeforename)&& exist(shapebackname)&&...
                    ~rewrite_score && ~rewrite_feat && ~rewrite_flow && ~rewrite_shape
                continue;
            end
            [forenames_out, backnames_out] = gene_trackletimg_strings(foretrackimgs, backtrackimgs, list);
            pyramid = {[1,1]};
            
            if ~exist(rawforename) || ~exist(rawbackname) || rewrite_feat
                forefeats = gene_tracklets_avepool_v1(forenames_out, list, res_cluster_path, vid_info.inputpath, mean_pix, layers, scales, pyramid, ht, wd);
                backfeats = gene_tracklets_avepool_v1(backnames_out, list, res_cluster_path, vid_info.inputpath, mean_pix, layers, scales, pyramid, ht, wd);
                save(rawforename, 'forefeats');
                save(rawbackname, 'backfeats');
            end
            if ~exist(scoreforename) || ~exist(scorebackname)||rewrite_score
                semantic_id = gene_set_ind(semantic_name) + 1;
                foreScores = gene_tracklets_scores(forenames_out, list, res_cluster_path, vid_info.inputpath, vid_info.fcnpath, semantic_id, ht, wd);
                response = foreScores;
                save(scoreforename, 'response');
                backScores = gene_tracklets_scores(backnames_out, list, res_cluster_path, vid_info.inputpath, vid_info.fcnpath, semantic_id, ht, wd);
                response = backScores;
                save(scorebackname, 'response');
            end
            if ~exist(flowforename) || ~exist(flowbackname)||rewrite_flow
                [flowsAll, flowsAll_Inv] = generate_flows(vid_info);
                semantic_id = gene_set_ind(semantic_name) + 1;
                foreFlows = gene_tracklets_flows(forenames_out, list, res_cluster_path, vid_info.inputpath, flowsAll, ht, wd);
                aveFlows = foreFlows;
                save(flowforename, 'aveFlows');
                backFlows = gene_tracklets_flows(backnames_out, list, res_cluster_path, vid_info.inputpath, flowsAll_Inv, ht, wd);
                aveFlows = backFlows;
                save(flowbackname, 'aveFlows');
            end
            if ~exist(shapeforename) || ~exist(shapebackname)||rewrite_shape
                foreShapes = gene_tracklets_shapes(forenames_out, list, res_cluster_path, ht, wd, pyramid, opt);
                imgShapes = foreShapes;
                save(shapeforename, 'imgShapes');
                backFlows = gene_tracklets_shapes(backnames_out, list, res_cluster_path, ht, wd, pyramid, opt);
                imgShapes = backFlows;
                save(shapebackname, 'imgShapes');
            end
            if ~exist(varianforename) || ~exist(varianbackname)||rewrite_varian
                [variance, div_variance, tracksize] = gene_tracklets_shapevariance(forenames_out, list, vid_info.inputpath, ht, wd);
                save(varianforename, 'variance', 'div_variance', 'tracksize');
                [variance, div_variance, tracksize] = gene_tracklets_shapevariance(backnames_out, list, vid_info.inputpath, ht, wd);
                save(varianbackname, 'variance', 'div_variance', 'tracksize');
            end
        end
    end
end



