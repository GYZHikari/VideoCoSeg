function [tracklets_overs, div_track, track_size] = gene_tracklets_shapevariance(names_out, list, trackletimgpath, ht, wd)
tracklets_overs = zeros(length(list)-1, 1);
for trackinds = 1:length(names_out)-1
    if ~exist([trackletimgpath, names_out{trackinds}])
        tmpgiven = ['rame', names_out{trackinds}(1:4), '_seg_fcn.png'];
    else
        tmpgiven =  names_out{trackinds};
    end
    if ~exist(tmpgiven) && strcmp(names_out{trackinds}(end - 6:end-4), 'fcn')
        tmpgiven = ['0', names_out{trackinds}];
    end
    foreimg = (imread([trackletimgpath,tmpgiven]));
    %     foreimg = imread([trackletimgpath, names_out{trackinds}]);
    if size(foreimg, 3) == 3
        foreimg = im2double(foreimg);
        foreimg = foreimg(:,:,1);
    end
    if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
        foreimg = imresize(foreimg, [ht, wd]);
    end
    if ~exist([trackletimgpath, names_out{trackinds+1}])
        tmpgiven = ['rame', names_out{trackinds+1}(1:4), '_seg_fcn.png'];
    else
        tmpgiven =  names_out{trackinds+1};
    end
    if ~exist(tmpgiven) && strcmp(names_out{trackinds+1}(end - 6:end-4), 'fcn')
        tmpgiven = ['0', names_out{trackinds+1}];
    end
    
    nextimg = (imread([trackletimgpath,tmpgiven]));
%     trackinds
    %     nextimg = imread([trackletimgpath, names_out{trackinds + 1}]);
    if size(nextimg, 3) == 3
        nextimg = im2double(nextimg);
        nextimg = nextimg(:,:,1);
    end
    [~, ~, overlap, ~, ~] = precision_recall_overlap_evaluation(foreimg, nextimg);
    tracklets_overs(trackinds) = overlap;
    track_size(trackinds) = numel(find(foreimg(:)~=0));
end
div_track = zeros(length(list)-1, 1);
for ii = 1:length(tracklets_overs) - 1
    div_track(ii) = tracklets_overs(ii) - tracklets_overs(ii + 1);
end

