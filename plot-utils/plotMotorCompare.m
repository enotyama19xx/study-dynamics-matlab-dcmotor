function plotMotorCompare(t1, omega1, t2, omega2, figName, layoutTitle, label1, label2)
% plotMotorCompare 2 組の角速度応答を 1 枚に重ね描画（白背景）
fig = newWhiteFigure(figName);
plot(t1, omega1, 'b-', 'LineWidth', 1.5);
hold on;
plot(t2, omega2, 'r--', 'LineWidth', 1.5);
grid on;
xlabel('Time t [s]');
ylabel('Angular velocity \omega(t) [rad/s]');
title(layoutTitle);
legend({label1, label2}, 'Location', 'best');
applyWhiteFigureStyle(fig);
end
