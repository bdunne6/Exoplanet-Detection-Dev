%% load the individual image files
image_root = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\';

% image_folders = dir(fullfile(image_root,'sister_sedc_starshade_rendezvous_imaging_*'));
image_folders = dir(fullfile(image_root,'sister_sedc_starshade_rendezvous_imaging_1em10*'));

for i0 = 1:numel(image_folders)
    image_folderi0 = fullfile(image_folders(i0).folder,image_folders(i0).name);
    name_parts = strsplit(image_folders(i0).name,'_');
    starshade_contrast_i0 = name_parts{end};
    
    
    image_files = dir(fullfile(image_folderi0,'*.fits'));
    clear('image_data')
    for i1 = 1:numel(image_files)
        image_filei1 = fullfile(image_files(i1).folder,image_files(i1).name);
        info        = fitsinfo(image_filei1);
        imgi1 = fitsread(image_filei1,'raw');
        
        name_parts = strsplit(image_files(i1).name,'_');
        
        
        %add image data and meta-data to a struct array
        image_data(i1).file_path = image_filei1;
        image_data(i1).data = imgi1;
        image_data(i1).fits_info = info;
        image_data(i1).RH = name_parts{2}(1);
        image_data(i1).scenario = str2double(name_parts{2}(2:end));
        image_data(i1).visit_num = str2double(name_parts{3}(2:end));
        image_data(i1).exozodi_intensity = str2double(name_parts{4}(4:end));
        image_data(i1).snr_level = str2double(name_parts{5}(4:end));
        image_data(i1).passband = [str2double(name_parts{6}),str2double(name_parts{7})];
        rparts = strsplit(name_parts{9},'.');
        image_data(i1).release = str2double(rparts{1}(2:end));
    end
    
end

%% load the calibration files
cal_root = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Calibration files\';

%load the psf fits file
psf_file = fullfile(cal_root,'psf_averaged_NI2_sedc_1em9_0425_0552_nm.fits');
psf_info = fitsinfo(psf_file);
data = fitsread(psf_file,'raw');
data = permute(data,[3 2 1]);

%add psf data to the output struct
calibration.psf.file_path = psf_file;
calibration.psf.fits_info = psf_info;
calibration.psf.data = data;

%load the transmission files
transmission_file = fullfile(cal_root,'starshade_averaged_transmission_NI2_sedc_1em9_0425_0552_nm.fits');
transmission_info = fitsinfo(transmission_file);
trans = fitsread(transmission_file,'raw');

%add transmission data to the output struct
calibration.transmission.file_path = transmission_file;
calibration.transmission.fits_info = transmission_info;
calibration.transmission.data = trans;

release2_data.cal = calibration;
release2_data.images = image_data;

% save all release 1 data in a convenient struct
save('release2_data.mat','release2_data');

