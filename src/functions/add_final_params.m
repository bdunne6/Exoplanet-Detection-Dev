function [img_set] = add_final_params(img_set)
%ADD_FINAL_PARAMS Summary of this function goes here
%   Detailed explanation goes here
images = img_set.images;
% keywords = images(1).get_fits_keywords();
% keywords{1}


xy_center = [33 33];

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

        int_timei2 = image_i1.lookup_fits_key('INTTIME');
        int_timei2 = int_timei2{i2};

        star_total_counts = start_fluxi2*int_timei2;

        planets_i2 = struct();

        for i3 = 1:numel(metai2.planet_locations)
            pixels_xy_i3 = [metai2.planet_locations(i3).x_r, metai2.planet_locations(i3).y_r];
            pixels_xy_i3 = [pixels_xy_i3(1) + image_i1.roi(2)-1 , pixels_xy_i3(2) + image_i1.roi(1)-1];
            planets_i2(i3).xy_pixels  = pixels_xy_i3;
            planets_i2(i3).xy_mas = (pixels_xy_i3 - [xy_center])*pixel_scale_i1;
            planets_i2(i3).xy_uncertainty_mas  = [metai2.planet_locations(i3).x_u, metai2.planet_locations(i3).x_u]*pixel_scale_i1;
            planets_i2(i3).planet_counts = metai2.planet_locations(i3).counts;
            planets_i2(i3).planet_SNR = metai2.planet_locations(i3).snr_est;
            planets_i2(i3).fwhm = metai2.planet_locations(i3).fwhm;
            planets_i2(i3).planet_star_ratio = metai2.planet_locations(i3).counts/star_total_counts;
        end

        %% disk properties
        axes_ratio = metai2.disk.exozodi_opt.axes_ratio;
        if axes_ratio > 1
            axes_ratio = 1/axes_ratio;
        end

        planets_i2 = planets_i2(:);

        %% assign back to meta struct
        metai2.planets = planets_i2;

        metai2.disk.inclination_deg = acosd(axes_ratio);
        metai2.disk.density = NaN;
        metai2.disk.forward_scattering = NaN;
        metai2.disk.brigthness_counts = metai2.disk.magnitude_counts;

        meta_i1{i2} = metai2;
    end
    images(i1).meta = cat(1,meta_i1{:});

end
img_set.images = images;
end

