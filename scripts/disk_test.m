mas_per_pixel = 21.85;

nx = 67;
ny = 67;
img = zeros(ny,nx);
xc = (nx-1)/2;
yc = (ny-1)/2;

[Xg,Yg] = meshgrid(1:nx,1:ny);

a = rand;
b = rand;

I = -sqrt(a*(Xg - xc).^2 + b*(Yg - yc).^2);

% o = pi/4;
o = randn();

Xgc = Xg - xc;
Ygc = Yg - yc;

tic
m_dist = sqrt(a*(Xgc*cos(o) + Ygc*sin(o)).^2 + b*(Xgc*sin(o) - Ygc*cos(o)).^2);
toc
r_mas = mas_per_pixel*sqrt(Xgc.^2 + Ygc.^2);

p = [-1 0 0];
% disk = polyval(p,r_dist);
disk = exp(polyval(p,m_dist)/10);


figure;
imagesc(I)

figure;
imagesc(disk )

load('release1_data.mat');
d1 = release1_data;
tdata = d1.cal.transmission.data;

trans_sim = interp1(tdata(1,:),tdata(2,:),r_mas);
trans_sim(isnan(trans_sim)) = 1;

figure;
imagesc(trans_sim)

disk = disk.*trans_sim;
figure;
imagesc(disk)

img1 = d1.images(1).data;
figure;
subplot(2,1,1)
imagesc(img1);
subplot(2,1,2)
imagesc(trans_sim);