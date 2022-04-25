close all; clear; setup_path();
mat_root = mat_output_root();
% load('img_set_disk_1em9_final2.mat');
load(fullfile(mat_root,'img_set_disk_1em10_rev2.mat'));
json_file = 'level_1_results_rev2_1em10.json';

%% user settings
meta_output_fields = {'file_name','design','num_planets','planets','disk'};
disk_output_fields = {'inclination_deg','density','forward_scattering','brigthness_counts'};
planet_output_fields = {'xy_pixels','xy_mas','xy_uncertainty_mas','planet_counts','planet_SNR','planet_star_ratio'};
xy_center = [33 33];

%% main script
images = img_set.images;
meta = cat(1,images.meta);

list_out = cell(numel(meta),1);
for i1 = 1:numel(meta)
    data_i1 = keep_fields(meta(i1),meta_output_fields);
    data_i1.disk = keep_fields(data_i1.disk,disk_output_fields);
    if data_i1.num_planets > 0
        data_i1.planets = keep_fields(data_i1.planets,planet_output_fields);
    else
        data_i1.planets = [];
    end
    list_out{i1} = data_i1;
end

json_out = jsonencode(list_out,'PrettyPrint',true,'ConvertInfAndNaN', false);
save_plaintext(json_file,json_out);


fid = fopen(json_file,'r');
json_string = fread(fid,'char=>char')';
fclose(fid);
data = jsondecode(json_string);