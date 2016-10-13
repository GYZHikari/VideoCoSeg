function sub_info = setup_res_info(data_info)
dataset = data_info.dataset;
resultCNNPath = [data_info.datapath, '/costfunc/Tracklet_cnn/' dataset, '/'];
if ~exist(resultCNNPath,'dir'), mkdir(resultCNNPath); end;

resultScorePath = [data_info.datapath, '/costfunc/Tracklet_score/' dataset, '/'];
if ~exist(resultScorePath,'dir'), mkdir(resultScorePath); end;

resultFlowPath = [data_info.datapath, '/costfunc/Tracklet_motion/' dataset, '/'];
if ~exist(resultFlowPath,'dir'), mkdir(resultFlowPath); end;

resultShapePath = [data_info.datapath, '/costfunc/Tracklet_shape/' dataset, '/'];
if ~exist(resultShapePath,'dir'), mkdir(resultShapePath); end;

resultVarianPath = [data_info.datapath, '/costfunc/Tracklet_variance/', dataset, '/'];
if ~exist(resultVarianPath,'dir'), mkdir(resultVarianPath); end;

sub_info.resultCNNPath = resultCNNPath;
sub_info.resultScorePath = resultScorePath;
sub_info.resultShapePath = resultShapePath;
sub_info.resultFlowPath = resultFlowPath;
sub_info.resultVarianPath = resultVarianPath;