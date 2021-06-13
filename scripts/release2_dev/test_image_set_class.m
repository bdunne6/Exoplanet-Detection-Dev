addpath(genpath(fullfile('..','..','src')))

img_folder = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';

% img_set = StarshadeImageSet(img_folder,0);
% save('img_set.mat','img_set');

load('img_set.mat');

s.passband = [425,552];
tic
[img_selected, i_equal] = img_set.select('equal',s);
toc

uset = {'RH','scenario','visit_num','exozodi_intensity','snr_level','exozodi_model'};


tic
i_unique = img_set.unique(uset);
toc

tic
i_unique1 = img_set.unique({'passband'});
toc

img_set_new = img_set.stack_by({'passband'});

% fits_files = dir(fullfile(image_folderi0,'*.fits'));
% for i1 = 1:numel(fits_files)
%     sample_inputi1 = fullfile(fits_files(i1).folder,fits_files(i1).name);
%     simg(i1) = StarshadeImage(sample_input);
% end
