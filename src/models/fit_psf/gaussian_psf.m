function [y] = gaussian_psf(x,Xg,Yg)
%GAUSSIAN_PSF Summary of this function goes here
%   Detailed explanation goes here

            %https://math.stackexchange.com/questions/426150/what-is-the-general-equation-of-the-ellipse-that-is-not-in-the-origin-and-rotate
%             m_dist = sqrt((Xgc*cos(o) + Ygc*sin(o)).^2*a^(-2) + (Xgc*sin(o) - Ygc*cos(o)).^2*b^(-2));
%             disk = s*exp(m_dist);
A = x(1);
x0 = x(2);
y0 = x(3);
sigma = x(4);

r = sqrt((Xg - x0).^2 + (Yg - y0).^2);
y = A*exp(-(r.^2/sigma));

end

