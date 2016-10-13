function tracklets_shot = gene_merge_tracklets_options(resultPath, tracklets)

trackletsNum = length(tracklets);
for kk = 1:trackletsNum
    currentname = tracklets{kk};
    locs1 = find(char(currentname) == '_');
    clustername = currentname(locs1(5) + 1: locs1(6)-1);
    objName = currentname(1:locs1(1) - 1);
    shotsname = currentname(locs1(1) + 1 : locs1(2) - 1);
    semantic_name = currentname(locs1(2) + 1 : locs1(3) - 1);
    
    imgPath = ['../data/' objName '/data/' shotsname '/shots/001/'];
        list = dir([imgPath,'*.jpg']);
    
    trackletimgpath = [resultPath sprintf('/%s/%s/%s',objName, shotsname, semantic_name, ['visual_cluster_', clustername])];
    foretrackimgs = dir([trackletimgpath, '*_mask.png']);
    backtrackimgs = dir([trackletimgpath, '*_mask_inverse.png']);
    [forenames_out, backnames_out] = gene_trackletimg_strings(foretrackimgs, backtrackimgs, list);
    if strcmp(currentname(locs1(6)+1: locs1(6) + 9), 'forefeats')
        tracklets_shot{kk}.mat = forenames_out;
        tracklets_shot{kk}.cluster = clustername;
        tracklets_shot{kk}.semantic = semantic_name;
    else
        if strcmp(currentname(locs1(6)+1: locs1(6) + 9), 'backfeats')
            tracklets_shot{kk}.mat = backnames_out;
            tracklets_shot{kk}.cluster = clustername;
            tracklets_shot{kk}.semantic = semantic_name;
        end
    end
end