clear; close all

load('planet_labels_1em9_final.mat');

x = nan(size(planet_labels));
y = nan(size(planet_labels));
for i1 = 1:numel(planet_labels)
    if ~isempty(planet_labels(i1).x)&~isempty(planet_labels(i1).y)
        x(i1) = planet_labels(i1).x;
        y(i1) = planet_labels(i1).y;
    end
end

% x = cat(1,planet_labels.x);
% y = cat(1,planet_labels.y);


i_bad = x<15|y<0|y>50;

figure;
plot(x,y,'.')
hold on;
plot(x(i_bad),y(i_bad),'.r')
% xlim([13,41])
% ylim([13,41])
set(gca, 'YDir','reverse')


planet_labels(i_bad) = [];

save('planet_labels_1em9_final.mat','planet_labels')