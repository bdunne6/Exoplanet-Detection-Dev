clear;
close all;

mdl_path = fullfile('ica_models_1em9','ica_17_3e0da4ec9afa2c933836178e4cf50b3a.mat');
%mdl_path = fullfile('ica_models_1em9','ica_17_2959536c5e5f0c931ef1365d05a0eed3.mat');
mdl_path = fullfile('ica_models_1em9','ica_19_b7d23f1924ea919bc6a3620b473a79bc.mat');
%mdl_path = fullfile('ica_models_1em9','ica_35_00d9cf82b805dd3874881c685ccdb0f0.mat');

%mdl_path = fullfile('ica_models_1em9_std','ica_21_cc17ad63a1cbbc13fa2dc4ea622299e5.mat');


mdl_data = load(mdl_path);

mdl = mdl_data.ica_mdl;

load('img_set_1em9.mat');
img_set = img_set.stack_by({'passband'});

% vidObj = VideoWriter('pca1.mp4','MPEG-4');
% vidObj.FrameRate = 1;
% vidObj.Quality = 100;
% open(vidObj);

figure(101)
set(gcf,'Color','white')
tile_size = [2,3];
t1 = tiledlayout(tile_size(1),tile_size(2));
t1.Padding = 'compact';
t1.TileSpacing = 'compact';
tile_2d = @(i,j) sub2ind(fliplr(tile_size),j,i);

% img_set.images = img_set.images(randperm(numel(img_set.images)));

label_file_name = 'planet_labels_1em9_fixed.mat';
if exist(label_file_name,'file')
    load(label_file_name)
else
    planet_labels = [];
end
for i0 = 1:numel(img_set.images)

    disp([num2str(i0) ' of ' num2str(numel(img_set.images))])

    if ~isempty(planet_labels)&&any(ismember({img_set.images(i0).meta.file_name},{planet_labels.file_name}))
        disp([img_set.images(i0).meta(1).file_name, ' found, skipping.' ]);
        continue;
    end


    img_sample = img_set.images(i0).data_roi;
    img_size = size(img_sample);
    %plot the original images
    nexttile(tile_2d(1,1))
    imagesc(img_sample(:,:,1))
    colorbar;
    title_str = img_set.images(i0).meta(1).file_name(8:end-5);
    title(title_str,'Interpreter','none');

    nexttile(tile_2d(2,1))
    imagesc(img_sample(:,:,2))
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


     %reci1 = tw*scores;
    reci1 = reci1_2;

    reci1 = reshape(reci1,img_size);

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
    res1  = img_sample(:,:,1) - reci1(:,:,1);
    mean(abs(res1(:)))
    res1 = imfilter(res1,k2);
    imagesc(ax1,res1)
    colorbar;

    title(title_str);
    ax1.UserData = img_set.images(i0).meta(1).file_name;
    res2  = img_sample(:,:,2) - reci1(:,:,2);
    res2 = imfilter(res2,k2);
    ax2 = nexttile(tile_2d(2,3));
    cla(ax2)
    %store file associated with axes for labelling
    imagesc(ax2,res2)
    colorbar;
    title(title_str);
    drawnow();
    ax2.UserData = img_set.images(i0).meta(2).file_name;


    labelsi1 = label_planets(gcf);
    %labelsi1 = [];
    pause(1)

    for i2 = 1:numel(labelsi1)
        i_match = contains({img_set.images(i0).meta.file_name},labelsi1(i2).file_name);
    end

    planet_labels = cat(1,planet_labels,labelsi1);
    %         currFrame = getframe(gcf);
    %         writeVideo(vidObj,currFrame);

end
save(label_file_name,'planet_labels');
