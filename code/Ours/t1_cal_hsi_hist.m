function [sp_pixel_num, temp_sp_cl_hist] = t1_cal_hsi_hist(temp_frame,ch_bins_num,sp_num,labels)

ff = temp_frame;
cy = size(ff,1);
cx = size(ff,2);
f_bins = fix(ff(:,:,1) * ch_bins_num) + (fix(ff(:,:,2) * ch_bins_num) * ...
         ch_bins_num + fix(ff(:,:,3) * ch_bins_num) * ch_bins_num^2 + ones(cy,cx)); 
f_bins = uint16(f_bins);
temp_sp_cl_hist = zeros(ch_bins_num^3, sp_num);     
temp_labels = labels;      

t = tabulate(temp_labels(:));%  t is sp_num*3 first column is label numbers of superpixel image 
sp_pixel_num = t(:,2);

for k = 1:sp_num
    x = min(ch_bins_num^3, f_bins(temp_labels == k));

    %% count freq
    x = sort(x);
    x1 = diff(x);
    x1 = x1(:);
    x1(end + 1) = 1; 
    x1 = find(x1); 
    x1 = x1(:);
    value = x(x1); 
    x1 = [0; x1]; 
    freq = diff(x1); 

    temp_sp_cl_hist(value, k) =  freq / sp_pixel_num(k);
end

%% normalization of the histogram
temp_sp_cl_hist = temp_sp_cl_hist ./ repmat(sum(temp_sp_cl_hist,1), size(temp_sp_cl_hist,1), 1);
% temp_index = [ones(1,temp_frame.sp_num)*frame_num; N_superpixels'];
     