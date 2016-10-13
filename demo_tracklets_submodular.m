% The implementation for the work 
% Semantic Co-segmentation in Videos
% Yi-Hsuan Tsai* Guangyu Zhong* and Ming-Hsuan Yang 
% 
% Guangyu Zhong & Yi-Hsuan Tsai @ 2016
% Dalian University of Technology
% UC Merced

%% Step 2: select best tracklets & merge tracklets
clear
close all
addpath(genpath('code'))
caffe_path = fullfile('../caffe-cedn-dev', 'matlab', 'caffe');
addpath(caffe_path);
%% dirs
dataset = 'Youtube_Objects';
datasetPath = ['youtube_masks/'];
featsPath = ['data/', dataset, '/costfunc/Tracklet_feat/'];
% if ~exist(featsPath,'dir'), mkdir(featsPath); end;
scoresPath = ['data/', dataset, '/costfunc/Tracklet_score/'];
% if ~exist(scoresPath,'dir'), mkdir(scoresPath); end;
motionsPath = ['data/', dataset, '/costfunc/Tracklet_motion/'];
% if ~exist(motionsPath,'dir'), mkdir(motionsPath); end;
shapesPath = ['data/' dataset, '/costfunc/Tracklet_shape/'];
% if ~exist(shapesPath,'dir'), mkdir(shapesPath); end;
variancePath = ['data/' dataset, '/costfunc/Tracklet_variance/'];
% if ~exist(shapesPath,'dir'), mkdir(shapesPath); end;

trackletPath = [data_info.respath]
opt.gamma = 1;
opt.lambda_fcn = 20;
opt.lambda_motion = 20;

opt.show = 0;
opt.alpha = 1;

opt.tracklet = 'fcn-motion-shape';
opt.edge_type = 'cnn'; % feature type cnn or shape
opt.afftype = 'cnn'; % append multi none
opt.dis_type = 'dot';
opt.type = 'naive';
opt.seedNum = 'adaptive'; % one is for only one seed adaptive is for adaptively selection
opt.normal_feat = 'none'; % norm or none


savedataPath = ['data/' dataset, '/submodular/submodular', '_',  opt.edge_type, '_', opt.type, '/'];

switch lower(opt.seedNum)
    case 'one'
        savedataPath = [savedataPath, '/one_seed/'];
        if ~exist(savedataPath,'dir'), mkdir(savedataPath); end;
    case 'adaptive'
        savedataPath = [savedataPath, '/adaptive_seed/'];
        if ~exist(savedataPath,'dir'), mkdir(savedataPath); end;
    otherwise
        error('No such response options!!!');
end

savetrackPath = ['data/' dataset, '/submodular/submodular', '_',  opt.edge_type, '_', opt.type, '_tracklets' '/'];

switch lower(opt.seedNum)
    case 'one'
        savetrackPath = [savetrackPath, '/one_seed/'];
        if ~exist(savetrackPath,'dir'), mkdir(savetrackPath); end;
    case 'adaptive'
        savetrackPath = [savetrackPath, '/adaptive_seed/'];
        if ~exist(savetrackPath,'dir'), mkdir(savetrackPath); end;
    otherwise
        error('No such response options!!!');
end


allclusterPath = [ 'data/Youtube_Objects/cluster/'];
% if ~exist(allclusterPath,'dir'), mkdir(allclusterPath); end;

%% dataset and video information
objNames = {'aeroplane','bird','boat','car','cat','cow','dog','horse','motorbike','train'};

