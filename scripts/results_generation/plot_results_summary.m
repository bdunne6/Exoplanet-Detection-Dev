json_file = 'level_1_results_rev2_1em10.json';
fid = fopen(json_file,'r');
json_string = fread(fid,'char=>char')';
fclose(fid);
data2 = jsondecode(json_string);