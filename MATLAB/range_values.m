function array_range_values = range_values(array, dim)
if nargin < 2
    minimums = min(array);
    maximums = max(array);
    array_range_values = cat(1,minimums,maximums);
else
    minimums = min(array,[],dim,'omitnan');
    maximums = max(array,[],dim,'omitnan');
    array_range_values = cat(dim,minimums,maximums);
end

end

