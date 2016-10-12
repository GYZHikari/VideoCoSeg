function [trackind, totalmaxnum] = cal_tracklet_ind(imglist, cluster_names, total_num, param_track)

for ii = 1:length(cluster_names)
	cluster_id(ii) = str2double(cluster_names(ii).name(1:end-4));
end
% initial pool
if total_num < 36
	imglist = [1, total_num];
else
	gap = 10;
	imglist = [16:gap:total_num];
	if numel(imglist) > 10
		randnum = randperm(numel(imglist));
		imglist = imglist(randnum(1:5));
	end
	imglist = sort(imglist);
end
imglist = intersect(imglist, cluster_id);

if length(imglist) == 0
	randnum = randperm(numel(cluster_id));
	imglist = cluster_id(randnum(1));
end
if trackind(end)==total_num && numel(trackind) >= 2
    totalmaxnum = length(trackind)-1;
else
    totalmaxnum = length(trackind);
end

totalmaxnum = max(totalmaxnum, 1);