for vv =1:length(objNames)
    videoId = vv;
    objName = objNames{videoId};
    vidNames = dir([datasetPath  objName '/data/']);
    vidNames(1:2) = [];
    all_inds(vv) = gene_set_ind(objName);
    
    %% tracklet feats feature
    featssavePath = [featsPath, '/', objName, '/'];
    tracklets = dir([featssavePath, '*.mat']);
    % check current semantic
    tracklets = gene_same_semantic(tracklets, opt.tracklet);
    tracklets_ratio = reduce_noise_tracklets([trackletPath, '/'], tracklets)';
    tracklet_rerank = {};
    for kktmp = 1:length(vidNames)
        tracklet_rerank = [tracklet_rerank; {[objName, '_', vidNames(kktmp).name]}];
    end
    [reduce_id, reduce_tracklet]= reduce_tracklets(tracklet_rerank, tracklets, tracklets_ratio, 0.5);
    tracklets(reduce_id) = [];
    
    if strcmp(opt.edge_type, 'cnn') || strcmp(opt.edge_type, 'intra-inter')
        feature = zeros(length(tracklets), 448);
        for tt = 1:length(tracklets)
            load([featssavePath, tracklets(tt).name]);
            locs = find(char(tracklets(tt).name) == '_');
            switch lower(tracklets(tt).name(locs(end) + 1:end-4))
                case 'forefeats'
                    feat = forefeats;
                case 'backfeats'
                    feat  = backfeats;
                case 'fcnfeats'
                    feat = fcnfeats;
                otherwise
                    error('No Such feats!');
            end
            sumfeat = feat{1};
            for tmpind = 2:numel(feat)
                sumfeat = sumfeat + feat{tmpind};
            end
            sumfeat = sumfeat./numel(feat);
            feature(tt, :) = sumfeat;
        end
    else
        feature = [];
    end
    %% shape similarity: tracklet shape feature
    if strcmp(opt.edge_type, 'shape') || strcmp(opt.edge_type, 'intra-inter')
        shapesavePath = [shapesPath, '/', objName, '/'];
        trackshapes = dir([shapesavePath, '*.mat']);
