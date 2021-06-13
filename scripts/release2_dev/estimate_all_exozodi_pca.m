addpath(genpath(fullfile('..','..','src')))

img_folder = 'X:\project_data\JPL\starshade_exoplanet\SEDC Starshade Rendezvous Imaging Simulations_v3\Simulated data\sister_sedc_starshade_rendezvous_imaging_1em10';

% img_set = StarshadeImageSet(img_folder,1);
% save('img_set.mat','img_set');

load('img_set.mat');


[img_set, i_equal] = img_set.select('equal',struct('snr_level',3));
img_set_new = img_set.stack_by({'passband'});

X = zeros(numel(img_set_new.images),numel(img_set_new.images(1).data));

img_size = size(img_set_new.images(1).data);
for i1 = 1:numel(img_set_new.images)
    X(i1,:) = img_set_new.images(i1).data(:);
end

mdl = pca_model(X,0,1);

figure;
img_mean = reshape(mdl.Xm,img_size);
imagesc(img_mean(:,:,2))

% figure(101);
% t1 = tiledlayout(1,2);
% for i1 = 1:size(mdl.coeff,2)
%     compi1 = reshape(mdl.coeff(:,i1),img_size);
%     nexttile(1)
%     imagesc(compi1(:,:,1))
%     nexttile(2)
%     imagesc(compi1(:,:,2))
%     pause(1)
% end




figure(101)
t1 = tiledlayout(3,2);

for i0 = 1:numel(img_set_new.images)
    
    
    img_sample = img_set_new.images(i0).data;
    scores = mdl.project(img_sample(:));
    
    nexttile(1)
    imagesc(img_sample(:,:,1))
    nexttile(2)
    imagesc(img_sample(:,:,2))
    for i1 = 11%numel(scores)
        reci1 = mdl.reconstruct(scores(1:i1));
        reci1 = reshape(reci1,img_size);
        
        nexttile(3)
        imagesc(reci1(:,:,1))
        nexttile(4)
        imagesc(reci1(:,:,2))
        drawnow();
        
        
        nexttile(5)
        imagesc(img_sample(:,:,1) - reci1(:,:,1))
        nexttile(6)
        imagesc(img_sample(:,:,2) - reci1(:,:,2))
        drawnow();
    end
end
