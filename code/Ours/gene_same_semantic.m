function tracks = gene_same_semantic(tracks, mode)
if nargin<2
    mode = 'without-fcn';
end
tmpind = [];
for senum = 1:length(tracks)
    tmpcurname = tracks(senum).name;
    locs = find(char(tmpcurname) == '_');
    
    switch lower(mode)
        case 'without-fcn'
            
            if ~strcmp(tmpcurname(locs(2) + 1 : locs(3) - 1), tmpcurname(1 :locs(1) - 1)) || strcmp(tmpcurname(locs(end-1) + 1 : locs(end) - 1), 'fcn')
                tmpind = [tmpind; senum];
            end
        case 'with-fcn'
            if ~strcmp(tmpcurname(locs(2) + 1 : locs(3) - 1), tmpcurname(1 :locs(1) - 1))
                tmpind = [tmpind; senum];
            end
        case 'without-fcn-all'
            if strcmp(tmpcurname(locs(end-1) + 1 : locs(end) - 1), 'fcn')
                tmpind = [tmpind; senum];
            end
        case 'fcn-all'
             if ~strcmp(tmpcurname(locs(end-1) + 1 : locs(end) - 1), 'fcn')
                tmpind = [tmpind; senum];
            end
            
        otherwise
            error('No Such opt.tracklet')
            
    end
end
tracks(tmpind) = [];
