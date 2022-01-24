clear;
load('planet_checks.mat')
load('planet_labels.mat')
planet_checks = planet_checks';
planet_checks = planet_checks(:);
i_del = find([planet_checks.button] ~= 32);
fdel = {planet_checks(i_del).file_name};


plabel_names = {planet_labels.file_name};
i_pdel = ismember(plabel_names ,fdel);

planet_labels(i_pdel) = [];

save('planet_labels.mat','planet_labels');
