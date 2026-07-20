function prepareDCMotorSpeedModel(modelName, Kp, Ki, omegaRef)
% prepareDCMotorSpeedModel  DCMotor_Speed.slx 実行前にワークスペースと Step を設定
%
% prepareDCMotorSpeedModel(modelName, Kp, Ki, omegaRef)
%
% modelName : 例 'DCMotor_Speed'
% Kp, Ki    : 速度 PI ゲイン
% omegaRef  : 角速度指令 Step の Final value [rad/s]

if ~modelFileExists(modelName)
    error('DCMotor:ModelNotFound', 'モデル "%s.slx" が見つかりません。', modelName);
end

assignin('base', 'Kp_speed', Kp);
assignin('base', 'Ki_speed', Ki);
assignin('base', 'omega_ss', omegaRef);

load_system(modelName);
stepBlk = findStepBlock(modelName);
afterVal = num2str(omegaRef, 16);

try
    set_param(stepBlk, 'Time', '0', 'Before', '0', 'After', afterVal);
catch
    set_param(stepBlk, 'StepTime', '0', 'InitialValue', '0', 'FinalValue', afterVal);
end
end

function exists = modelFileExists(modelName)
exists = exist([modelName '.slx'], 'file') == 4 || exist([modelName '.mdl'], 'file') == 4;
end

function stepBlk = findStepBlock(modelName)
candidates = {
    [modelName '/Step']
    [modelName '/Step1']
    [modelName '/omega_ref']
    };
for k = 1:numel(candidates)
    if blockExists(candidates{k})
        stepBlk = candidates{k};
        return;
    end
end
blocks = find_system(modelName, 'BlockType', 'Step');
if isempty(blocks)
    error('DCMotor:StepNotFound', ...
        ['モデル "%s" に Step ブロックが見つかりません。', ...
         ' ω_ref 用 Step を追加するか、ブロック名を Step にしてください。'], modelName);
end
stepBlk = blocks{1};
end

function ok = blockExists(blockPath)
try
    get_param(blockPath, 'BlockType');
    ok = true;
catch
    ok = false;
end
end
