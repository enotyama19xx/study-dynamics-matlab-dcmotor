function opts = bodeWhiteOptions()
% bodeWhiteOptions  白背景・黒文字の bodeplot 用オプション（テーマ非依存）

opts = bodeoptions;
opts.Grid = 'on';
opts.GridColor = [0.75 0.75 0.75];

black = [0 0 0];
opts.Title.String = '';
opts.Title.Color = black;
opts.XLabel.Color = black;
opts.YLabel.String = {'ゲイン', '位相'};
opts.YLabel.Color = black;
opts.TickLabel.Color = black;
opts.InputLabels.Color = black;
opts.OutputLabels.Color = black;
end
