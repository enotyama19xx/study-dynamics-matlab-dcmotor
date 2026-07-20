function fig = newWhiteFigure(name)
% newWhiteFigure  白背景・ライトテーマの Figure を作成する

fig = figure('Name', name, 'NumberTitle', 'off', 'Color', 'w');
if isprop(fig, 'Theme')
    fig.Theme = 'light';
else
    try
        theme(fig, 'light');
    catch
    end
end
end
