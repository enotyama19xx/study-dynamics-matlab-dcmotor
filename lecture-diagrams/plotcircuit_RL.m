% --- RL回路図描画スクリプト (エラー対策版) ---

% 【重要】GUI（ウィンドウ）を使わず画像生成のみを行う設定
mpl = py.importlib.import_module('matplotlib');
mpl.use('Agg');

% Pythonのschemdrawモジュールを読み込む
try
    sd = py.importlib.import_module('schemdraw');
    elm = py.importlib.import_module('schemdraw.elements');
catch ME
    error('schemdrawがインポートできません。Python環境とpip installが完了しているか確認してください。');
end

% 描画オブジェクトの作成
d = sd.Drawing();

% --- 回路要素の追加（直列：電圧源 V + 抵抗 R + インダクタ L） ---
d.add(elm.SourceV().up().label('V'));
d.add(elm.Resistor().right().label('R'));
d.add(elm.Inductor().label('L'));
d.add(elm.Line().down());
d.add(elm.Line().left());
d.add(elm.Line().left());

% --- 保存と終了（このスクリプトと同じフォルダに出力） ---
scriptDir = fileparts(mfilename('fullpath'));
filename = fullfile(scriptDir, 'rl_circuit.png');
d.save(filename, pyargs('transparent', false));

disp(['回路図を ', filename, ' として保存しました。']);
