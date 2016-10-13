function  reduce_fcn_ratio = reduce_noise_tracklets(trackpath, tracklets, mode)

if nargin < 3
    mode = 'fcn-ratio';
end
switch lower(mode)
    case 'fcn-ratio'
        for ii = 1:length(tracklets)
            locs = find(char(tracklets(ii).name) == '_');
            curname = [trackpath, tracklets(ii).name(1:locs(1) - 1), '/',...
                tracklets(ii).name(locs(1) + 1 : locs(2) - 1), '/', tracklets(ii).name(locs(2) + 1 : locs(3) - 1), ...
                '/', tracklets(ii).name(locs(3) + 1 : locs(6) - 1), '/'];
            fcnnames = dir([curname, '*_fcn.png']);
            allnames = dir([curname, '*.png']);
            reduce_fcn_ratio(ii) = length(fcnnames)/length(allnames);
        end
    otherwise
        error('No such reduce option!!');
end

