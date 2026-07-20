% --- カスケード速度・電流フィードバックのブロック線図（3.4節） ---
%
% 構成：ω_ref → C_speed → i_ref → C_curr → V → 1/(Ls+R) → i → K_t/(Js+B) → ω
%       外側：ω 負帰還、内側：i 負帰還、逆起電力 K_e を外乱として Σ_V へ
% 出力：cascade_block_diagram.png（本スクリプトと同じフォルダ）
%
% 依存：Python matplotlib、draw_cascade_feedback.py

mpl = py.importlib.import_module('matplotlib');
mpl.use('Agg');

scriptFile = which('plotBlockDiagram_Cascade');
if isempty(scriptFile)
    here = pwd;
    for k = 1:10
        candidates = {
            fullfile(here, 'plotBlockDiagram_Cascade.m')
            fullfile(here, 'lecture-diagrams', 'plotBlockDiagram_Cascade.m')
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
    error(['plotBlockDiagram_Cascade.m が見つかりません。', ...
        'Current Folder を study-dynamics-matlab-dcmotor に設定するか、', ...
        'addpath(''lecture-diagrams'') してから再実行してください。']);
end

scriptDir = fileparts(scriptFile);
drawPy = fullfile(scriptDir, 'draw_cascade_feedback.py');
if ~exist(drawPy, 'file')
    error('draw_cascade_feedback.py が見つかりません: %s', drawPy);
end

scriptDirPy = strrep(scriptDir, '\', '/');
outPng = fullfile(scriptDir, 'cascade_block_diagram.png');
outPngPy = strrep(outPng, '\', '/');

pyCode = sprintf([ ...
    'import sys\n' ...
    'sys.path.insert(0, r"%s")\n' ...
    'from draw_cascade_feedback import draw\n' ...
    'draw(r"%s")\n'], scriptDirPy, outPngPy);
py.run(pyCode);

disp(['ブロック線図を ', outPng, ' として保存しました。']);
