function [s1] = keep_fields(s0,fkeep)
%KEEP_FIELDS Summary of this function goes here
%   Detailed explanation goes here
fnames = fieldnames(s0);
if ~isempty(fnames)
    s1 = rmfield(s0,fnames(~ismember(fnames,fkeep)));
    s1 = orderfields(s1,fkeep);
else
    s1 = s0;
end
end

