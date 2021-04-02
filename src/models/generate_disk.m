function [disk] = generate_disk(p,Xg,Yg,trans_sim)
%GENERATE_DISK Summary of this function goes here
%   Detailed explanation goes here

s = p(1);
a = p(2);
b = p(3);
o = p(4);
xc = p(5);
yc = p(6);
e_scale = p(7);
p_coeff = p(8:end);

% [ny,nx] = size(Xg);
% xc = (nx-1)/2;
% yc = (ny-1)/2;
Xgc = Xg - xc;
Ygc = Yg - yc;

%https://math.stackexchange.com/questions/426150/what-is-the-general-equation-of-the-ellipse-that-is-not-in-the-origin-and-rotate
m_dist = sqrt(a*(Xgc*cos(o) + Ygc*sin(o)).^2 + b*(Xgc*sin(o) - Ygc*cos(o)).^2);
%m_dist = sqrt((Xgc*cos(o) + Ygc*sin(o)).^2*a^(-2) + (Xgc*sin(o) - Ygc*cos(o)).^2*b^(-2));
%r_mas = mas_per_pixel*sqrt(Xgc.^2 + Ygc.^2);

%p_coeff = [-1 0 0];
% disk = polyval(p,r_dist);
disk = s*exp(polyval(p_coeff,m_dist)/e_scale);
disk = disk.*trans_sim;
end

