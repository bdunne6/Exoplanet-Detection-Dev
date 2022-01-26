clear;
close all;

label_file_name = 'planet_labels_1em9.mat';
% mdl_path = fullfile('ica_models1','ica_17_ec2012725779cfc8a01eb63c55e867a7.mat');
mdl_path = fullfile('ica_models_1em9','ica_19_b7d23f1924ea919bc6a3620b473a79bc.mat');
%mdl_path = fullfile('ica_models_1em9','ica_35_00d9cf82b805dd3874881c685ccdb0f0.mat');
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


load(label_file_name);
if exist('planet_checks.mat','file')
    load('planet_checks.mat')
else
    planet_checks = [];
end
for i0 = 1:numel(img_set.images)

    disp([num2str(i0) ' of ' num2str(numel(img_set.images))])

    if ~isempty(planet_checks)&&any(ismember({img_set.images(i0).meta.file_name},{planet_checks.file_name}))
        disp([img_set.images(i0).meta(1).file_name, ' found, skipping.' ]);
        continue;
    end


    labels_1 = find(ismember({planet_labels.file_name},img_set.images(i0).meta(1).file_name));
    labels_1 = planet_labels(labels_1);
    labels_1([labels_1.button] <= 2);

    labels_2 = find(ismember({planet_labels.file_name},img_set.images(i0).meta(2).file_name));
    labels_2 = planet_labels(labels_2);
    labels_2([labels_2.button] <= 2);

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


    %reci1 = tw*scores;
    %reci1 = reshape(reci1,img_size);
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
    res1  = img_sample(:,:,1) - reci1_2(:,:,1);
    res1 = imfilter(res1,k2);
    imagesc(ax1,res1)
    hold on;
    plot([labels_1.x],[labels_1.y],'.r')
    colorbar;

    title(title_str);
    ax1.UserData = img_set.images(i0).meta(1).file_name;
    res2  = img_sample(:,:,2) - reci1_2(:,:,2);
    res2 = imfilter(res2,k2);
    ax2 = nexttile(tile_2d(2,3));
    cla(ax2)
    %store file associated with axes for labelling
    imagesc(ax2,res2)
    hold on;
    plot([labels_2.x],[labels_2.y],'.r')
    colorbar;
    title(title_str);
    drawnow();
    ax2.UserData = img_set.images(i0).meta(2).file_name;


    %     labelsi1 = label_planets(gcf);
    %     pause(1)
    %
    %     for i2 = 1:numel(labelsi1)
    %         i_match = contains({img_set.images(i0).meta.file_name},labelsi1(i2).file_name);
    %     end

    %set(gcf,'KeyPressFcn',@key_handler);
    k = waitforbuttonpress;
    % 28 leftarrow
    % 29 rightarrow
    % 30 uparrow
    % 31 downarrow
    keyi0 = double(get(gcf,'CurrentCharacter'));


    %check_key = input('space for good, enter for delete:');
    checksi1(1).button = deal(keyi0);
    checksi1(2).button = deal(keyi0);

    checksi1(1).file_name = img_set.images(i0).meta(1).file_name;
    checksi1(2).file_name = img_set.images(i0).meta(2).file_name;

    planet_checks = cat(1,planet_checks,checksi1);
    %         currFrame = getframe(gcf);
    %         writeVideo(vidObj,currFrame);

end
save('planet_checks.mat','planet_checks');

% function key = key_handler(src,event)
% key = event.key;
% disp(key);
% assignin('base','keyi0',key);
% end
