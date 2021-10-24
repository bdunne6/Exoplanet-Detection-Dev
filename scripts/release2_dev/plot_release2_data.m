load('release2_data.mat')

d1 = release2_data;

figure;
psf1 = d1.cal.psf.data(:,:,1);
imagesc(psf1)

figure;
tdata = d1.cal.transmission.data;
plot(tdata(1,:),tdata(2,:));

imgs = d1.images;
figure(101);
for i1 = 1:numel(imgs)
%     nexttile()
    imagesc(imgs(i1).data);
%     [~,file_name,ext] = fileparts(imgs(i1).file_path);
%     title(file_name,'Interpreter','none')
pause(0.2)
end



% t = tiledlayout(5,6);
% t.TileSpacing = 'compact';
% t.Padding = 'compact';
% for i1 = 1:numel(imgs)
%     nexttile()
%     imagesc(imgs(i1).data);
%     [~,file_name,ext] = fileparts(imgs(i1).file_path);
%     title(file_name,'Interpreter','none')
% end