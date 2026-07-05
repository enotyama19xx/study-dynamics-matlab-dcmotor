function plotMotorResponse(t, v, omega, figName, layoutTitle, vTitle, omegaTitle)
% plotMotorResponse 入力電圧と角速度を上下2段でプロット（白背景）
fig = newWhiteFigure(figName);
tl = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile;
plot(ax1, t, v, 'b-', 'LineWidth', 1.5);
grid(ax1, 'on');
ylabel(ax1, '電圧 v(t) [V]');
title(ax1, vTitle);
ax2 = nexttile;
plot(ax2, t, omega, 'r-', 'LineWidth', 1.5);
grid(ax2, 'on');
ylabel(ax2, '角速度 \omega(t) [rad/s]');
xlabel(ax2, '時間 t [s]');
title(ax2, omegaTitle);
title(tl, layoutTitle);
linkaxes([ax1, ax2], 'x');
applyWhiteFigureStyle(fig);
end
