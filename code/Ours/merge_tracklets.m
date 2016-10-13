function [decision] = merge_tracklets(tracklets_path, tracklets, opt, savepath)
gap = opt.gap;
overthreshold = opt.overthreshold;
rate_threshold = Inf;
frameNum = length(tracklets{1}.mat);
if length(tracklets) < 2
    decision = cell(frameNum, 1);
    for ii = 1:frameNum
        decision{ii} = 1;
    end
    warning('only one tracklets!');
    fnums = [1:gap:frameNum];
    if fnums(end) ~= frameNum
        fnums(end + 1) = frameNum;
    end
    for fnum = 1:length(fnums) - 1
        %     fnum
        gbegin = fnums(fnum);
        if fnum ==  (length(fnums) - 1)
            gend = fnums(end);
        else
            gend = fnums(fnum + 1) - 1;
        end
        %% initial
        ii = 1;
        for gnum = gbegin:gend
            loadpath = [tracklets_path, '/', tracklets{1}.semantic, '/', 'visual_cluster_',tracklets{1}.cluster, '/'];
            mask = im2double(imread([loadpath, tracklets{1}.mat{gnum}]));
            name{ii} = [sprintf('%04d', gnum),'_final.png'];
            imwrite(mask, [savepath, name{ii}]);
        end
        %% merge others to the previous
        
    end
    return;
end
fnums = [1:gap:frameNum];
if fnums(end) ~= frameNum
    fnums(end + 1) = frameNum;
end
decision = cell(frameNum, 1);
for fnum = 1:length(fnums) - 1
    %     fnum
    gbegin = fnums(fnum);
    if fnum ==  (length(fnums) - 1)
        gend = fnums(end);
    else
        gend = fnums(fnum + 1) - 1;
    end
    %% initial
    ii = 1;
    for gnum = gbegin:gend
        loadpath = [tracklets_path, '/', tracklets{1}.semantic, '/', 'visual_cluster_',tracklets{1}.cluster, '/'];     
        mask = im2double(imread([loadpath, tracklets{1}.mat{gnum}]));
        locs1 = find(char(tracklets{1}.mat{gnum}) == '_');
        allmask(:, ii) = reshape(mask, numel(mask), 1);
        mask_pre{ii} = mask;
        name{ii} = [sprintf('%04d', gnum),'_final.png'];
        imwrite(mask, [savepath, name{ii}]);
        ii = ii + 1;
        decision{gnum} = 1;
        
        
    end

    avemask = mean(allmask, 2);
    avemask(avemask <0.5) = 0;
    avemask(avemask~=0) = 1;
    avemask = reshape(avemask, size(mask, 1), size(mask, 2));
    avemaskpre = avemask;
    clear allmask
    curclusternum = tracklets{1}.cluster;
    %% merge others to the previous
    for tlnum = 2:length(tracklets)
        ii = 1;
        if strcmp(tracklets{tlnum}.cluster, curclusternum)
            continue;
        end
        curclusternum = tracklets{tlnum}.cluster;
        for gnum = gbegin:gend
            loadpath = [tracklets_path, '/', tracklets{tlnum}.semantic, '/', 'visual_cluster_',tracklets{tlnum}.cluster, '/'];  
            mask = im2double(imread([loadpath, tracklets{tlnum}.mat{gnum}]));
            allmask(:, ii) = reshape(mask, numel(mask), 1);
            mask_cur{ii} = mask;
            ii = ii + 1;
            
        end
        avemaskcur = mean(allmask, 2);
        avemaskcur(avemaskcur <0.5) = 0;
        avemaskcur(avemaskcur~=0) = 1;
        avemaskcur = reshape(avemaskcur, size(mask, 1), size(mask, 2));
        clear allmask
%          scores_pre = region_to_shape(avemaskpre);
%          score_cur = region_to_shape(avemaskcur);
        [~, ~, overlap] = precision_recall_overlap_evaluation(avemaskpre, avemaskcur);
        rate = max(sum(avemaskpre(:)), sum(avemaskcur(:)))/min(sum(avemaskpre(:)), sum(avemaskcur(:)));
        if overlap < overthreshold && rate < rate_threshold
            avemaskpre = avemaskpre + avemaskcur;
            avemaskpre(avemaskpre~=0) = 1;
            for tmpfinal = 1:length(mask_pre)
                final_result{tmpfinal} = mask_pre{tmpfinal} + mask_cur{tmpfinal};
                final_result{tmpfinal}(final_result{tmpfinal}~=0) = 1;
                imwrite(final_result{tmpfinal}, [savepath, name{tmpfinal}]);
            end
            mask_pre = final_result;
        end
    end
end