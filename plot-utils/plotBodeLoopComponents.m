function h = plotBodeLoopComponents(C, G, figName, plotTitle)
% plotBodeLoopComponents C(s), G(s), L(s)=C(s)G(s) を同一ボード線図に描画
%
% h = plotBodeLoopComponents(C, G, figName, plotTitle)
%
% C, G     : 伝達関数（tf, ss, zpk 等）
% figName  : Figure 名
% plotTitle: 全体タイトル（sgtitle、省略可）

if nargin < 3 || isempty(figName)
    figName = 'Bode: C, G, L';
end

L = C * G;
fig = newWhiteFigure(figName);
h = bodeplot(C, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5, ...
    G, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, ...
    L, 'Color', [0 0 0], 'LineStyle', '-', 'LineWidth', 1.5);
grid on;
legend('C(s)', 'G(s)', 'L(s)=C(s)G(s)', 'Location', 'best');
if nargin >= 4 && ~isempty(plotTitle)
    sgtitle(plotTitle);
end
applyWhiteFigureStyle(fig);
end
