nx = 67;
ny = 67;
img = zeros(ny,nx);
xc = 50;
yc = 50;

[Xg,Yg] = meshgrid(1:nx,1:ny);

a = rand;
b = rand;

I = -sqrt(a*(Xg - xc).^2 + b*(Yg - yc).^2);

% o = pi/4;
o = randn();

Xgc = Xg - xc;
Ygc = Yg - yc;

tic
r_dist = sqrt(a*(Xgc*cos(o) + Ygc*sin(o)).^2 + b*(Xgc*sin(o) - Ygc*cos(o)).^2);
toc

p = [-1 0 0];
% disk = polyval(p,r_dist);
disk = exp(-r_dist/40);

figure;
imagesc(I)

figure;
imagesc(disk )

load('release1_data.mat');
tdata = d1.cal.transmission.data;
mas_per_pixel = 21.85;

img1 = d1.images(1).data;
