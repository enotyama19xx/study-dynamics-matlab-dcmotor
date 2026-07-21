% --- 直線運動の模式図（1.5節） ---
%
% 平面上的ブロック：外力 F、質量 m、速度 v、粘性摩擦 c·v、逆方向の力 F_L
% 出力：linear_motion.png（本スクリプトと同じフォルダ）
%
% 依存：Python matplotlib、draw_linear_motion.py

mpl = py.importlib.import_module('matplotlib');
mpl.use('Agg');

scriptFile = which('plotLinearMotion');
if isempty(scriptFile)
    here = pwd;
    for k = 1:10
        candidates = {
            fullfile(here, 'plotLinearMotion.m')
            fullfile(here, 'lecture-diagrams', 'plotLinearMotion.m')
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
    error(['plotLinearMotion.m が見つかりません。', ...
        'Current Folder を study-dynamics-matlab-dcmotor に設定するか、', ...
        'addpath(''lecture-diagrams'') してから再実行してください。']);
end

scriptDir = fileparts(scriptFile);
drawPy = fullfile(scriptDir, 'draw_linear_motion.py');
if ~exist(drawPy, 'file')
    error('draw_linear_motion.py が見つかりません: %s', drawPy);
end

scriptDirPy = strrep(scriptDir, '\', '/');
outPng = fullfile(scriptDir, 'linear_motion.png');
outPngPy = strrep(outPng, '\', '/');

pyCode = sprintf([ ...
    'import sys\n' ...
    'sys.path.insert(0, r"%s")\n' ...
    'from draw_linear_motion import draw\n' ...
    'draw(r"%s")\n'], scriptDirPy, outPngPy);
py.run(pyCode);

disp(['模式図を ', outPng, ' として保存しました。']);
