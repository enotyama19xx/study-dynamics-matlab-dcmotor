function applyWhiteFigureStyle(fig)
% applyWhiteFigureStyle  Figure / Axes / テキストを白背景・黒文字に統一する

if nargin < 1 || isempty(fig)
    fig = gcf;
end

if isprop(fig, 'Theme')
    fig.Theme = 'light';
else
    try
        theme(fig, 'light');
    catch
    end
end

set(fig, 'Color', 'w');

charts = findall(fig, '-regexp', 'Type', 'BodePlot|bodeplot');
for k = 1:numel(charts)
    if isprop(charts(k), 'BackgroundColor')
        charts(k).BackgroundColor = [1 1 1];
    end
    if isprop(charts(k), 'Title') && isprop(charts(k).Title, 'String')
        charts(k).Title.String = '';
    end
end

ax = findall(fig, 'Type', 'axes');
for k = 1:numel(ax)
    if strcmp(get(ax(k), 'Tag'), 'legend')
        continue;
    end
    set(ax(k), ...
        'Color', 'w', ...
        'XColor', 'k', ...
        'YColor', 'k', ...
        'GridColor', [0.15 0.15 0.15], ...
        'GridAlpha', 0.25, ...
        'MinorGridColor', [0.15 0.15 0.15], ...
        'MinorGridAlpha', 0.12);
    setLabelColor(get(ax(k), 'Title'), 'k');
    setLabelColor(get(ax(k), 'XLabel'), 'k');
    setLabelColor(get(ax(k), 'YLabel'), 'k');
end

txts = findall(fig, 'Type', 'text');
for k = 1:numel(txts)
    set(txts(k), 'Color', 'k');
end

legs = findall(fig, 'Type', 'Legend');
for k = 1:numel(legs)
    set(legs(k), 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.5 0.5 0.5]);
end
end

function setLabelColor(label, color)
if isempty(label)
    return;
end
if isobject(label) && ~isvalid(label)
    return;
end
try
    set(label, 'Color', color);
catch
end
end
