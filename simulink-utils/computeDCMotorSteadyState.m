function [i_ss, omega_ss] = computeDCMotorSteadyState(V0, R, B, Kt, Ke, TL)
% computeDCMotorSteadyState 定常状態のアーマチュア電流と角速度を計算する
%
% [i_ss, omega_ss] = computeDCMotorSteadyState(V0, R, B, Kt, Ke, TL)
%
% 第 1 章の電気・機械式を di/dt=0, domega/dt=0 として解いた結果。

if nargin < 6
    TL = 0;
end

den = Ke * Kt + R * B;
omega_ss = (V0 * Kt - R * TL) / den;
i_ss = (B * omega_ss + TL) / Kt;
end
