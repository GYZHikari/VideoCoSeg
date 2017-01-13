function names = gene_names(dirresults)
for ii = 1:length(dirresults)
    names{ii} = dirresults(ii).name;
end