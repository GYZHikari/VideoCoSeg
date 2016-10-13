function spfea = cnnfea_pixel2sp(fea, pix)
spfea = cell(length(fea), 1);
for ii = 1:length(fea)
    for jj = 1:length(pix)
        tmp = mean(fea{ii}(:, pix{jj}), 2) / length(pix{jj});
%         spfea{ii}(:, jj) = tmp/(norm(tmp(:))+eps);
        spfea{ii}(:, jj) = tmp;
    end
end
