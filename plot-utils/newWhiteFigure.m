function fig = newWhiteFigure(name)
% newWhiteFigure 白背景の Figure を作成する（ダークモード時の視認性向上）
fig = figure('Name', name, 'NumberTitle', 'off', 'Color', 'w');
end
