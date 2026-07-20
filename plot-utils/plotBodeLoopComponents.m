function h = plotBodeLoopComponents(C, G, figName, plotTitle)
% plotBodeLoopComponents  C(s), G(s), L(s)=C(s)G(s) を同一ボード線図に描画
%
% h = plotBodeLoopComponents(C, G, figName, plotTitle)

if nargin < 3 || isempty(figName)
    figName = 'Bode: C, G, L';
end

L = C * G;
fig = newWhiteFigure(figName);
opts = bodeWhiteOptions();
h = bodeplot(fig, C, G, L, opts);
styleBodeLineColors(fig, { ...
    [0 0.4470 0.7410], ...
    [0.8500 0.3250 0.0980], ...
    [0 0 0]}, 1.5);
legend('C(s)', 'G(s)', 'L(s)=C(s)G(s)', 'Location', 'best');
if nargin >= 4 && ~isempty(plotTitle)
    sgtitle(plotTitle, 'Color', 'k');
end
applyWhiteFigureStyle(fig);
end
