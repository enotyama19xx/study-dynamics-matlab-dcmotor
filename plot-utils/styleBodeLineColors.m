function styleBodeLineColors(fig, colors, lineWidth)
% styleBodeLineColors  bodeplot 後の各系の線色・線幅を設定する
%
% colors    : n×3 行列、または 1×n の RGB セル配列
% lineWidth : 省略時 1.5

if nargin < 3 || isempty(lineWidth)
    lineWidth = 1.5;
end

if iscell(colors)
    colorList = colors;
else
    colorList = mat2cell(colors, ones(size(colors, 1), 1), 3);
end

axList = findobj(fig, 'Type', 'axes');
axList = axList(~strcmp({axList.Tag}, 'legend'));
for k = 1:numel(axList)
    lines = findobj(axList(k), 'Type', 'line');
    lines = flip(lines);
    for i = 1:min(numel(lines), numel(colorList))
        set(lines(i), 'Color', colorList{i}, 'LineWidth', lineWidth);
    end
end
end
