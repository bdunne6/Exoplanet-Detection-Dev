function [labels] = label_planets(figure_in)
%LABEL_PLANETS Summary of this function goes here
%   Detailed explanation goes here

figure(figure_in);

button = 1;
i0 = 0;
labels = [];
while button ~= 32   % read ginputs until a mouse right-button occurs
    i0 = i0 +1;
    [x,y,button] = ginput(1);

    if button == 32
        break;
    end

    %     if button == 1
    %         continue;
    %     end

    labels(i0).x = x;
    labels(i0).y = y;
    labels(i0).button = button;

    ax = gca;
    labels(i0).file_name = ax.UserData;

    hold on;
    plot(gca,labels(i0).x,labels(i0).y,'.r');

end

labels = labels(:);
hold off;
end