% setupPaths DC モータ教材用の simulink-utils / plot-utils を MATLAB パスに追加する
%
% Live Script は一時フォルダから実行されるため、mfilename ではなく
% which('DCMotor_Modeling_Lecture') で保存先のパスを特定する。

lectureFile = which('DCMotor_Modeling_Lecture');
if isempty(lectureFile)
    here = pwd;
    for k = 1:10
        cand = fullfile(here, 'DCMotor_Modeling_Lecture.m');
        if exist(cand, 'file')
            lectureFile = cand;
            break;
        end
        parent = fileparts(here);
        if isequal(parent, here)
            break;
        end
        here = parent;
    end
end

if isempty(lectureFile)
    error('DCMotor:PathNotFound', ...
        ['教材ファイル DCMotor_Modeling_Lecture.m が見つかりません。\n' ...
         'MATLAB の Current Folder を study-dynamics-matlab-dcmotor フォルダに設定してから再実行してください。']);
end

utilsDir = fullfile(fileparts(lectureFile), 'simulink-utils');
plotDir = fullfile(fileparts(lectureFile), 'plot-utils');
if ~exist(utilsDir, 'dir')
    error('DCMotor:UtilsNotFound', ...
        'simulink-utils フォルダが見つかりません: %s', utilsDir);
end
if ~exist(plotDir, 'dir')
    error('DCMotor:PlotUtilsNotFound', ...
        'plot-utils フォルダが見つかりません: %s', plotDir);
end

addpath(utilsDir);
addpath(plotDir);
