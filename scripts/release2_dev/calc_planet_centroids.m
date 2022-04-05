clear;
close all;

mdl_path = fullfile('ica_models1','ica_17_ec2012725779cfc8a01eb63c55e867a7.mat');
%mdl_path = fullfile('ica_models_1em9','ica_19_b7d23f1924ea919bc6a3620b473a79bc.mat');


mdl_data = load(mdl_path);

mdl = mdl_data.ica_mdl;

%load('img_set_disk.mat');
%img_set = img_set.stack_by({'passband'});
load('img_set_disk.mat');
%img_set = img_set.stack_by({'passband'});

% vidObj = VideoWriter('pca1.mp4','MPEG-4');
% vidObj.FrameRate = 1;
% vidObj.Quality = 100;
% open(vidObj);

sigma_lookup_files = dir(fullfile('..','mat_files','psf_*.mat'));
ind = find(contains({sigma_lookup_files.name},'0425_0552'));
sigma_lookup1 = load(fullfile(sigma_lookup_files(ind(1)).folder,sigma_lookup_files(ind(1)).name));
ind = find(contains({sigma_lookup_files.name},'0615_0800'));
sigma_lookup2 = load(fullfile(sigma_lookup_files(ind(1)).folder,sigma_lookup_files(ind(1)).name));

figure(101)
set(gcf,'Color','white')
tile_size = [2,3];
t1 = tiledlayout(tile_size(1),tile_size(2));
t1.Padding = 'compact';
t1.TileSpacing = 'compact';
tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);

% img_set.images = img_set.images(randperm(numel(img_set.images)));

load('planet_labels.mat');
% load('planet_labels_1em9_final.mat');
% if exist('planet_checks.mat','file')
%     load('planet_checks.mat')
% else
%     planet_checks = [];
% end
i_del = [planet_labels.x]<10|[planet_labels.y]<10|[planet_labels.x]>35|[planet_labels.y]>60;
planet_labels(i_del) = [];


figure;
plot([planet_labels.x],[planet_labels.y],'.r')
xlim([0 Inf])
ylim([0 Inf])



cvec = -2:2;
[xg,yg] = meshgrid(1:41,1:41);
for i0 = 1:numel(img_set.images)

