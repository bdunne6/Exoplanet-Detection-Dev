close all; clear; setup_path();


mat_root = mat_output_root();
mat_path = fullfile(mat_root,'img_set_disk_1em10_rev2.mat');

load(mat_path);
img_set = add_final_params(img_set);
save(mat_path,'img_set');

