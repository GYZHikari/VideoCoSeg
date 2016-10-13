function [forenames_out, backnames_out] = gene_trackletimg_strings(forenames, backnames, allnames, type)
forenames_out = cell(length(allnames), 1);
backnames_out = cell(length(allnames), 1);
if length(forenames) == 0
    tmpfore = [];
else
    for ii = 1:length(forenames)
        tmpfore{ii, 1} = forenames(ii).name;
    end
end
if length(backnames) == 0
    tmpback = [];
else
    for ii = 1:length(backnames)
        tmpback{ii, 1} = backnames(ii).name;
    end
end

if nargin<4
    type = 'youtube';
end
switch lower(type)
    case 'youtube'
        beginind = 6;
        endind = 4;
    case 'safari'
        beginind = 1;
        endind = 4;
    case 'movics'
        beginind = 1;
        endind = 4
end
for ii = 1:length(allnames)
    if any(strcmp(tmpfore, [allnames(ii).name(beginind:end-endind), '_mask.png']))
        forenames_out{ii} = [allnames(ii).name(beginind:end-endind), '_mask.png'];
    else
        if any(strcmp(tmpback, [allnames(ii).name(beginind:end-endind), '_mask_inverse.png']))
            forenames_out{ii} = [allnames(ii).name(beginind:end-endind), '_mask_inverse.png'];
        else
            forenames_out{ii} = [allnames(ii).name(beginind:end-endind), '_fcn.png'];
        end
    end
    
    if any(strcmp(tmpback, [allnames(ii).name(beginind:end-endind), '_mask_inverse.png']))
        backnames_out{ii} = [allnames(ii).name(beginind:end-endind), '_mask_inverse.png'];
    else
        if any(strcmp(tmpfore, [allnames(ii).name(beginind:end-endind), '_mask.png']))
            backnames_out{ii} = [allnames(ii).name(beginind:end-endind), '_mask.png'];
        else
            backnames_out{ii} = [allnames(ii).name(beginind:end-endind), '_fcn.png'];
        end
    end
    
end