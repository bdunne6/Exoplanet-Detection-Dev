addpath(genpath(fullfile('..','..','src')))

img_folder = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';

% img_set = StarshadeImageSet(img_folder,1);
% save('img_set.mat','img_set');

load('img_set.mat');

s.passband = [425,552];
tic
[img_set, i_equal] = img_set.select('equal',struct('snr_level',3));
toc

% uset = {'RH','scenario','visit_num','exozodi_intensity','snr_level','exozodi_model'};
% tic
% i_unique = img_set.unique(uset);
% toc
% 
% tic
% i_unique1 = img_set.unique({'passband'});
% toc

img_set_new = img_set.stack_by({'passband'});

%img_set_new.load();

% fits_files = dir(fullfile(image_folderi0,'*.fits'));
% for i1 = 1:numel(fits_files)
%     sample_inputi1 = fullfile(fits_files(i1).folder,fits_files(i1).name);
%     simg(i1) = StarshadeImage(sample_input);
% end
figure(101)
t1 = tiledlayout(1,2);
for i1 = 1:numel(img_set_new.images)
    ax1 = nexttile(1);
    imgb1 = img_set_new.images(i1).data(:,:,1);
    imagesc(imgb1)
    title(img_set_new.images(i1).meta(1).file_name,'Interpreter','none');
    ax2 = nexttile(2);
    imgb2 = img_set_new.images(i1).data(:,:,2);
    imagesc(imgb2)
    title(img_set_new.images(i1).meta(2).file_name,'Interpreter','none');
    drawnow();
    linkaxes([ax1,ax2],'xy');
    pause(1)
end