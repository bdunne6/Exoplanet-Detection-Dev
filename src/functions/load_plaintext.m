function [json_content] = load_plaintext(json_file)
%LOAD_PLAINTEXT Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(json_file,'r');
json_content= fread(fid,'char=>char')';
fclose(fid);
end

