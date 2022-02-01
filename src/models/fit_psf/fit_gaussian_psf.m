function [s_out] = fit_gaussian_psf(psf,fixed_sigma)
%FIT_GAUSSIAN_PSF Summary of this function goes here
%   Detailed explanation goes here


yr = 1:size(psf,1);
xr = 1:size(psf,2);

[Xg,Yg] = meshgrid(xr,yr);

xy_c = [mean(xr),mean(yr)];
x0 = [max(psf(:)),xy_c(1),xy_c(2),min(psf(:)),3];




if ~exist('fixed_sigma','var')
    fixed_sigma = 0;
end

if fixed_sigma&&numel(x0)>4
    x0(5) = [];
end

g.Xg = Xg;
g.Yg = Yg;
g.fixed_sigma = fixed_sigma;

opts = statset('nlinfit');
opts.RobustWgtFun = 'huber';
[f.x_opt,f.R,f.J,f.covb,f.mse] = nlinfit(g,psf(:),@model_fun,x0,opts);
f.ci = nlparci(f.x_opt,f.R,'covar',f.covb);

if fixed_sigma
    x_opt = [f.x_opt,fixed_sigma];
    ci = [f.ci;0,0];
else
    ci = f.ci;
    x_opt = f.x_opt;
end

[y_opt] = gaussian_psf(x_opt,Xg,Yg);

s_out.nlinfit = f;
s_out.x_opt = x_opt;
s_out.y_opt = y_opt;
s_out.grid = g;
s_out.ci = ci;
end
function y = model_fun(x,g)
if g.fixed_sigma&&(numel(x) == 4)
    x = [x,g.fixed_sigma];
end
y = gaussian_psf(x,g.Xg,g.Yg);
y = y(:);
end
