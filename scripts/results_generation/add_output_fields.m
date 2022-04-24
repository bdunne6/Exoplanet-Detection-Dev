close all; clear; setup_path();

% load('img_set_disk_1em9_final2.mat');
load('img_set_disk_1em10_rev2.mat');
json_file = 'level_1_results_rev2_1em10.json';

% data_root = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3';
%
% img_file1 = fullfile(data_root,'\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10\sister_R01_v1_rez1_snr1_0425_0552_nm_r2.fits');
% fi1 = fitsinfo(img_file1);

images = img_set.images;
% keywords = images(1).get_fits_keywords();
% keywords{1}


xy_center = [33 33];


list_out = [];
for i1 = 1:numel(images)
    image_i1 = images(i1);
    pixel_scale_i1 = image_i1.lookup_fits_key('PIXSCALE');
    pixel_scale_i1  = pixel_scale_i1{1};
    designi1 = image_i1.lookup_fits_key('DESIGN');

    meta_i1 = cell(numel(image_i1.meta),1);
    for i2 = 1:numel(image_i1.meta)

        metai2 = image_i1.meta(i2);
        metai2.design = designi1{i2};
        metai2.num_planets = numel(metai2.planet_locations);

        start_fluxi2 = image_i1.lookup_fits_key('STARFLX');
        start_fluxi2 = start_fluxi2{i2};

        planets_i2 = struct();

        for i3 = 1:numel(metai2.planet_locations)
            pixels_xy_i3 = [metai2.planet_locations(i3).x_r, metai2.planet_locations(i3).y_r];
            pixels_xy_i3 = [pixels_xy_i3(1) + image_i1.roi(2)-1 , pixels_xy_i3(2) + image_i1.roi(1)-1];
            planets_i2(i3).xy_pixels  = pixels_xy_i3;
            planets_i2(i3).xy_mas = (pixels_xy_i3 - [xy_center])*pixel_scale_i1;
            planets_i2(i3).xy_uncertainty_mas  = [metai2.planet_locations(i3).x_u, metai2.planet_locations(i3).x_u]*pixel_scale_i1;
            planets_i2(i3).planet_counts = metai2.planet_locations(i3).counts;
            planets_i2(i3).planet_SNR = metai2.planet_locations(i3).counts_snr;
            planets_i2(i3).planet_star_ratio = metai2.planet_locations(i3).counts/start_fluxi2;
        end

        %% disk properties
        axes_ratio = metai2.disk.exozodi_opt.axes_ratio;
        if axes_ratio > 1
            axes_ratio = 1/axes_ratio;
        end

        planets_i2 = planets_i2(:);

        %% assign back to meta struct
        metai2.planets = planets_i2;
        metai2.disk

        metai2.disk.inclination_deg = acosd(axes_ratio);
        metai2.disk.density = NaN;
        metai2.disk.forward_scattering = NaN;
        metai2.disk.brigthness_counts = metai2.disk.magnitude_counts;

        meta_i1{i2} = metai2;
    end
    images(i1).meta = cat(1,meta_i1{:});

end
img_set.images = images;
save('img_set_disk_1em10_rev2_1.mat','img_set');

