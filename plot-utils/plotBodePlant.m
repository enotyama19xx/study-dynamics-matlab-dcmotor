function h = plotBodePlant(G, figName, plotTitle)
% plotBodePlant  プラント G(s) のみのボード線図（白背景）
%
% h = plotBodePlant(G, figName, plotTitle)

if nargin < 2 || isempty(figName)
    figName = 'Bode: G(s)';
end

fig = newWhiteFigure(figName);
opts = bodeWhiteOptions();
h = bodeplot(fig, G, opts);
styleBodeLineColors(fig, [0.8500 0.3250 0.0980], 1.5);
legend('G(s)', 'Location', 'best');
if nargin >= 3 && ~isempty(plotTitle)
    sgtitle(plotTitle, 'Color', 'k');
end
applyWhiteFigureStyle(fig);
end
