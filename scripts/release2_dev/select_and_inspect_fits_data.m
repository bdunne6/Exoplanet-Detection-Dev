addpath(genpath(fullfile('..','..','src')))

%specify directory of .fits image files
starshade_root = 'X:\project_data\JPL\starshade_exoplanet\release_2_data\SEDC Starshade Rendezvous Imaging Simulations_v3';
img_folder = fullfile(starshade_root,'\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10');
%construct the StarShadeImageSet (populates meta-data for all images)
img_set = StarshadeImageSet(img_folder);
%load all images into memory
img_set.load();
% load('img_set.mat');


img_setr1 = StarshadeImageSet('X:\project_data\JPL\starshade_exoplanet\release_1_data\1860_Release_1\Simulated data\');
img_setr1.load();

%% plot scenario 3 visits in RGB
%specify fields to select by equality
s_select = struct('scenario',5,'snr_level',3,'exozodi_model','rez','exozodi_intensity',2,'visit_num',1);
%select specified images
img_set1 = img_set.select('equal',s_select);
%stack passband images together into N-by-M-by-P matrix where P is number of passbands
% img_set1 = img_set1.stack_by({'passband'});
%plot all selected and stacked images
img_set1.plot_all(101);


s_select = struct('scenario',5,'snr_level',3);
%select specified images
img_set2 =img_setr1.select('equal',s_select);

%stack passband images together into N-by-M-by-P matrix where P is number of passbands
% img_set1 = img_set1.stack_by({'passband'});
%plot all selected and stacked images
img_set2.plot_all(102);

%% plot scenario 3 disk models
% %specify fields to select by equality
% s_select = struct('scenario',3,'snr_level',3,'exozodi_intensity',1,'exozodi_model','rez');
% %select specified images
% img_set1 = img_set.select('equal',s_select);
% %plot all selected and stacked images
% img_set1.plot_all(102);
