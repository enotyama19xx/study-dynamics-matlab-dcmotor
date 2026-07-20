% --- 単位帰還フィードバックのブロック線図（第3章冒頭・図A） ---
%
% 構成：r → Σ → C(s) → G(s) → y、y を Σ へ負帰還
% 出力：unity_feedback.png（本スクリプトと同じフォルダ）
%
% 依存：Python matplotlib、draw_unity_feedback.py

mpl = py.importlib.import_module('matplotlib');
mpl.use('Agg');

scriptFile = which('plotBlockDiagram_UnityFeedback');
if isempty(scriptFile)
    here = pwd;
    for k = 1:10
        candidates = {
            fullfile(here, 'plotBlockDiagram_UnityFeedback.m')
            fullfile(here, 'lecture-diagrams', 'plotBlockDiagram_UnityFeedback.m')
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
    error(['plotBlockDiagram_UnityFeedback.m が見つかりません。', ...
        'Current Folder を study-dynamics-matlab-dcmotor に設定するか、', ...
        'addpath(''lecture-diagrams'') してから再実行してください。']);
end

scriptDir = fileparts(scriptFile);
drawPy = fullfile(scriptDir, 'draw_unity_feedback.py');
if ~exist(drawPy, 'file')
    error('draw_unity_feedback.py が見つかりません: %s', drawPy);
end

scriptDirPy = strrep(scriptDir, '\', '/');
outPng = fullfile(scriptDir, 'unity_feedback.png');
outPngPy = strrep(outPng, '\', '/');

pyCode = sprintf([ ...
    'import sys\n' ...
    'sys.path.insert(0, r"%s")\n' ...
    'from draw_unity_feedback import draw\n' ...
    'draw(r"%s")\n'], scriptDirPy, outPngPy);
py.run(pyCode);

disp(['ブロック線図を ', outPng, ' として保存しました。']);
