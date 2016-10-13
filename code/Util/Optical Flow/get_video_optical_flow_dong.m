function get_video_optical_flow_dong(project_path)
    close all;
    if nargin==0
        project_path='D:\Data\UCF11\basketball_OF_background_results\v_shooting_20_07\';
    end
    slash_indexes=regexp(project_path,'\\');
    result_path=[project_path(1:slash_indexes(end)-1) '_OF\'];
    if ~exist(result_path)
        mkdir(result_path);
    end
    project_name=project_path(slash_indexes(end-1)+1:slash_indexes(end)-1);
    image_index=0;
    while true
        close all;
        image_index=image_index+1;
        image1_path=sprintf('%s%s_%d.bmp',project_path,project_name,image_index);
        image2_path=sprintf('%s%s_%d.bmp',project_path,project_name,image_index+1);
        if exist(image1_path)&&exist(image2_path)
            im1=imread(image1_path);
            im2=imread(image2_path);
            [flow flow_color]=get_optical_flow_dong(im1,im2);
            flow_color_path=sprintf('%s%s_%d.bmp',result_path,project_name,image_index);
            imwrite(flow_color,flow_color_path);
            %pause;
        end
    end