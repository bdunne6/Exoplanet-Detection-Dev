function [json_content] = save_plaintext(json_file,text)
%LOAD_PLAINTEXT Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(json_file,'w');
json_content= fwrite(fid,text)';
fclose(fid);
end