%         trackshapes = gene_names(trackshapesall);
        % check current semantic
        trackshapes = gene_same_semantic(trackshapes, opt.tracklet);
        trackshapes(reduce_id) = [];
        shapes = zeros(length(trackshapes), 360);
        for tt = 1:length(trackshapes)
            load([shapesavePath, trackshapes(tt).name]);
            imgShapes(isnan(imgShapes)) = 0;
            shapes(tt, :) = mean(imgShapes, 2);
        end
    else
        shapes = [];
    end
    
    %% score fcn
    scoresavePath = [scoresPath, '/', objName, '/'];
    trackscores = dir([scoresavePath, '*.mat']);
    trackscores = gene_same_semantic(trackscores, opt.tracklet);
    trackscores(reduce_id) = [];
    if length(trackscores)~=length(tracklets)
        error('tracklets and scores length not match!!!');
    end
    %     trackscorenames = gene_names(trackscores);
    all_response = zeros(length(trackscores), 1);
    for tt = 1:length(trackscores)
        load([scoresavePath, trackscores(tt).name]);
        all_response(tt) = mean(response);
    end
    all_response = (all_response - min(all_response))/(max(all_response) - min(all_response));
    
    %% score motion
    motionsavePath = [motionsPath, '/', objName, '/'];
    trackmotions = dir([motionsavePath, '*.mat']);
    trackmotions = gene_same_semantic(trackmotions, opt.tracklet);
    trackmotions(reduce_id) = [];
    %     trackmotionnames = gene_names(trackmotions);
    all_motion = zeros(length(trackmotions), 1);
    for tt = 1:length(trackmotions)
        load([motionsavePath, trackmotions(tt).name]);
        all_motion(tt) = mean(aveFlows);
    end
    all_motion = (all_motion - min(all_motion))/(max(all_motion) - min(all_motion));
    
     %% shape variance
        variancesavePath = [variancePath, '/', objName, '/'];
        trackvariance = dir([variancesavePath, '*.mat']);
        trackvariance = gene_same_semantic(trackvariance);
        trackvariance(reduce_id) = [];

        all_shape_variance = zeros(length(trackscores), 1);
        for tt = 1:length(trackvariance)
            load([variancesavePath, trackvariance(tt).name]);
            all_shape_variance(tt, :) = std(tracksize)/mean(tracksize);
        end
        all_shape_variance = (all_shape_variance - min(all_shape_variance))/(max(all_shape_variance) - min(all_shape_variance));

    %% graph building affmat: feature similarity
    indNum = length(tracklets);
    weights = gene_sub_weight(indNum, feature, shapes, opt);
    % graph inds inter
    tmpaffmat = zeros(indNum, indNum);
    inds1 = [1:indNum]';
    edges1 = edges_between(inds1);
    row1 = edges1(:,1); col1 = edges1(:,2);
    ind1{1} = sub2ind([indNum, indNum], col1, row1);
    ind1{2} = sub2ind([indNum, indNum], row1, col1);
   % graph inds intra
   ind2 = cell(2, 1);
   for gg = 1:length(vidNames)
       switch lower(opt.tracklet)
           case 'without-fcn'
               canditracklets = dir([featssavePath, [objName, '_' ,vidNames(gg).name, '_', objName, '*.mat']]);
               canditracklets = pickupfcn(canditracklets);
           case 'with-fcn'
               canditracklets = dir([featssavePath, [objName, '_' ,vidNames(gg).name, '_', objName, '*.mat']]);
       end
       if length(canditracklets) == 0
           continue;
       end
       candinames = gene_names(canditracklets)';
       trackletsname = gene_names(tracklets)';
       if length(reduce_tracklet)~=0
       loc_reduce = ismember(candinames, reduce_tracklet);
       index_reducd = find(loc_reduce == 1);
       candinames(index_reducd) = [];
       end
       
       loc = ismember(trackletsname, candinames);
       index = find(loc == 1);
       candi_inds = index;
       if length(candi_inds) > 1
       edges2 = edges_between(candi_inds);
       row2 = edges2(:,1); col2 = edges2(:,2);
       ind2{1} = [ind2{1}; sub2ind([indNum, indNum], col2, row2)];
       ind2{2} = [ind2{2}; sub2ind([indNum, indNum], row2, col2)];
       end
   end
    affmat = gene_sub_graph(weights, ind1, ind2, indNum, opt.afftype);
   
    cur_pos_inds = cell(length(vidNames), 1);
    obj_val = cell(length(vidNames), 1);
    %% candidate seeds response
    for oo = 1:length(vidNames)
        switch lower(opt.tracklet)
            case 'without-fcn'
                canditracklets = dir([featssavePath, [objName, '_' ,vidNames(oo).name, '_', objName, '*.mat']]);
                canditracklets = pickupfcn(canditracklets);
            case 'with-fcn'
                canditracklets = dir([featssavePath, [objName, '_' ,vidNames(oo).name, '_', objName, '*.mat']]);
        end
        if length(canditracklets) == 0
            cur_pos_inds{oo} = 'NA';
            obj_val{oo} = -1000000;
            continue;
        end
        candinames = gene_names(canditracklets)';
        trackletsname = gene_names(tracklets)';
        loc = ismember(trackletsname, candinames);
        index = find(loc == 1);
        candi_inds = index;
        [cur_pos_inds{oo}, obj_val{oo}] = submodularFunc(affmat, candi_inds, all_response, all_motion, all_shape_variance, opt);
        
    end
    %% convert number to file name
    
    for ii = 1:length(cur_pos_inds)
        if ~strcmp(cur_pos_inds{ii}, 'NA')
            for kkk = 1:length(cur_pos_inds{ii})
                select_tracklet_names{ii, kkk} = tracklets(cur_pos_inds{ii}(kkk)).name;
            end
        else
            select_tracklet_names{ii, 1} = 'NA';
        end
    end
    
    readnames = cell(length(cur_pos_inds), 1);
    tracklets = cell(length(cur_pos_inds), 1);
    for ii = 1:length(cur_pos_inds)
        if strcmp(cur_pos_inds{ii,1}, 'NA')
            kkknum = 1;
        else
            kkknum = numel(cur_pos_inds{ii});
        end
        for kkk = 1:kkknum
            currname = select_tracklet_names{ii,kkk};
            if length(currname) == 0
                continue;
            end
            if strcmp(currname, 'NA')
                readnames{ii} = 'NA';
                continue;
            end
            locs = find(char(currname) == '_');
            matpath = [trackletPath, '/', objName, '/', currname(locs(1) + 1 : locs(2) - 1), '/', ...
                currname(locs(2) + 1:locs(3) - 1), '/', currname(locs(3) + 1: locs(6) - 1), '/'];
            results = dir([matpath, 'ratio*.mat']);
            if length(results) >5
                readnames{ii} = 'NA';
            end
            switch lower(currname(locs(end) + 1 : end - 4))
                case 'backfeats'
                readnames{ii, kkk} = results(1).name;
                tracklets{ii, kkk} = currname;
                case 'forefeats'
                readnames{ii, kkk} = results(2).name;
                tracklets{ii, kkk} = currname;
                case 'fcnfeats'
                readnames{ii, kkk} = results(1).name;
                tracklets{ii, kkk} = currname;   
                otherwise
                    error('No such file!');
            end
        end
    end
    disp(readnames)
    sub1results = readnames;
    save([savedataPath, '/', objName, '_sub1results.mat'], 'sub1results');
    save([savetrackPath, '/', objName, '_tracklets.mat'], 'tracklets');
end