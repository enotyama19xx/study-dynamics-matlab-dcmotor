function applyWhiteFigureStyle(fig)
% applyWhiteFigureStyle Figure と Axes を白背景・黒目盛りに設定する
if nargin < 1 || isempty(fig)
    fig = gcf;
end
set(fig, 'Color', 'w');
ax = findall(fig, 'Type', 'axes');
for k = 1:numel(ax)
    set(ax(k), 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
end
end
