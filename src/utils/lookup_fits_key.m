function [vals] = lookup_fits_key(fits_info,key)
%LOOKUP_FITS_KEY Summary of this function goes here
%   Detailed explanation goes here
if ~iscell(fits_info)
    fits_info = num2cell(fits_info);
end

vals = cell(numel(fits_info),1);
for i1 = 1:numel(fits_info)
    keywords = fits_info{i1}.PrimaryData.Keywords;
    i_match = strcmpi(keywords(:,1),key);
    val = keywords(i_match,2);
    vals{i1} = val{1};
end
if numel(vals) == 1
    vals = vals{1};
end
end

