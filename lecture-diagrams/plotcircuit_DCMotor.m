% --- DCモータ等価回路（電気側）描画スクリプト ---
%
% 直列構成：電源 V → 抵抗 R → インダクタ L → 逆起電力 K_e ω
% 逆起電力は東側（右縦枝）に配置（北側/top 直列に並べない）
% 出力：dcmotor_elec_circuit.png（本スクリプトと同じフォルダ）
%
% Live Editor から実行すると mfilename('fullpath') は Temp 配下を指すため、
% which / 親ディレクトリ探索で実ファイルの場所を特定する。

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

% --- 回路要素（V → R → L → K_e ω、逆起電力は東側 .down()） ---
d.add(elm.SourceV().up().label('V'));
d.add(elm.Resistor().right().label('R'));
d.add(elm.Inductor().right().label('L'));
d.add(elm.SourceControlledV().reverse().down().label('K_e ω'));
d.add(elm.Line().left());
d.add(elm.Line().left());

% --- 保存先：スクリプト本体の場所（Temp ではない） ---
scriptFile = which('plotcircuit_DCMotor');
if isempty(scriptFile)
    here = pwd;
    for k = 1:10
        candidates = {
            fullfile(here, 'plotcircuit_DCMotor.m')
            fullfile(here, 'lecture-diagrams', 'plotcircuit_DCMotor.m')
        };
        for c = 1:numel(candidates)
            if exist(candidates{c}, 'file')
                scriptFile = candidates{c};
                break;
            end
        end
        if ~isempty(scriptFile)
            break;
        end
        parent = fileparts(here);
        if isequal(parent, here)
            break;
        end
        here = parent;
    end
end
if isempty(scriptFile)
    error(['plotcircuit_DCMotor.m が見つかりません。', ...
        'Current Folder を study-dynamics-matlab-dcmotor に設定するか、', ...
        'addpath(''lecture-diagrams'') してから再実行してください。']);
end
scriptDir = fileparts(scriptFile);
filename = fullfile(scriptDir, 'dcmotor_elec_circuit.png');
filenamePy = strrep(filename, '\', '/');
d.save(filenamePy, pyargs('transparent', false));

disp(['回路図を ', filename, ' として保存しました。']);
