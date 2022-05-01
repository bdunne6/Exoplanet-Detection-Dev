json_file = 'level_1_results_rev4_1em10.json';
fid = fopen(json_file,'r');
json_string = fread(fid,'char=>char')';
fclose(fid);
data2 = jsondecode(json_string);

json_file = 'level_1_results_rev4_1em9.json';
fid = fopen(json_file,'r');
json_string = fread(fid,'char=>char')';
fclose(fid);
data1 = jsondecode(json_string);