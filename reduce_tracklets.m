function [reduce_id, reduce_tracklet] = reduce_tracklets(tracklet_catorshot, tracklets, reduce_ratio, threshold)

tmp = zeros(length(tracklet_catorshot), 1);
tmp_ind = [];


for ii = 1:length(reduce_ratio)
    curname = tracklets(ii).name;
    locs = find(char(curname) == '_');
    curcatorname = curname(1:locs(2) - 1);
    ind = ismember(tracklet_catorshot, curcatorname);
    index = find(ind == 1);
    if (reduce_ratio(ii)) <= threshold
        tmp(index) = tmp(index) + 1;
    else
        tmp_ind = [tmp_ind; ii];
    end
end

empty_tracklets = find(tmp == 0);
error_tmp_ind = [];
for ii = 1:length(empty_tracklets)
    tmp_save = [];
    tmp_score = [];
    for jj = 1:length(tracklets)
        curname = tracklets(jj).name;
        locs = find(char(curname) == '_');
        if strcmp(curname(1:locs(2) - 1), tracklet_catorshot(empty_tracklets(ii)))
            tmp_save = [tmp_save, jj];
            tmp_score = [tmp_score, reduce_ratio(jj)];
        end
    end
    [value, minind] = min(tmp_score);
    error_tmp_ind = [error_tmp_ind, tmp_save(minind)];
end

[interval, interid] = intersect(tmp_ind, error_tmp_ind);
tmp_ind(interid) = [];

reduce_id = tmp_ind;
if length(reduce_id) == 0
    reduce_tracklet = [];
else
    for ii = 1:length(reduce_id)
        reduce_tracklet{ii, 1} = tracklets(reduce_id(ii)).name;
    end
end