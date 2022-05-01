mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));

%load detections and estimates
load(fullfile(mat_root,'img_set_disk_1em10_rev2.mat'));
img_set = img_set.unstack();

% [~,fname] = fileparts(mat_true(1).name);
% 
% fname = [fname,'.fits'];
% 
% s = struct('file_name',fname);
% 
% img_set_new = img_set.select('equal',s);


for i1 = 1:numel(mat_true)
    mat_filei1 = fullfile(mat_true(i1).folder,mat_true(i1).name);
    dt = load(mat_filei1);

    fits_name = strrep(mat_true(i1).name,'.mat','.fits');

    [image_set_i1,i_selected] = img_set.select('equal',struct('file_name',fits_name));

    image_m = image_set_i1.images;
    image_m.meta_true


    starflx = image_m.lookup_fits_key('STARFLX');
    inttime = image_m.lookup_fits_key('INTTIME');

    dm.star_total_PSF_counts = starflx{1}*inttime{1};
    dm.planets_total_PSF_counts = [];
    dm.planets_star_flux_ratio = [];
    if ~isempty(image_m.meta.planet_locations)

        for i2 = 1:numel(image_m.meta.planet_locations)
            dm.planets_total_PSF_counts = [dm.planets_total_PSF_counts,image_m.meta.planet_locations.counts];
        end
        dm.planets_star_flux_ratio = dm.planets_total_PSF_counts./dm.star_total_PSF_counts;
    end

    if ~isempty(dm.planets_star_flux_ratio)
        format long
        disp('flux ratios:')
        disp(dt.planets_star_flux_ratio)
        disp(dm.planets_star_flux_ratio)
    end



end

