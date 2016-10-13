function scores = gene_tracklets_shapes(names_out, list, trackletimgpath, ht, wd, pyramid, opt)
type = opt.shapetype;
switch lower(type)
    case '360'
        scores = zeros(360, length(list));
        if ~exist('pyramid', 'var')
            pyramid = {[1,1]};
        end
        if length(pyramid) == 1
            for trackinds = 1:length(names_out)
                if ~exist([trackletimgpath, names_out{trackinds}])
                    tmpgiven = ['rame', names_out{trackinds}(1:4), '_seg_fcn.png'];
                else
                    tmpgiven =  names_out{trackinds};
                end
                if ~exist(tmpgiven) && strcmp(names_out{trackinds}(end - 6:end-4), 'fcn')
                    tmpgiven = ['0', names_out{trackinds}];
                end
                foreimg = (imread([trackletimgpath,tmpgiven]));
                %                 foreimg = imread([trackletimgpath, names_out{trackinds}]);
                if size(foreimg, 3) == 3
                    foreimg = im2double(foreimg);
                    foreimg = foreimg(:,:,1);
                end
                if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
                    foreimg = imresize(foreimg, [ht, wd]);
                end
                
                scores(:, trackinds) = region_to_shape(foreimg);
                scores(:, trackinds) = normal_gyz(scores(:, trackinds));
            end
        else
            for trackinds = 1:length(names_out)
                if ~exist([trackletimgpath, names_out{trackinds}])
                    tmpgiven = ['rame', names_out{trackinds}(1:4), '_seg_fcn.png'];
                else
                    tmpgiven =  names_out{trackinds};
                end
                if ~exist(tmpgiven) && strcmp(names_out{trackinds}(end - 6:end-4), 'fcn')
                    tmpgiven = ['0', names_out{trackinds}];
                end
                foreimg = (imread([trackletimgpath,tmpgiven]));
                %                 foreimg = imread([trackletimgpath, names_out{trackinds}]);
                if size(foreimg, 3) == 3
                    foreimg = im2double(foreimg);
                    foreimg = foreimg(:,:,1);
                end
                if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
                    foreimg = imresize(foreimg, [ht, wd]);
                end
                idx = find(foreimg~=0);
                [y,x] = ind2sub([ht, wd], idx);
                
                numLayers = length(pyramid);
                numGroups = zeros(numLayers,1);
                for ii = 1:numLayers
                    numGroups(ii) = pyramid{ii}(1)*pyramid{ii}(2);
                end
                numBins = sum(numGroups);
                score = [];
                for ii = 1:numLayers
                    nBins = numGroups(ii);
                    wUnit = ht / pyramid{ii}(1);
                    hUnit = wd / pyramid{ii}(2);
                    
                    xBin = ceil(x / wUnit);
                    yBin = ceil(y / hUnit);
                    idxBin = (yBin-1)*pyramid{ii}(1) + xBin;
                    
                    for jj = 1:nBins
                        sidxBin = find(idxBin == jj);
                        if isempty(sidxBin)
                            score_sub = zeros(360,1);
                        else
                            sub_img = zeros(size(foreimg));
                            sub_img(idx(sidxBin)) = 1;
                            score_sub = region_to_shape(sub_img)
                            score_sub = normal_gyz(score_sub);
                        end
                        score = [score; score_sub];
                    end
                end
                scores(:, trackinds) = score;
            end
        end
        
        
    case 'context'
        defaultoptions = struct('r_max',4,'r_min',1e-3,'r_bins',8,'a_bins',16,'rotate',0,'method',1,'maxdist',5);
        for trackinds = 1:length(names_out)
            foreimg = imread([trackletimgpath, names_out{trackinds}]);
            if size(foreimg, 3) == 3
                foreimg = im2double(foreimg);
                foreimg = foreimg(:,:,1);
            end
            if size(foreimg, 1)~=ht || size(foreimg, 2)~=wd
                foreimg = imresize(foreimg, [ht, wd]);
            end
            
            mask = uint8(foreimg);
            bdy = mask - imerode(mask,strel('diamond',1));
            [X,Y] = ind2sub(size(bdy),find(bdy));
            X = X(1:2:length(X)); Y = Y(1:2:length(Y));
            BH = getHistogramFeatures([X,Y],[X,Y],[],defaultoptions);
            BH = mean(BH, 2);
            scores(:, trackinds) = BH;
        end
end


