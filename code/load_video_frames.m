function videoAll = load_video_frames(video_info)
% load video
videoAll = cell(video_info.framenum,1);
ht = video_info.ht;
wd = video_info.wd;
for ii = 1:video_info.framenum
    tmp = imread([video_info.inputpath video_info.list(ii).name]);
    if size(tmp,1)~=ht || size(tmp, 2)~=wd
        videoAll{ii} = imresize(tmp,[ht wd]);
    else
        videoAll{ii} = tmp;
    end
end