%     [contains({img_set.images(i0).meta(1).file_name},'0425_0552'),contains({img_set.images(i0).meta(1).file_name},'0615_0800')]
    


    disp([num2str(i0) ' of ' num2str(numel(img_set.images))])

    %     if ~isempty(planet_checks)&&any(ismember({img_set.images(i0).meta.file_name},{planet_checks.file_name}))
    %         disp([img_set.images(i0).meta(1).file_name, ' found, skipping.' ]);
    %         continue;
    %     end


    labels_1 = find(ismember({planet_labels.file_name},img_set.images(i0).meta(1).file_name));
    labels_1 = planet_labels(labels_1);
    labels_1 = labels_1([labels_1.button] <= 2);

    labels_2 = find(ismember({planet_labels.file_name},img_set.images(i0).meta(2).file_name));
    labels_2 = planet_labels(labels_2);
    labels_2 = labels_2([labels_2.button] <= 2);

    img_sample = img_set.images(i0).data_roi;
    img_size = size(img_sample);
    %plot the original images
    ax3 = nexttile(tile_2d(1,1));
    cla(ax3);
    imagesc(ax3,img_sample(:,:,1))
    hold on;
    plot([labels_1.x],[labels_1.y],'.r')
    colorbar;
    title_str = img_set.images(i0).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');

    ax4 = nexttile(tile_2d(2,1));
    cla(ax4);
    imagesc(img_sample(:,:,2))
    hold on;
    plot([labels_2.x],[labels_2.y],'.r')
    colorbar;
    title_str = img_set.images(i0).meta(2).file_name(8:end-5);
    title(title_str,'Interpreter','none');

    %plot estimated background and residual
    tw = mdl.TransformWeights;


    dvect = img_sample(:)';
    scores = mdl.transform(dvect)';


    scores1 = dvect*tw;
    %         score1 = tw
    %         scores2 = robustfit(tw,dvect);


    %        i_thresh = prctile(dvect,100*(numel(dvect)-5)/numel(dvect))/2;
    i_thresh = 0.5;
    %         scores2 = robustfit(tw,dvect,'fair',i_thresh);
    scores2 = robustfit(tw,dvect,'huber',i_thresh);
    %scores2 = robustfit(tw,dvect,'ols');


    reci1_2 = tw*scores2(2:end) + scores2(1);
    reci1_2 = reshape(reci1_2,img_size);



    reci1 = tw*scores;
    reci1 = reshape(reci1,img_size);
    reci1 = reci1_2;

    title_str = ['ICA model with ' num2str(mdl.NumLearnedFeatures) ' components.'];
    nexttile(tile_2d(1,2))
    imagesc(reci1(:,:,1))
    colorbar;
    title(title_str,'Interpreter','none');

    nexttile(tile_2d(2,2))
    imagesc(reci1(:,:,2))
    colorbar;
    title(title_str,'Interpreter','none');

    title_str  = 'residual';

    k1 = [0,1,0;1,1,1;0,1,0];
    k2 = fspecial('gaussian',[5 ,5],1);
    ax1 = nexttile(tile_2d(1,3));
    cla(ax1)

    raw_pix1 = img_set.images(i0).data(:,:,1);
    baseline1 = prctile(raw_pix1(:),5);
    mag_ref1 = reci1_2(:,:,1)-baseline1;
    disk_mag1 = sum(mag_ref1(:));
    res1_0  = img_sample(:,:,1) - reci1_2(:,:,1);
    res1 = imfilter(res1_0,k2);
    imagesc(ax1,res1_0)

    if ~isempty(labels_1)
        hold on;
        plot([labels_1.x],[labels_1.y],'.r')
        colorbar;


        for i2 = 1:numel(labels_1)
            cent0 = [labels_1(i2).x,labels_1(i2).y];
            w=7;
            %TODO: Fix the SNR calculation using proper PSF SNR estimation math:
            %https://www.stsci.edu/instruments/wfpc2/Wfpc2_hand6/ch6_exposuretime6.html
            [cent1,cent_fit1] = refine_centroid_gaussian(res1_0 ,cent0,w,sigma_lookup1);
            cent_uncertainty = diff(cent_fit1.ci(2:3,:),1,2)/2;
            labels_1(i2).x_r = cent1(1);
            labels_1(i2).y_r = cent1(2);
            labels_1(i2).x_u = cent_uncertainty(1);
            labels_1(i2).y_u = cent_uncertainty(2);
            labels_1(i2).counts = cent_fit1.counts;
            [~,~,noise_mag] = estimate_counts(res1_0,cent1,5);
            labels_1(i2).counts_snr = labels_1(i2).counts/noise_mag;
        end

        plot([labels_1.x_r],[labels_1.y_r],'om');
    end

    title(title_str);
    ax1.UserData = img_set.images(i0).meta(1).file_name;

    raw_pix2 = img_set.images(i0).data(:,:,2);
    baseline2 = prctile(raw_pix2(:),5);
    mag_ref2 = reci1_2(:,:,2)-baseline2;
    disk_mag2 = sum(mag_ref2(:));

    res2_0  = img_sample(:,:,2) - reci1_2(:,:,2);
    res2 = imfilter(res2_0 ,k2);
    ax2 = nexttile(tile_2d(2,3));
    cla(ax2)
    %store file associated with axes for labelling
    imagesc(ax2,res2_0)
    colorbar;
    %caxis([0 Inf])
    if ~isempty(labels_2)
        hold on;
        plot([labels_2.x],[labels_2.y],'.r')



        for i2 = 1:numel(labels_2)
            cent0 = [labels_2(i2).x,labels_2(i2).y];
            w=3;
            %[cent1] = refine_centroid(res2,cent0,w);
            [cent1,cent_fit2] = refine_centroid_gaussian(res2_0,cent0,w,sigma_lookup2);
            cent_uncertainty = diff(cent_fit2.ci(2:3,:),1,2)/2;
            labels_2(i2).x_r = cent1(1);
            labels_2(i2).y_r = cent1(2);
            labels_2(i2).x_u = cent_uncertainty(1);
            labels_2(i2).y_u = cent_uncertainty(2);
            labels_2(i2).counts = cent_fit2.counts;
            [~,~,noise_mag] = estimate_counts(res2_0,cent1,5);
            labels_2(i2).counts_snr = labels_2(i2).counts/noise_mag;
        end
        plot([labels_2.x_r],[labels_2.y_r],'om');
    end
%     median(res1(:))
%     median(res2(:))
    title(title_str);
    drawnow();
    ax2.UserData = img_set.images(i0).meta(2).file_name;
    %pause(0.1)

    img_set.images(i0).meta(1).planet_locations = rmfield(labels_1,'file_name');
    img_set.images(i0).meta(2).planet_locations = rmfield(labels_2,'file_name');

    img_set.images(i0).meta(1).disk.magnitude_counts = disk_mag1;
    img_set.images(i0).meta(2).disk.magnitude_counts = disk_mag2;
end
save('img_set_disk_1em10_rev2.mat','img_set');
%save('planet_checks.mat','planet_checks');

% function key = key_handler(src,event)
% key = event.key;
% disp(key);
% assignin('base','keyi0',key);
% end
