% --- DCモータプラントのブロック線図（3.1節） ---
%
% V -> 1/(Ls+R) -> i -> K_t -> T_m -> 1/(Js+B) -> ω、逆起電力 K_e 負帰還
% 出力：plant_block_diagram.png（本スクリプトと同じフォルダ）
%
% 依存：Python matplotlib、draw_plant_block_diagram.py

mpl = py.importlib.import_module('matplotlib');
mpl.use('Agg');

scriptFile = which('plotBlockDiagram_Plant');
if isempty(scriptFile)
    here = pwd;
    for k = 1:10
        candidates = {
            fullfile(here, 'plotBlockDiagram_Plant.m')
            fullfile(here, 'lecture-diagrams', 'plotBlockDiagram_Plant.m')
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
    error(['plotBlockDiagram_Plant.m が見つかりません。', ...
        'Current Folder を study-dynamics-matlab-dcmotor に設定するか、', ...
        'addpath(''lecture-diagrams'') してから再実行してください。']);
end

scriptDir = fileparts(scriptFile);
drawPy = fullfile(scriptDir, 'draw_plant_block_diagram.py');
if ~exist(drawPy, 'file')
    error('draw_plant_block_diagram.py が見つかりません: %s', drawPy);
end

scriptDirPy = strrep(scriptDir, '\', '/');
outPng = fullfile(scriptDir, 'plant_block_diagram.png');
outPngPy = strrep(outPng, '\', '/');

pyCode = sprintf([ ...
    'import sys\n' ...
    'sys.path.insert(0, r"%s")\n' ...
    'from draw_plant_block_diagram import draw\n' ...
    'draw(r"%s")\n'], scriptDirPy, outPngPy);
py.run(pyCode);

disp(['ブロック線図を ', outPng, ' として保存しました。']);
