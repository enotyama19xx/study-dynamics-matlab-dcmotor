function [t, v, i, omega, ok] = simulateDCMotorModel(modelName, stopTime)
% simulateDCMotorModel DC モータ Simulink モデルを実行し時系列を取得する
%
% [t, v, i, omega, ok] = simulateDCMotorModel(modelName, stopTime)
%
% modelName : Simulink モデル名（例: 'DCMotor_Model'）
% stopTime  : シミュレーション終了時間 [s]
% t, v, i, omega : 時間・入力電圧・電流・角速度（失敗時は空）
% ok        : 成功時 true

t = [];
v = [];
i = [];
omega = [];
ok = false;

if ~modelFileExists(modelName)
    warning('Simulink:ModelNotFound', ...
        ['モデルファイル "%s.slx" がカレントフォルダにありません（現在: %s）。\n' ...
         ' 対処: Live Script と同じフォルダに保存するか、cd でそのフォルダに移動してください。'], ...
        modelName, pwd);
    return;
end

try
    simOut = sim(modelName, 'StopTime', num2str(stopTime));
    t = extractSimTime(simOut);
    v = extractSimSignal(simOut, {'v_sim', 'v_data'});
    i = extractSimSignal(simOut, {'i_sim', 'i_data'});
    omega = extractSimSignal(simOut, {'omega_sim', 'omega_data'});
    if isempty(v) && ~isempty(t)
        v = fallbackStepVoltage(t);
    end
    [t, v, i, omega] = alignSeries(t, v, i, omega);
    ok = true;
catch ME
    reportSimError(modelName, ME);
end
end

function exists = modelFileExists(modelName)
exists = exist([modelName '.slx'], 'file') == 4 || exist([modelName '.mdl'], 'file') == 4;
end

function t = extractSimTime(simOut)
t = [];
if isprop(simOut, 'tout') && ~isempty(simOut.tout)
    t = simOut.tout;
elseif evalin('base', 'exist(''t_sim'',''var'')')
    t = evalin('base', 't_sim');
end
t = unpackSeries(t);
end

function y = extractSimSignal(simOut, names)
y = [];
for k = 1:numel(names)
    name = names{k};
    if isprop(simOut, name) && ~isempty(simOut.(name))
        y = simOut.(name);
        break;
    end
    if isa(simOut, 'Simulink.SimulationOutput')
        try
            y = simOut.get(name);
            if ~isempty(y)
                break;
            end
        catch
        end
    end
    if isempty(y) && evalin('base', sprintf('exist(''%s'',''var'')', name))
        y = evalin('base', name);
        break;
    end
end
if isempty(y) && isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
    for k = 1:numel(names)
        try
            elem = simOut.logsout.getElement(names{k});
            if ~isempty(elem)
                ts = elem.Values;
                if isa(ts, 'timeseries')
                    y = ts.Data;
                    break;
                end
            end
        catch
        end
    end
end
y = unpackSeries(y);
end

function v = fallbackStepVoltage(t)
v = [];
if evalin('base', 'exist(''V0'',''var'')')
    V0 = evalin('base', 'V0');
    v = V0 * (t >= 0);
    warning('Simulink:VoltageFallback', ...
        'v_sim が見つかりませんでした。ワークスペースの V0 からステップ電圧を再構成しました。Step → To Workspace（v_sim）の設定を推奨します。');
end
end

function y = unpackSeries(x)
if isa(x, 'timeseries')
    y = x.Data;
elseif isstruct(x) && isfield(x, 'signals')
    y = x.signals.values;
elseif isnumeric(x)
    y = x;
else
    y = [];
end
y = squeeze(y(:));
end

function [t, v, i, omega] = alignSeries(t, v, i, omega)
if isempty(omega) || isempty(t)
    error('DCMotor:OutputMissing', ...
        '角速度 omega_sim（または omega_data）がワークスペースに出力されていません。');
end
if isempty(v)
    error('DCMotor:OutputMissing', ...
        '入力電圧 v_sim が見つかりません。Step 出力 → To Workspace（v_sim）を設定するか、1.9 節で V0 を定義してください。');
end
n = min([numel(t), numel(v), numel(omega)]);
if ~isempty(i)
    n = min(n, numel(i));
else
    i = nan(size(t));
end
t = t(1:n);
v = v(1:n);
i = i(1:n);
omega = omega(1:n);
end

function reportSimError(modelName, ME)
if strcmp(ME.identifier, 'DCMotor:OutputMissing')
    warning('Simulink:OutputMissing', ...
        ['モデル "%s" は実行されましたが、結果の読み取りに失敗しました。\n' ...
         ' 原因: %s\n' ...
         ' 対処: Step（入力電圧）→ To Workspace（v_sim）、Integrator（i, omega）→ To Workspace（i_sim, omega_sim）。\n' ...
         ' Save format = Array。Model Settings で Time にチェック（tout）。'], ...
        modelName, ME.message);
else
    warning('Simulink:SimFailed', ...
        ['Simulink モデル "%s" の実行中にエラーが発生しました。\n' ...
         ' 原因: %s\n' ...
         ' 対処: 1.9 節を先に実行し、Simulink でモデルを開いてエラーを確認してください。'], ...
        modelName, ME.message);
end
end
