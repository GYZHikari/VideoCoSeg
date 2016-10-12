function vid_info = generate_clusters(vid_info, param_track)

vid_info.clusters = dir(vid_info.clusterpath);
vid_info.clusters(1:2) = [];
ht = vid_info.ht;
wd = vid_info.wd;
if length(vid_info.clusters) == 0
    maskhist = [];
    tag = [];
    clear img_cluster_tmp
    for ii = 1:length(vid_info.list)
        img_cluster = im2double(imread([vid_info.inputpath, vid_info.list(ii).name]));
        mask_cluster = im2double(imread([vid_info.fcnpath, vid_info.singles(ii).name]));
        img_cluster_tmp(:,:,1) = imresize(img_cluster(:,:,1), [ht, wd]);
        img_cluster_tmp(:,:,2) = imresize(img_cluster(:,:,2), [ht, wd]);
        img_cluster_tmp(:,:,3) = imresize(img_cluster(:,:,3), [ht, wd]);
        img_cluster = img_cluster_tmp;
        mask_cluster = imresize(mask_cluster, [ht, wd]);
        obj = zeros(size(img_cluster));
        mask_cluster(mask_cluster >=0.5) = 1;
        mask_cluster(mask_cluster <0.5) = 0;
        imLarges_cluster = mask_cluster;
        [L, num] = bwlabel(imLarges_cluster);
        if num>0
            for tmpbw = 1:num
                bwnum(tmpbw) = numel(find(L == tmpbw));
            end
            imLarges_cluster = bwareaopen(imLarges_cluster, round(max(bwnum)*param_track.bw1));
            [L, num] = bwlabel(imLarges_cluster);
        end
        L = L + 1;
        num = num + 1;
        [~, sp_hist_cluster] = t1_cal_hsi_hist(img_cluster, param_track.histnum, num, L);
        maskhist = [maskhist, sp_hist_cluster(:,2:end)];
        labelid = ones(num - 1, 1).*ii;
        subid = [2:num]';
        tag = [tag; [labelid, subid]];
    end
    [clust_cent,point2cluster,clust_mem_cell] = MeanShiftCluster(maskhist,param_track.bandwidth);

    cluster_num = zeros(length(clust_mem_cell), 1);
    for kk = 1:length(clust_mem_cell)
        cluster_num(kk) = numel(clust_mem_cell{kk});
    end

    if vid_info.framenum > 20
        ind_collect = find(cluster_num >= floor(vid_info.framenum*param_track.bw2));
    end
    if length(ind_collect) == 0
        ind_collect = find(cluster_num == max(cluster_num));
    end
    clear good_collect
    good_collect = [];
    clear kk
    for kk = 1:length(ind_collect)
        good_collect = [good_collect, cell2mat(clust_mem_cell(ind_collect(kk)))];
    end
    
    for ii = good_collect
        label = point2cluster(ii);
        label_path = [vid_info.clusterpath, 'visual_cluster_', num2str(label), '/'];
        if ~isdir(label_path)
            mkdir(label_path);
        end
        img_ind = tag(ii, 1);
        part_ind = tag(ii, 2);
        img_cluster = im2double(imread([vid_info.inputpath, vid_info.list(img_ind).name]));
        mask_cluster = im2double(imread([vid_info.fcnpath, vid_info.singles(img_ind).name]));
        img_cluster_tmp(:,:,1) = imresize(img_cluster(:,:,1), [ht, wd]);
        img_cluster_tmp(:,:,2) = imresize(img_cluster(:,:,2), [ht, wd]);
        img_cluster_tmp(:,:,3) = imresize(img_cluster(:,:,3), [ht, wd]);
        img_cluster = img_cluster_tmp;
        obj = zeros(size(img_cluster));
        mask_cluster = imresize(mask_cluster, [ht, wd]);
        mask_cluster(mask_cluster >=0.5) = 1;
        mask_cluster(mask_cluster <0.5) = 0;
        imLarges_cluster = mask_cluster;
        
        [L, num] = bwlabel(imLarges_cluster);
        if num>0
            for tmpbw = 1:num
                bwnum(tmpbw) = numel(find(L == tmpbw));
            end
            imLarges_cluster = bwareaopen(imLarges_cluster, round(max(bwnum)*param_track.bw1));
            [L, num] = bwlabel(imLarges_cluster);
        end
        L = L + 1;
        num = num + 1;
        ind = find(L == part_ind);
        temp_mask = zeros(size(img_cluster, 1), size(img_cluster, 2));
        temp_mask(ind) = 1;
        obj(:,:,1) = temp_mask.*img_cluster(:,:,1);
        obj(:,:,2) = temp_mask.*img_cluster(:,:,2);
        obj(:,:,3) = temp_mask.*img_cluster(:,:,3);
        
        write_path = [label_path, vid_info.list(img_ind).name(1:end-4), '.png'];
        write_path_mask = [label_path, vid_info.list(img_ind).name(1:end-4), '_mask.png'];
        imwrite(obj, write_path);
        imwrite(temp_mask, write_path_mask);
    end
end
clear vid_info.clusters;
vid_info.clusters = dir(vid_info.clusterpath);
vid_info.clusters(1:2) = [];