function [rgb_out] = multi_spectral_to_rgb(image_stack,hue_sat,color_scale)
%MULTI_SPECTRAL_TO_RGB Summary of this function goes here
%   Detailed explanation goes here


img_stack_v = rescale(image_stack,0,1,'InputMin',color_scale(1),'InputMax',color_scale(2));


img_size = [size(image_stack,1),size(image_stack,2)];

rgb_out = zeros(img_size(1),img_size(2),3);
for i1 = 1:size(image_stack,3)
    hsv_i1 = cat(3,hue_sat(i1,1)*ones(img_size),hue_sat(i1,2)*ones(img_size),img_stack_v(:,:,i1));
    rgb_out = rgb_out + hsv2rgb(hsv_i1);
end

% rgb_out = uint8(rgb_out);

end

