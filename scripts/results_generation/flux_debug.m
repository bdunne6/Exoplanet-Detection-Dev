mat_true = dir(fullfile('..','..','data','ground_truth','*.mat'));

%load detections and estimates
load('img_set_disk_1em10_rev2.mat');
img_set = img_set.unstack();

for i1 = 1:numel(mat_true)
    mat_filei1 = fullfile(mat_true(i1).folder,mat_true(i1).name);
    dt = load(mat_filei1);

    fits_name = strrep(mat_true(i1).name,'.mat','.fits');

    image_m = img_set.select('equal',struct('file_name',fits_name)).images;


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

% mat_true = 'C:\Users\bdunne\Desktop\Simulated_data\sister_R09_v1_rez3_snr1_0425_0552_nm_r2.mat';
%
% dt = load(mat_true);
%
% load('img_set_disk_1em10_rev2.mat');
%
% [image_m, i_eq1] = img_set.select('equal',struct('file_name','sister_R09_v1_rez3_snr1_0425_0552_nm_r2.fits'));
% image_m = image_m.images;
%
%
% image_m.meta = image_m.meta(1);
% image_m.data = image_m.data(:,:,1);
%
% starflx = image_m.lookup_fits_key('STARFLX');
% inttime = image_m.lookup_fits_key('INTTIME');
%
% dm.star_total_PSF_counts = starflx{1}*inttime{1};
% dm.planets_total_PSF_counts =