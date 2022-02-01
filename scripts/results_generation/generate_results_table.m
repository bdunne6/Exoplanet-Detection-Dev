

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

    for i2 = 1:numel(image_i1.meta)
        data_i2 = struct();
        metai2 = image_i1.meta(i2);
        data_i2.file_name = metai2.file_name;
        data_i2.design = designi1{i2};
        data_i2.num_planets = numel(metai2.planet_locations);

        start_fluxi2 = image_i1.lookup_fits_key('STARFLX');
        start_fluxi2 = start_fluxi2{i2};
%         figure(111);
%         hold off;
%         imagesc(image_i1.data(:,:,i2))
%         hold on;

        pixels_xy = [];
        planets_i2 = [];
        for i3 = 1:numel(metai2.planet_locations)
            pixels_xy_i3 = [metai2.planet_locations(i3).x_r, metai2.planet_locations(i3).y_r];
            pixels_xy_i3 = [pixels_xy_i3(1) + image_i1.roi(2)-1 , pixels_xy_i3(2) + image_i1.roi(1)-1];
            %             pixels_xy = cat(1,pixels_xy,pixels_xy_i3);

            planets_i2(i3).xy_pixels  = pixels_xy_i3;
            planets_i2(i3).xy_mas = (pixels_xy_i3 - [xy_center])*pixel_scale_i1;
            planets_i2(i3).xy_uncertainty_mas  = [metai2.planet_locations(i3).x_u, metai2.planet_locations(i3).x_u]*pixel_scale_i1;
            planets_i2(i3).planet_counts = metai2.planet_locations(i3).counts;
            planets_i2(i3).planet_SNR = metai2.planet_locations(i3).counts_snr;
            planets_i2(i3).planet_star_ratio = metai2.planet_locations(i3).counts/start_fluxi2;
        end


        clear('disk_i2');
        %% disk properties
        axes_ratio = metai2.disk.exozodi_opt.axes_ratio;
        if axes_ratio > 1
            axes_ratio = 1/axes_ratio;
        end

        inclination = acosd(axes_ratio);
        disk_i2.inclination_deg = inclination;
        disk_i2.density = NaN;
        disk_i2.forward_scattering = NaN;
        disk_i2.brigthness_counts = metai2.disk.magnitude_counts;
        %collect outputs
        data_i2.planets = planets_i2;
        data_i2.disk = disk_i2;
        list_out = cat(1,list_out,{data_i2});
    end

end


json_out = jsonencode(list_out,'PrettyPrint',true,'ConvertInfAndNaN', false);

save_plaintext(json_file,json_out);


fid = fopen(json_file,'r');
json_string = fread(fid,'char=>char')';
fclose(fid);
data = jsondecode(json_string);
data(1).planets(1).xy_mas


% json_out
% jstruct_out.results = list_out;
% json_out = jsonencode(list_out(1));
% 
% a.f = 1;
% b.gh= 23;
% 
% jsonencode({a,b})

% For each image in Release 2
% Planet detection: No. Planets, Planet location (milli-arcsec) and uncertainty
% Planet broadband photometry: Planet counts, Planet S/N, Planet/Star (star counts are provided in FITS header)
% Disk characterization: Disk inclination, Disk density ("zodis"), Disk forward scattering factor (between 0 and 1, if possible), or Disk brightness

% trans_file_425 = fullfile(data_root,'Calibration files','starshade_averaged_transmission_NI2_sedc_1em10_0425_0552_nm.fits');
% trans_file_615 = fullfile(data_root,'Calibration files','starshade_averaged_transmission_NI2_sedc_1em10_0615_0800_nm.fits');
%
% t1 = fitsread(trans_file_425,'raw');
% t2 = fitsread(trans_file_615,'raw');
%
% transmission1 = fitsread()