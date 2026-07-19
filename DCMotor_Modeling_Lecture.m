%[text] # ブラシ付き DC モータのモデリング・ダイナミクス解析・制御
%[text] このファイルは MATLAB R2025b 以降のプレーンテキスト Live Code 形式（`.m`）です。Files パネルから 開く（テキストとして開くではない）と、Live Editor で解説・数式・コードが一体化した教材として表示されます。
%[text] 前提教材：RLC回路モデリング演習（study-dynamics-matlab）。GitHub URL は https://github.com/enotyama19xx/study-dynamics-matlab 。RL 回路の時定数、Simulink の Integrator 方式、ステップ応答の読み方などは復習程度で進めます。
%%
%[text] ## 1. モデリング・ダイナミクス（前教材との接続）
%[text] 本章では、前教材で学んだ RL 回路（1 階 ODE・時定数 $\\tau = L/R$）を出発点に、ブラシ付き DC モータを 電気系＋機械系の結合モデル として定式化します。第 2 章では手計算と Simulink（Integrator 方式・Simscape 方式）でダイナミクスを解析し、第 3 章で伝達関数に基づく速度制御設計へ進みます。
%%
%[text] ### 1.1 本教材の位置づけと学習目標
%[text] 前教材では、R → L → RL → RLC の順に回路をモデル化し、微分方程式と Simulink（Integrator 中心）による数値シミュレーションを学びました。本教材ではその延長として、モータの等価的な回路（等価回路）と 機械を結合した 2 変数（電流 $i$、角速度 $\\omega$）の連立微分方程式を扱います。
%[text] 学習目標は次のとおりです。
%[text] - ブラシ付き DC モータを RL 回路＋逆起電力＋機械系としてモデル化できること
%[text] - 電気方程式・トルク方程式から連立微分方程式を立て、各変数の時間変化を説明できること
%[text] - 手計算で定常値・過渡応答のイメージを把握できること
%[text] - Simulink（Integrator 方式・Simscape 方式）でダイナミクスをシミュレーションし、両者の波形が一致することを確認できること
%[text] - プラントの伝達関数をボード線図で直感的に読み取れること
%[text] - 一巡伝達関数を用いたループ整形法で速度制御器を設計し、Simulink で検証できること \
%[text] 本教材で扱わないこと： 前教材のように ode45 による MATLAB 数値積分は使いません。ダイナミクスの数値計算は Simulink に集約 します。
%%
%[text] ### 1.2 RL 回路の復習（電気側）
%[text] ![](text:image:612b)
%[text] 前教材 2.3 節（RL 回路）を思い出してください。直列 RL 回路にステップ電圧 $V\_0$ を印加したとき、キルヒホッフの電圧法則（KVL）より：
%[text] $v(t)=R\\,i(t)+L\\,\\frac{di(t)}{dt}${"editStyle":"visual"}
%[text] 整理すると 1 階線形常微分方程式：
%[text] $\\frac{di(t)}{dt}+\\frac{R}{L}\\,i(t)=\\frac{1}{L}\\,v(t)${"editStyle":"visual"}
%[text] 時定数 $\\tau\_{elec} = L/R$ \[$\\mathrm{s}$\] は「電流が定常値の約 63% まで立ち上がる目安の時間」です。ステップ入力 $v(t)=V\_0$（$i(0)=0$）では、定常電流 $i\_{ss} = V\_0/R$ に指数関数的に近づきます。
%[text] DC モータの等価回路も、抵抗 $R$ とインダクタンス $L$ を持つ RL 回路として捉えられます。ただし回転に伴い 逆起電力（バック EMF） $K\_e\\,\\omega$ が加わる点が RL 回路との決定的な違いです。
%%
%[text] ### 1.3 ブラシ付き DC モータの等価回路（電気側）
%[text] ブラシ付き DC モータを、電源電圧 $V$、抵抗 $R$、インダクタ $L$、逆起電力源 $K\_e\\,\\omega$ の直列等価回路として表現します。
%[text] ![](text:image:0b1c)
%[text] $V(t)$ はモータの端子に印加する端子電圧です。$i(t)$ \[$\\mathrm{A}$\] はモータに流れる電流です。$R$ \[$\\Omega$\] はモータの巻線に存在する内部抵抗です。$L$ \[$\\mathrm{H}$\] はモータの巻線のインダクタンスです。$K\_e$ \[$\\mathrm{V\\,s/rad}$\] は逆起電力定数（角速度 $\\omega$ に比例する起電力の係数）です。$\\omega(t)$ \[$\\mathrm{rad/s}$\] はロータ角速度です。
%[text] KVL より 電気側の基本方程式：
%[text] $V(t)=R\\,i(t)+L\\,\\frac{di(t)}{dt}+K\_e \\,\\omega (t)${"editStyle":"visual"}
%[text] RL 回路の式 $v = Ri + L\\,di/dt$ に $K\_e\\,\\omega$ 項が加わった 形です。モータが回転すると逆起電力が電源電圧を相殺するため、同じ $V$ でも電流 $i$ は RL 回路単体より小さくなります。DCモータ以外でも、基本的な等価回路は同じで、相の数が変わるぐらいですので、この型は覚えておいてください。
%%
%[text] ### 1.4 電磁トルク（電流に比例する駆動トルク）
%[text] 1\.3 節までは 電気側 の式を扱いました。ロータを回す力は 機械側のトルク として現れます。ブラシ付き DC モータでは、アーマチュア（回転子巻線）に流れる電流 $i(t)$ が磁界内の導体に働く ローレンツ力 により、シャフト方向の 電磁トルク（駆動トルク） $T\_m(t)$ を生み出します。
%[text] 磁気回路が飽和していない通常の動作範囲では、この電磁トルクは 電流 $i$ に比例 します。
%[text] $T\_m (t)=K\_t \\,i(t)${"editStyle":"visual"}
%[text] $K\_t$ \[$\\mathrm{N\\,m/A}$\] は トルク定数 です。$i$ が大きいほど磁場と電流の相互作用が強くなり、シャフトに大きなトルクが伝わります。
%%
%[text] ### 1.5 機械側（慣性・粘性摩擦・負荷トルク）
%[text] 1\.4 節までで、電流 $i$ から駆動トルク $T\_m = K\_t\\,i$ が生まれることを述べました。ここからは シャフトがどう回るか（機械側） を扱います。機械系の詳細な知識がなくても、前教材の RL 回路と 対応関係 を意識すると理解しやすくなります。
%[text] 機械側の主な状態変数は 角速度 $\\omega(t)$ \[$\\mathrm{rad/s}$\] です。「シャフトが 1 秒間に何ラジアン回ったか」を表し、回転の速さそのものです。
%[text] シャフトまわりで押し返す要素を 3 つ に分けてモデル化します。
%[text] - 慣性 $J$ \[$\\mathrm{kg\\,m^2}$\]：ロータと負荷をまとめた「重さ・太さ」に相当する概念です。$J$ が大きいほど、トルクを加えても $\\omega$ は すぐには変わりません。電気回路で言えば インダクタ $L$ が電流 $i$ の変化を遅らせる のと同じ働きです。
%[text] - 粘性摩擦 $B$ \[$\\mathrm{N\\,m\\,s/rad}$\]：軸受や空気抵抗など、回転が速いほど大きくなる反対向きのトルクです。常に $\\omega$ を小さくしようとする「損失」として働きます。電気回路の 抵抗 $R$ に相当します。
%[text] - 外付け負荷 $T\_L$ \[$\\mathrm{N\\,m}$\]：ギアや外部機構など、モータ外からシャフトに加わるトルクです。（重い荷物を常に持ち上げ続ける、といったイメージ）。 \
%[text] 以上をまとめると、シャフトに働く正味のトルクは「モータが出す $T\_m$」から「摩擦 $B\\,\\omega$」と「負荷 $T\_L$」を引いたものになります。この正味トルクが $\\omega$ の変化率（角加速度）を決めます。
%[text] $J\\,\\frac{d\\omega (t)}{dt}=T\_m (t)-B\\,\\omega (t)-T\_L \\;,\\,\\,T\_m (t)=K\_t \\,i(t)${"editStyle":"visual"}
%[text] 左辺 $J\\,d\\omega/dt$ は「回転の速さがどれだけ速く変化するか」です。右辺第 1 項 $T\_m = K\_t\\,i$ は 1.4 節の電磁トルク（電流が大きいほど強く回そうとする力）。第 2 項 $B\\,\\omega$ は摩擦による減速。第 3 項 $T\_L$ は外付け負荷による減速です。定常状態（$d\\omega/dt = 0$）では $K\_t\\,i = B\\,\\omega + T\_L$ となり、「流れ込む電気エネルギー（トルク）」と「摩擦＋負荷で消費される分」が釣り合います。
%[text] 機械側にも時定数 $\\tau\_{mech} = J/B$ \[$\\mathrm{s}$\] があります。$B$ が大きい（摩擦が強い）ほど $\\omega$ は早く落ち着き、$J$ が大きいほど立ち上がり・停止が遅くなります。電気側の $\\tau\_{elec} = L/R$ と並べて読むと、2 変数系のイメージが掴みやすくなります。
%%
%[text] ### 1.6 電気系と機械系の結合（$K\_t$ と $K\_e$ の関係）
%[text] 電気側の式と機械側の式は、未知量 $i(t)$ と $\\omega(t)$ について 連立 2 階（実質 1 階連立）微分方程式 を構成します。電流 $i$ が機械側のトルクを決め、角速度 $\\omega$ が電気側の逆起電力を決める — この 双方向の結合 が DC モータのダイナミクスの核心です。
%[text] $K\_t$ と $K\_e$ の関係 — SI 単位系では、同一モータについて
%[text] $K\_t =K\_e${"editStyle":"visual"}
%[text] が成り立ちます（詳細な導出は電気機器の教科書に譲りますが、本教材では $K\_t = K\_e = K$ と 同一係数 $K$ で扱います）。以降、パラメータ名は Kt, Ke としてコード上も分けますが、数値は同じに設定します。
%[text] 与条件の例（開ループ・ステップ入力） — 初期条件 $i(0)=0$、$\\omega(0)=0$、入力 $V(t)=V\_0$（$t \\ge 0$ のステップ）、負荷 $T\_L$ 一定とします。第 2 章では、この条件で Simulink シミュレーションを行います。
%%
%[text] ### 1.7 Integrator 方式 Simulink 向けの 1 階連立形
%[text] 前教材 2.3 節（RL 回路）・2.4 節（RLC 回路）と同様、Simulink では微分方程式を $\\frac{di}{dt}$、$\\frac{d\\omega}{dt}$ の形 に直し、Integrator ブロックで $i$ と $\\omega$ を生成します。電気式を $di/dt$ について解くと：
%[text] $\\frac{di(t)}{dt}=\\frac{V(t)-R\\,i(t)-K\_e \\,\\omega (t)}{L}${"editStyle":"visual"}
%[text] 機械式を $d\\omega/dt$ について解くと：
%[text] $\\frac{d\\omega (t)}{dt}=\\frac{K\_t \\,i(t)-B\\,\\omega (t)-T\_L }{J}${"editStyle":"visual"}
%[text] これが第 2 章で組む DCMotor\_Model.slx の 信号の流れ そのものです。
%[text] 電流経路は、Sum で $V - Ri - K\_e\\,\\omega$ を計算し、Gain $1/L$、Integrator（出力 $i$）とつなぎます。角速度経路は、Sum で $K\_t\\,i - B\\,\\omega - T\_L$ を計算し、Gain $1/J$、Integrator（出力 $\\omega$）とつなぎます。両 Integrator の出力は互いにフィードバックし合います（2 変数の結合）。
%[text] RL 回路（1 変数）から 2 変数の結合系 へ拡張された点に注意してください。電気時定数 $L/R$ と機械時定数 $J/B$ の両方が応答の速さに影響します。
%%
%[text] ### 1.8 フィードバック制御の必要性
%[text] ここまでの開ループモデルでは、ステップ電圧 $V\_0$ を印加すると角速度 $\\omega$ はある定常値に近づきますが、その値は $R$, $L$, $J$, $B$, $K$, $T\_L$ すべてに依存します。実際の速度制御では 望ましい角速度 $\\omega\_{ref}$ に対し、制御器が電圧 $V$（または電流指令）を自動調整する フィードバック制御 が必要です。
%[text] 第 3 章では、まず 速度 PI 制御器が電圧 $V$ を直接操作する 単純な構成から始めます。電気系と機械系が結合しているため、$V \\to \\omega$ のプラントは 二次系 として扱われ、ボード線図上でも位相余裕の確保が難しくなることを確認します。そのうえで 電流内側ループ を追加するカスケード構成へ拡張し、 一巡伝達関数 $L(s)$ のループ整形 により内外ループを分けて設計する流れで学びます。
%%
%[text] ### 1.9 標準パラメータの定義（MATLAB コード）
%[text] 以降の章で Simulink モデルとプロットに使う 標準パラメータ をワークスペースに定義します。電気側（$R$、$L$、$K\_t$、$K\_e$）は小さめ DC モータのオーダー、$J$・$B$ は負荷込みの教材用値（SI 単位）です。Simulink 内の Gain・Step ブロックはこれらの変数名を参照する想定です。下のコードセクションを Run Section（セクションの実行）（Ctrl+Enter）で実行してください。
lectureFile = which('DCMotor_Modeling_Lecture');
if ~isempty(lectureFile)
    run(fullfile(fileparts(lectureFile), 'setupPaths.m'));
else
    run('setupPaths.m');
end
R = 2.0;        % Armature resistance [Ohm]
L = 0.005;      % Armature inductance [H]
J = 0.002;      % Inertia [kg*m^2] (tau_mech = J/B ~ 2 s)
B = 0.001;      % Viscous friction [N*m*s/rad]
Kt = 0.05;      % Torque constant [N*m/A]
Ke = 0.05;      % Back-EMF constant [V*s/rad]
V0 = 12;        % Step input voltage [V]
TL = 0;         % Load torque [N*m]
Tsim = 5;       % Simulation time [s]
tau_elec = L / R;
tau_mech = J / B;
fprintf(['Parameters defined:\n' ... %[output:group:64a9966e] %[output:9ba97d77]
    '  R=%g Ohm, L=%g H, J=%g kg*m^2, B=%g N*m*s/rad\n' ... %[output:9ba97d77]
    '  Kt=Ke=%g, V0=%g V, TL=%g N*m, Tsim=%g s\n' ... %[output:9ba97d77]
    '  tau_elec=L/R=%g s, tau_mech=J/B=%g s\n'], ... %[output:9ba97d77]
    R, L, J, B, Kt, V0, TL, Tsim, tau_elec, tau_mech); %[output:group:64a9966e] %[output:9ba97d77]
%%
%[text] ## 2. ダイナミクス解析（手計算＋Simulink）
%[text] 本章では、第 1 章で立てた連立微分方程式について、手計算・Simulink（Integrator 方式）・Simulink（Simscape 方式）の 3 つの視点を並べて扱います。いずれも同じ物理モデル・同じパラメータ・同じ入力条件で結果を比較し、解析とシミュレーションの対応を確認します。
%[text] なお Integrator 方式も Simscape 方式も Simulink 上のシミュレーションです。Integrator 方式は 1.7 節の式をそのままブロック化 する実装、Simscape 方式は 物理素子を接続 する実装、という違いがあります。
%%
%[text] ### 2.1 手計算による過渡応答のイメージ
%[text] 第 1 章の与条件（$i(0)=0$、$\\omega(0)=0$、$V(t)=V\_0$ ステップ、$T\_L$ 一定）のもとで、定常値と過渡応答のイメージを整理します。厳密な時間応答の解析は Simulink に任せ、ここでは 定常値の計算 と 二次系としての性質 の把握を目的とします。
%[text] 定常状態の計算
%[text] 定常状態では $\\frac{di}{dt}=0$、$\\frac{d\\omega}{dt}=0$ です。第 1 章の式に代入すると、電気側 $V\_0 = R\\,i\_{ss} + K\_e\\,\\omega\_{ss}$、機械側 $K\_t\\,i\_{ss} = B\\,\\omega\_{ss} + T\_L$ が成り立ちます。2 式を解くと：
%[text] $\\omega\_{ss} =\\frac{V\_0 K\_t -R\\,T\_L }{K\_e K\_t +R\\,B}${"editStyle":"visual"}
%[text] $i\_{ss} =\\frac{B\\,\\omega\_{ss} +T\_L }{K\_t }${"editStyle":"visual"}
%[text] $T\_L=0$ のとき、$\\omega\_{ss} = \\frac{V\_0 K\_t}{K\_e K\_t + R\\,B}$ です。RL 回路単体（$K\_e=0$）の定常電流 $V\_0/R$ とは異なり、逆起電力と摩擦のバランスで角速度が決まります。
%[text] 二次系としての性質（$V \\to \\omega$）
%[text] 信号 $V$ から $\\omega$ までの入力出力関係は、電気系と機械系の結合により 2 次系 として扱えます（第 3 章でブロック線図から伝達関数 $G(s)=\\Omega/V$ を導出します）。特性式は
%[text] $(Js+B)(Ls+R)+K\_e K\_t =0${"editStyle":"visual"}
%[text] となり、2 つの実根（過減衰）または共役複素根（不足減衰）を持ちます。標準パラメータ（1.9 節）では過減衰で、電気時定数 $\\tau\_{elec}=L/R$（数 ms）より機械側 $\\tau\_{mech}=J/B$（約 2 s）の方がはるかに大きく、角速度は ゆっくり立ち上がる 応答になります。
%[text] 下のコードセクションで定常値と特性根を計算します。1.9 節を先に実行してパラメータが定義されていることを確認してください。
[i_ss, omega_ss] = computeDCMotorSteadyState(V0, R, B, Kt, Ke, TL);
charPoly = [J*L, J*R + B*L, B*R + Ke*Kt];
poles = roots(charPoly);
fprintf(['Hand calculation (steady state):\n' ... %[output:group:6c89ffc0] %[output:59de716d]
    '  i_ss = %g A, omega_ss = %g rad/s\n' ... %[output:59de716d]
    '  Characteristic poles [rad/s]: %g, %g\n'], ... %[output:59de716d]
    i_ss, omega_ss, poles(1), poles(2)); %[output:group:6c89ffc0] %[output:59de716d]
%%
%[text] ### 2.2 Simulinkの実装
%[text] 1\.7 節の連立微分方程式を、Integrator・Gain・Sum ブロックで実装します。リポジトリには `DCMotor_Model.slx` を同梱しないため、以下の手順で各自作成してください。完成ファイルは `DCMotor_Modeling_Lecture.m` と 同じフォルダ に保存します。
%[text] #### 手順 1：Simulink を起動し、新規モデルを開く
%[text] 1. MATLAB コマンドウィンドウで `simulink` と入力して Simulink を起動する \
%[text] 1. 空のモデル を選び、新規モデルエディタを開く
%[text] 2. モデル名を `DCMotor_Model` とし、教材 `.m` と同じフォルダに `DCMotor_Model.slx` として保存する \
%[text] #### 手順 2：実装する微分方程式（1.7 節と同じ）
%[text] $\\frac{di}{dt} = \\frac{V - R\\,i - K\_e\\,\\omega}{L}$
%[text] $\\frac{d\\omega}{dt} = \\frac{K\_t\\,i - B\\,\\omega - T\_L}{J}$
%[text] 初期条件 $i(0)=0$、$\\omega(0)=0$。入力 $V(t)=V\_0$（$t \\ge 0$ ステップ）。
%[text] #### 手順 3：ブロック線図を組む
%[text] 端子配線の図ではなく、1.7 節の式を「微分方程式の信号の流れ」として表すブロック線図を組み立てます。
%[text] **使うブロック（Simulink 標準）**
%[text] - **Step**（入力電圧 $V\_0$）
%[text] - **Constant**（負荷トルク $T\_L$）
%[text] - **Sum**（加算。電流経路・角速度経路で各 1 個、計 2 個）
%[text] - **Gain**（$R$、$K\_e$、$1/L$、$K\_t$、$B$、$1/J$）
%[text] - **Integrator**（$i$ と $\\omega$ を生成）× 2
%[text] - **To Workspace**（`v_sim`・`i_sim`・`omega_sim` 用。手順 5 で接続）× 3 \
%[text] **配線の要点（推奨構成）**
%[text] 1. **入力電圧** — Step ブロックで $V(t)=V\_0$（$t \\ge 0$）を生成する
%[text] 2. **電流** $i$ **の経路** — Step 出力を Sum へ。Sum で `V - R*i - Ke*omega` を計算（**List of signs** = `++-`：$+V$、$-R\\,i$、$-K\_e\\,\\omega$）→ Gain `1/L` → Integrator（出力 $i$。**Initial condition** = `0`）
%[text] 3. **角速度** $\\omega$ **の経路** — Integrator（$i$）出力 → Gain `Kt` を Sum へ。Constant `TL` を Sum のマイナス入力へ。Integrator（$\\omega$）出力 → Gain `B` を Sum のマイナス入力へ。Sum で `Kt*i - B*omega - TL` を計算 → Gain `1/J` → Integrator（出力 $\\omega$。**Initial condition** = `0`）
%[text] 4. **フィードバック** — Integrator（$\\omega$）出力を Gain `Ke` 経由で電流側 Sum のマイナス入力へ（逆起電力）。Integrator（$i$）出力を Gain `R` 経由で電流側 Sum、Gain `Kt` 経由で角速度側 Sum へ接続する \\ \
%[text] #### 手順 4：パラメータを変数参照に設定する
%[text] Gain・Step・Constant は 1.9 節の変数名を参照する（数値を直接書かない）。Step：Step time = `0`、Initial value = `0`、Final value = `V0`。Constant：Value = `TL`。Gain：`R`, `Ke`, `1/L`, `Kt`, `B`, `1/J`。 \\
%[text] #### 手順 5：出力とシミュレーション設定
%[text] Step 出力 → To Workspace（`v_sim`、Save format = Array）。$i$ Integrator 出力 → To Workspace（`i_sim`）。$\\omega$ Integrator 出力 → To Workspace（`omega_sim`）。Model Settings → Data Import/Export で Time にチェック（変数名 `tout`）。Stop time = `Tsim`。 \\
%[text] #### 手順 6：Simulink 実行と結果プロット
%[text] 1\.8 節を Run Section 済みであることを確認し、Simulink モデルで Run してエラーがないことを確認します。続いて下のコードセクションで `simulateDCMotorModel` により再実行し、入力電圧と角速度を上下 2 段でプロットします。2.1 節の定常値 $\\omega\_{ss}$ と最終的な波形の定常値が近いことを確認してください。
modelName = 'DCMotor_Model';
[t, v, i, omega, ok] = simulateDCMotorModel(modelName, Tsim);
if ok %[output:group:657418cb]
    plotMotorResponse(t, v, omega, 'DC motor (Integrator model)', ... %[output:00ab597c]
        sprintf('Integrator model (R=%g, L=%g H, J=%g kg*m^2)', R, L, J), ... %[output:00ab597c]
        sprintf('Input: step voltage (V_0=%g V)', V0), ... %[output:00ab597c]
        sprintf('Output: angular velocity (omega_{ss}=%g rad/s theory)', omega_ss)); %[output:00ab597c]
    fprintf('Simulink model "%s" completed. omega(end)=%g rad/s\n', modelName, omega(end)); %[output:9b89c989]
end %[output:group:657418cb]
%%
%[text] ### 2.3 Simulink：Simscape 方式
%[text] Simscape Electrical の DC Motor 素子（または等価な RL ＋ 回転機械の接続）で 同一の物理モデル を Simulink 上に構築します。Simscape / Simscape Electrical のライセンスが必要です。
%[text] Integrator 方式では、1.7 節の式をそのままブロック化していました。Simscape 方式は、電気端子・機械端子を 物理素子で接続していく方法をとります。パラメータ $R$, $L$, $K\_t$, $K\_e$, $J$, $B$ は 1.9 節と同じ値に設定します。
%[text] #### 手順 1：新規モデル `DCMotor_Simscape.slx` を作成
%[text] 1. Simulink 起動 → 空のモデル → 名前 `DCMotor_Simscape` で教材フォルダに保存 \
%[text] 1. Simscape → Simscape → Solver Configuration ブロックを配置 \
%[text] 1. Simscape → Foundation Library → Electrical → Electrical Elements → または Simscape Electrical → Specialized Power Systems / Electric Drives から DC Motor 関連ブロックを配置（環境に応じて DC Motor ブロック、または Series RLC + Rotational Electromechanical 相当の構成） \
%[text] 1. 電源：Step または Controlled Voltage Source で $V\_0$ ステップを印加 \
%[text] 1. モータパラメータ：Armature resistance = `R`、Inductance = `L`、Torque constant = `Kt`、Back-EMF constant = `Ke`、Inertia = `J`、Viscous friction = `B` \
%[text] 1. センサ：電流・角速度を PS-Simulink Converter 等で Simulink 信号に変換し、To Workspace（`i_sim`, `omega_sim`）へ。入力電圧も `v_sim` へ \
%[text] 1. Stop time = `Tsim`、Time 出力 `tout` は 2.2 節と同様 \
%[text] #### 手順 2：Integrator モデルとの波形比較
%[text] 2\.2 節と 同一の $V\_0$, $T\_L$, $Tsim$ で両モデルを実行し、$i(t)$ と $\\omega(t)$ の波形を重ね描画して一致を確認します。下のコードセクションは両方の `.slx` が存在するときに比較プロットを表示します。
modelIntegrator = 'DCMotor_Model';
modelSimscape = 'DCMotor_Simscape';
[t_i, ~, ~, omega_i, ok_i] = simulateDCMotorModel(modelIntegrator, Tsim);
[t_s, ~, ~, omega_s, ok_s] = simulateDCMotorModel(modelSimscape, Tsim);
if ok_i && ok_s
    plotMotorCompare(t_i, omega_i, t_s, omega_s, ...
        'Integrator vs Simscape', ...
        sprintf('Angular velocity comparison (V_0=%g V)', V0), ...
        'Integrator model', 'Simscape model');
    fprintf('Both models completed. omega(end): Integrator=%g, Simscape=%g rad/s\n', ...
        omega_i(end), omega_s(end));
elseif ok_i
    fprintf('Integrator model OK. Create DCMotor_Simscape.slx for comparison (section 2.3).\n');
else
    fprintf('Create DCMotor_Model.slx first (section 2.2).\n');
end
%%
%[text] ### 2.4 パラメータ変更と 3 方式の比較
%[text] パラメータを変えると定常値・立ち上がりの速さが変わります。ここでは 慣性 $J$ を 2 倍 にした場合を例に、手計算の予測と Integrator モデルの波形を比較します（Simscape モデルがあれば同様に $J$ を変更して 3 方式比較可能）。
%[text] $J$ を 2 倍にすると $\\omega\_{ss}$ は変わりません（$T\_L=0$ のとき定常式に $J$ が現れないため）が、立ち上がりは 遅く なります。下のコードでは $J$ を一時的に 2 倍にして Integrator モデルを再実行します。Simulink モデル内の $J$ 参照はワークスペース変数のため、実行前に `J` を変更すればモデルに反映されます（Simscape 側も Inertia = `J` 参照なら同様）。
%[text] 演習：$B$ を 2 倍、$T\_L$ を 0.05 N·m などに変え、2.1 節の式で $\\omega\_{ss}$ を予測してから Simulink で確認してください。
J_base = J;
J = 2 * J_base;
[i_ss_J2, omega_ss_J2] = computeDCMotorSteadyState(V0, R, B, Kt, Ke, TL);
fprintf('J doubled: omega_ss=%g rad/s (unchanged if TL=0), i_ss=%g A\n', omega_ss_J2, i_ss_J2);
[t2, v2, ~, omega2, ok2] = simulateDCMotorModel(modelIntegrator, Tsim);
J = J_base;
[t1, v1, ~, omega1, ok1] = simulateDCMotorModel(modelIntegrator, Tsim);
if ok1 && ok2
    plotMotorCompare(t1, omega1, t2, omega2, ...
        'Effect of inertia J', ...
        sprintf('Angular velocity: J=%g vs J=%g kg*m^2', J_base, 2*J_base), ...
        sprintf('J=%g', J_base), sprintf('J=%g', 2*J_base));
end
fprintf('Chapter 2 complete. Proceed to Chapter 3 for Bode plot and loop shaping.\n');
%%
%[text] ## 3. 制御系設計（ボード線図とループ整形）
%[text] 本章では、第 1 章の結合モデルを 伝達関数 として整理し、MATLAB の ボード線図（bode / margin） で周波数応答を直感的に理解します。制御器設計の基本手法として、単位帰還（ユニティフィードバック）構成における 一巡伝達関数 $L(s) = C(s)G(s)$ のループ整形 により、ゲイン交差周波数・位相余裕・帯域などの目標を満たすよう $C(s)$ を決めます。
%[text] 学習の流れは次のとおりです。まずプラント $G(s)$ のボード線図を描き、$V \\to \\omega$ が 二次系 であることを確認します。次に 速度 PI 制御器が $V$ を直接操作する 構成でループ整形を試し、二次プラントでは位相が急速に落ちるため設計が難しいことをボード線図で理解します。最後に 電流内側ループ を追加し、内側ループを先に整形してから外側速度ループを設計する カスケード構成 へ拡張します。各段階で Simulink シミュレーションとボード線図の結果を照合します。
%%
%[text] ### 3.1 プラントの伝達関数とボード線図
%[text] 第 1 章の結合モデルを ブロック線図 から整理し、$V$ から $\\omega$ までの伝達関数 $G(s)$ を求めます。ラプラス変換の長い式変形は省略し、ブロックの直列とフィードバックから読み取ります。
%[text] ブロック線図の整理
%[text] 電気側：$V$ から $i$ までの経路は $G\_i(s) = \\frac{1}{L s + R}$ に、角速度 $\\omega$ による逆起電力 $K\_e \\omega$ が 負帰還 として作用します。機械側：$i$ から $\\omega$ まで $G\_\\omega(s) = \\frac{K\_t}{J s + B}$（$T\_L$ は外乱として省略可能）。$V$ から $\\omega$ への閉ループ相当の伝達関数は
%[text] $G(s)=\\frac{\\Omega (s)}{V(s)}=\\frac{K\_t }{(Js+B)(Ls+R)+K\_e K\_t }${"editStyle":"visual"}
%[text] 分母は 2 次式 なので $G(s)$ は 2 次プラント です。定常ゲイン $G(0) = K\_t / (B R + K\_e K\_t)$ は 2.1 節の $\\omega\_{ss}/V\_0$（$T\_L=0$）と一致します。
%[text] 下のコードで $G(s)$ を `tf` オブジェクトとして作成し、`bode` と `margin` でボード線図を描きます（3.1 節ではプラント $G(s)$ のみ。3.2 節以降は $C(s)$、$G(s)$、$L(s)$ を同一図に重ねます）。低周波ゲイン（定常ゲイン）、折れ点（$\\tau\_{elec}$, $\\tau\_{mech}$ 付近）、高周波での減衰（$-40$ dB/dec 付近）を確認してください。
numG = Kt;
denG = conv([J, B], [L, R]);
denG(end) = denG(end) + Ke * Kt;
G = tf(numG, denG);
fprintf('Plant G(s): omega/V\n');
fprintf('  DC gain G(0) = %g rad/(s*V)\n', dcgain(G));
plotBodePlant(G, 'Plant Bode diagram', 'Plant G(s): V to omega');
[gm, pm, wcg, wcp] = margin(G);
fprintf('Plant only (no controller): GM=%g dB, PM=%g deg, wcg=%g rad/s\n', 20*log10(gm), pm, wcg);
%%
%[text] ### 3.2 ループ整形の基礎（一巡伝達関数）
%[text] 単位帰還（ユニティフィードバック）構成では、制御器 $C(s)$ とプラント $G(s)$ の 一巡伝達関数 $L(s) = C(s)G(s)$ の形状を整える ループ整形 が基本です。目標の目安は次のとおりです。
%[text] ゲイン交差周波数 $\\omega\_c$（$|L(j\\omega\_c)|=1$）：応答の速さの目安。位相余裕 PM（$\\angle L(j\\omega\_c)$ と $-180\\degree $ の差）：オーバーシュート・安定性の余裕。一般に PM $\\ge 45\\degree $ 程度を目標にすることが多いです。
%[text] PI 制御器 $C(s) = K\_p + \\frac{K\_i}{s}$ は、低周波ゲインを上げて定常偏差を小さくし、位相は $\\omega\_c$ 付近で遅れを生じます。`margin(L)` で GM・PM を読み、$K\_p$, $K\_i$ を調整する流れがループ整形の基本です。
%[text] 例として、速度制御用 PI の初期候補 $K\_p=0.05$、$K\_i=0.2$ で $L(s)=C(s)G(s)$ のボード線図を確認します。下のコードでは $C(s)$（青）、$G(s)$（橙）、$L(s)$（黒）を 同一図に重ね描画 します（3.3 節で Simulink と照合）。
Kp_demo = 0.05;
Ki_demo = 0.2;
C_demo = tf([Kp_demo, Ki_demo], [1, 0]);
L_demo = C_demo * G;
plotBodeLoopComponents(C_demo, G, 'Loop shaping demo', ...
    'C(s), G(s), L(s)=C(s)G(s) (PI demo)');
[gmL, pmL, ~, wcpL] = margin(L_demo);
fprintf('PI demo on G(s): Kp=%g, Ki=%g -> PM=%g deg, wcp=%g rad/s\n', Kp_demo, Ki_demo, pmL, wcpL);
T_demo = feedback(L_demo, 1);
stepInfo = stepinfo(T_demo);
fprintf('Closed-loop step info (omega/V): rise time=%g s, overshoot=%g %%n', ...
    stepInfo.RiseTime, stepInfo.Overshoot);
%%
%[text] ### 3.3 速度制御：電圧を直接操作する場合
%[text] $\\omega\_{ref}$ を入力とする単位帰還で、PI 制御器の出力を 電圧 $V$ 直接 に接続します。一巡伝達関数は $L(s) = C\_{speed}(s)\\,G(s)$ です。2 次プラント $G(s)$ では位相が中域で急速に落ちるため、PM を確保しにくい 場合があります。
%[text] Simulink モデル `DCMotor_Speed.slx`：2.2 節のプラントに PI Controller（速度）を追加。$\\omega\_{ref}$ ステップ → Sum（偏差）→ PI → $V$ → プラント → $\\omega$ フィードバック。Integrator プラント部分は 2.2 節と同じ。 \\
%[text] 下では $G(s)$ 上でループ整形した PI ゲイン例（$K\_p=0.08$, $K\_i=0.15$）の閉ループステップ応答を確認します。Simulink モデル作成後、同じゲインで波形を照合してください。
Kp_speed = 0.08;
Ki_speed = 0.15;
C_speed = tf([Kp_speed, Ki_speed], [1, 0]);
L_speed = C_speed * G;
[gmS, pmS, ~, wcpS] = margin(L_speed);
T_speed = feedback(L_speed, 1);
plotBodeLoopComponents(C_speed, G, 'Speed loop (V direct)', ...
    sprintf('C_{speed}, G, L=C_{speed}G (PM=%.1f deg)', pmS));
figure('Name', 'Speed control step response', 'Color', 'w');
step(T_speed);
grid on;
title(sprintf('Closed-loop speed control (V direct), PM=%.1f deg', pmS));
applyWhiteFigureStyle(gcf);
fprintf('Speed PI (V direct): Kp=%g, Ki=%g, PM=%g deg\n', Kp_speed, Ki_speed, pmS);
%%
%[text] ### 3.4 電流内側ループの追加（カスケード構成）
%[text] 外側ループ：$\\omega\_{ref} \\to C\_{speed} \\to i\_{ref}$。内側ループ：$i\_{ref} \\to C\_{curr} \\to V \\to G\_i(s)=\\frac{1}{L s + R}$（逆起電力 $K\_e\\omega$ は外乱）。内側を先に整形し、$V \\to i$ を十分速くすると、外側から見た等価経路は $i \\to \\omega$ の $G\_\\omega(s)=\\frac{K\_t}{J s + B}$ に近づき、ループ整形が容易になります。
%[text] Simulink モデル `DCMotor_Cascade.slx`：外側 PI（$\\omega$）、内側 PI（$i$）、2.2 節プラント。内側ループの一巡 $L\_i = C\_{curr}(s) / (Ls+R)$、外側は整形後の等価プラント $G\_{outer}(s)$ に対して $L\_o = C\_{speed}(s) G\_{outer}(s)$。 \\
%[text] 下では内側 PI（$K\_{p,i}=2$, $K\_{i,i}=50$）で $L\_i$ の PM を確認し、内側閉ループ $T\_i = L\_i/(1+L\_i)$ 経由で外側等価 $G\_{outer} \\approx G\_\\omega \\,T\_i$ のボード線図を描きます。
G_i = tf(1, [L, R]);
G_omega = tf(Kt, [J, B]);
Kp_curr = 2;
Ki_curr = 50;
C_curr = tf([Kp_curr, Ki_curr], [1, 0]);
L_i = C_curr * G_i;
[gmI, pmI, ~, wcpI] = margin(L_i);
T_i = feedback(L_i, 1);
G_outer = G_omega * T_i;
Kp_sp_c = 0.3;
Ki_sp_c = 1.0;
C_sp_c = tf([Kp_sp_c, Ki_sp_c], [1, 0]);
L_outer = C_sp_c * G_outer;
[gmO, pmO, ~, wcpO] = margin(L_outer);
plotBodeLoopComponents(C_curr, G_i, 'Inner current loop', ...
    sprintf('Inner loop: C_{curr}, G_i, L_i (PM=%.1f deg)', pmI));
plotBodeLoopComponents(C_sp_c, G_outer, 'Outer speed loop (cascade)', ...
    sprintf('Outer loop: C_{speed}, G_{outer}, L_o (PM=%.1f deg)', pmO));
T_cascade = feedback(L_outer, 1);
fprintf('Inner loop: Kp=%g, Ki=%g, PM=%g deg\n', Kp_curr, Ki_curr, pmI);
fprintf('Outer loop (on G_outer): Kp=%g, Ki=%g, PM=%g deg\n', Kp_sp_c, Ki_sp_c, pmO);
figure('Name', 'Cascade closed-loop step', 'Color', 'w');
step(T_cascade);
grid on;
title('Closed-loop step (cascade design, transfer-function model)');
applyWhiteFigureStyle(gcf);
%%
%[text] ### 3.5 設計比較と事後課題
%[text] 3\.3 節（$V$ 直接）と 3.4 節（カスケード）では、同じ $\\omega\_{ss}$ 目標でも 一巡伝達関数の PM と閉ループステップ応答 が異なります。Simulink モデル `DCMotor_Speed.slx` と `DCMotor_Cascade.slx` を作成し、本節のゲイン設定でシミュレーションし、ボード線図の予測と波形を照合してください。
%[text] 事後課題（制御設計レポート）
%[text] 一巡伝達関数 $L(s)$ の整理（$G(s)$、$C(s)$ の式とパラメータ）。ループ整形の意図（目標 PM・$\\omega\_c$ の記述）。3.3 と 3.4 のボード線図・`margin` 結果・Simulink 波形の比較。カスケード構成の利点を自分の言葉で考察。発展：実機パラメータへの置き換え、$T\_L \\ne 0$ 時の定常偏差。
%[text] 下のコードは 3.3 と 3.4 の閉ループステップ応答を 1 枚に重ね、設計比較のたたき台とします（Simulink 作成後は実波形でも同様に比較）。
figure('Name', 'Design comparison', 'Color', 'w');
step(T_speed, 'b-');
hold on;
step(T_cascade, 'r--');
grid on;
legend({'V direct (3.3)', 'Cascade (3.4)'}, 'Location', 'best');
title('Closed-loop step: V-direct vs cascade (transfer-function model)');
xlabel('Time [s]');
ylabel('Normalized response');
applyWhiteFigureStyle(gcf);
fprintf('Report: compare PM, overshoot, and Simulink waveforms for both designs.\n');

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[text:image:612b]
%   data: {"align":"baseline","height":143,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAACPCAYAAAAV4wXfAAAAOnRFWHRTb2Z0d2FyZQBNYXRwbG90bGliIHZlcnNpb24zLjEwLjksIGh0dHBzOi8vbWF0cGxvdGxpYi5vcmcvJkbTWQAAAAlwSFlzAAALEwAACxMBAJqcGAAADNVJREFUeJzt3XlsVFUbBvB3SoFKaYHiIBGshbILIUViBUUB2VqRRaUEiGxKWGRJIE1Y\/qhBlKBIKAaSQoECpjHSRghLEJQlAinK0igqYmkqQUgqS4TSBVrOl\/dN5n5t6TKd3o05zy+ZzPT2dO6h5T5z7rnnnOtRSikCAC2FOF0BAHAOAgBAYwgAAI0hAAA0hgAA0BgCwCLTp08nj8cjj9DQUIqOjqa5c+fSnTt3rNolQIMhACw0bNgwunHjBhUUFFB6ejrt27eP5s2bZ+UuARoktGHFoSGaN29O7du3l9cdO3akiRMnUkZGBn6J4BpoAdgkPz+fDh06RE2bNrVrlwD1QgvAQnzAt2zZkioqKqi0tFS2rVu3zspdQiP7bW7evEn79+\/X5veIALDQa6+9Rps3b6aSkhLasmULXblyhRYuXGjlLgEaBKcAFmrRogV16dKF+vTpQxs2bKDi4mL6+OOPrdwlQIMgAGyUkpJCa9asoevXr9u5W4BaIQBsNHjwYOrVqxetWrXKzt0C1AoBYLMlS5bQ1q1b6e+\/\/7Z71wCP8WA9AAB9rwKgBQCgMVwGBKjk7t27lJubW3kTtW7dmmJiYigYIQAAKvnxxx8pLi6u8iZ65513KCsri4IRTgH8wNfvufMuJyfHFeXBGhkZGcRLZFZ\/BOvBL7gTEOqWmprKC6equLg4V5QHMAtaAH7YvXu3PF+4cEGG8zpdHsAsCIB6\/PPPP3Ty5MnHDlanygOYCQFQj+zsbHlu166dXweo1eXBPzwDMy8vj37\/\/Xfp2Xe6jGuZdjIRpF599VU5P9+2bZuKiIiQ13l5eY6Vh7qVlZWpzz77THXq1El+l\/wICwtTM2bMUH\/99ZftZdwOAVCHa9euKY\/Ho5o3b67u3r2rJk+eLH\/k1atX11qev29VeahbaWmpGjlypHEwer1e1aVLF+PrqKgolZOTY1uZ8+fPu\/5PhgDwo3d+\/Pjx8vWePXvk6379+jlSHuq2fPly42Dk32V5eblsv3z5skpISJDvRUZG2lYmOjpaPXjwwNV\/NgRAHXzN88zMTPm6pKSkzma61eWhdvy7a9u2rfzujh07VmPrIDY21viEtrpM165d5ftZWVmu\/rO5ZjLQ\/fv3ZapsWVkZDRw40OnqyACQvXv3UrNmzejff\/+liIgI2T5lyhTKzMyk1atX09KlS6v05vPCn7wQqBXli4qKaPHixTJZxS144BKveuwmvAQbd8TxcuzVzZkzh9LS0qhVq1ayPLvHwjJr166l5ORkchuv10uFhYX\/36Bc4uzZs0aquukxceLEKvWsrZlevTlvVXk86v4dxMfH1\/p\/7Ny5cyo5OVmlpaVZXqagoEAGdrnx7+XKFgBXIyQkpMqlMafxDT14EY\/IyEhjGy\/uyZfs7t27J5d+YmNjZfugQYPkej5\/ek+aNMmy8suWLaP+\/fuTG\/AKx0OHDqXw8HCnqwJ+8LVUqhzyykVqSig3qt5bX7033+7yAIEeXxgIFICkpKQqg3Z8LZbExETjXN6K8gkJCTWWBwiYcpEnpQVQvbe+em++3eUBAj2+XHW0PSkBULmZvmDBAr+a51aXB6gPAsBEvt56HilYU2++2eXHjRtnZvVBQ4Q+APOMHDlSzsd9PaoTJkywtLyvXwDATOgEDFBYWBi99dZb8poH84wePdrR8gCBQAA0wrRp04w14\/zpnbe6PEBDuWYgUK0DFVzu\/Pnz1K1bNxmC6obyAA05vhAAABoHAE4BADSGAADQGAIAQGMIAACNIQAANIYAANAYAgBAYwgAAI0hAAA0hgAA0BgCAEBjCAAAjSEAADSGAADQGAIAQGMIAACNIQAANIYAANAYAgBAYwgAAI0hAAA0hgAA0BgCAEBjoU7tuKKigv788086d+6c3PyisLDQ+N4HH3xAvXv3phdffJHi4uJwUwwAi9h+Y5Cff\/6ZNm3aRFlZWVRUVOTXzQxefvllmjt3rtxQk++ZBwBP2J2Bvv32W\/r000\/p7Nmzxrbo6Gj5lO\/fv7+85ptglpeX0+3btyk3N1daBxcvXqSHDx9K+bZt29Ls2bNp+fLlFB4ebke1AYJGjbfes\/qe5IWFhSopKcm4N3lUVJRKTk5WeXl5fv18UVGRSk9PV3FxccZ7dO7cWR0\/ftzqqgMEFd\/xU2WblTs8ePCg8nq9stPw8HCVmpqqiouLA3qvR48eqZMnT6q+ffsa\/5BFixaphw8fml5vgGBkawDs2rVLNWnSRHY4ePBglZ+fb8r7lpWVqZSUFBUaGirvPXbsWFVSUmLKewMEM9sC4Ouvv1Yej0d2tmzZMlVRUeHXzyUmJsrDH6dOnVKtW7eWfYwbNw4tAQA3BEBOTo7x6bxy5cpGV7Auubm5RggsXLgwgNoC6KOm48vUqwClpaVy3f7SpUv04Ycf0pdffmn0PAbcS1mP06dP0+uvvy5XD44fPy6vAcC\/48vUkYAfffSRHPw9evSgtWvX1nvwv\/nmm1LG96hcUX7w9+szcOBAWrFihbyeOXMm3b9\/34R\/CYAeTAuAP\/74gz7\/\/HMKCQmh7du32zpgh8cF9O3bl\/Lz8+mTTz6xbb8ATzrTTgHmz59PGzdupFmzZtHmzZsDq0wApwCVTwVeeeUVGSx07do1jBgEsOsU4N69e7Rz5055vWDBAnLCgAEDqF+\/fnTr1i3avXu3I3UAeNKYEgCZmZkSAoMGDaI+ffqQU+k2b948ec1zDQAgwAAYM2YMvfHGG7We6\/PBdvjwYWPb999\/L8\/Tpk2jxkhMTJRHoCZNmkRNmzalM2fOSCABQAAB8P7779OxY8eooKDgse9t3bqVnn\/+eRo2bJixzTfBJz4+nhrjwIED8ghUixYtpAXC5zgXLlxoVF0AtA0Avvz2zDPPSG9+ZTwrb9euXXK5jXv7GZ9zc1A89dRTcvnPaTy7kPFMQgAIIABCQ0OlOZ+RkUGPHj0ytu\/bt49u3rxJM2bMMLb99ttv8syfvPxzTuOBSIynEQNAgJ2AfBpw9epV4\/ze1\/wfMWIEPffcc8Y236IeUVFR5AZt2rSRZ38WGwHQXa0B0LVrVxlWu23bNvn6+vXr9N1330kwVMZDcJkbPv0ZdwIy3yIiABDgZUA+2Pfs2SMr9PDpAH\/Kjx07tkoZXsWHlZWVkRvwfASGpcMAGhkA7777rhxIX331lbQEpk6danzC+rRr106e+XTBDXz18Hq9TlcFwPXqbLdzz\/7kyZNlks+dO3cea\/6zXr16UbNmzejy5cty7T0iIoKc5Ov9910NAIBGjATkJbr54OdZdz179nzs+3wK4KZr7wgAABMDgMfX88F96tSpWsvwqr7shx9+ICfxbEAek8ADgtwwJgFAi7kASUlJ8pyenu5o73taWprRd9GkSRPH6gGg1XRgfgs+PeA7\/WRnZ9Pbb79NTvT+d+zYUUYm5uTkNHpYMkCwsWw6cOWZeGvWrJHbfvmj+opA1R\/+rAhUeZASH\/x8yvLSSy8F\/G8B0IlpKwJNnz6dnn32Wfrpp58oNTWV7MTn\/UuXLjVWB2rIOoQAOjN1UVCeyTd69GgZO8C39urevTtZjecqDB8+nI4ePSrn\/lgMBMChRUG5yc6Dhfh8nG\/kyZcPrZaSkiIH\/9NPPy1LkgGA\/0wNALZ+\/Xr55P\/1119p1KhRloYA32x01apV0uPPU5d9oxIBwKEA4Nl4R44coZiYGOkP4AlFPErQTNzCWLRokSwHzs0aHqbMpx4A0EBW3YXk6tWrqnv37nInkrCwMPXFF1+o8vLyRr\/vmTNnVM+ePeV9+Q5EmZmZptQXINjZfnfg27dvq6lTpxo7jo+PV9nZ2QHdx+\/ixYtqzpw5KiQkRN6rW7du6vTp05bUGyAYWX5rsNrwSkKzZ8+mGzduyNcdOnSQ+wcMGTJEVvCpaQIRjyXguwzxacSOHTvoxIkTsp2b\/EuWLKGVK1fKZCUACPwqgC0BwP777z9ZU4CX7K7cJ8CV4k7D6OhouXTI1YmNjaVffvmFiouLjXItW7ak9957TwYc9e7d244qAwQVRwPAh3fHl+2++eYbWU2YrxbUNn+AVx\/mab28AvGUKVMoMjLSzqoCBBVXBEB1vJIQLyxaWFhICQkJso3v8vvCCy\/ItX0ACOIAMOvegADg8EhAAHiyIAAANIYAANAYAgBAYwgAAI0hAAA0hgAA0BgCAEBjCAAAjSEAADSGAADQGAIAQGMIAACNIQAANIYAANAYAgBAYwgAAI0hAAA0hgAA0BgCAEBjCAAAjSEAADSGAADQGAIAQGMIAACNIQAANIYAANAYAgBAYwgAAI0hAAA0hgAA0BgCAEBjoeRCHo\/H6SoAaMFVLQCv1+t0FQCCWvVjzKOUUo7VBgAc5aoWAADYCwEAoDEEAADp63\/AE7k2+ZqqoAAAAABJRU5ErkJggg==","width":256}
%---
%[text:image:0b1c]
%   data: {"align":"baseline","height":143,"src":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAARIAAACPCAYAAAA2uFQKAAAAOnRFWHRTb2Z0d2FyZQBNYXRwbG90bGliIHZlcnNpb24zLjEwLjksIGh0dHBzOi8vbWF0cGxvdGxpYi5vcmcvJkbTWQAAAAlwSFlzAAALEwAACxMBAJqcGAAAEBlJREFUeJzt3QtQVNUfB\/CzBkLyyEAePkIKsPBRAzhplumYo2E5ZJpOOqM9R6nJpggf2GT20OmlYY4jaow9hprAAdOanDK1zGgCZNIY5WFmpSDmg0BAgfOf3+\/v7rDILrt77t27u3w\/MyuwnLv3uHC+3Me5v2uSUkoBAKCgj8rCAAAIEgDQBLZIAEAZggQAlCFIAEAZgkQnjz32mDCZTPzw8\/MTMTExIj09XZw\/f16vVQIYBkGio8mTJ4vTp0+LEydOiK1bt4qdO3eKZ555Rs9VAhjCz5jV9g4BAQEiOjqaPx8yZIiYM2eO2LZtm9HdAtActkjc5Pjx4+Kbb74R\/v7+7lolgNtgi0RHFBzBwcGivb1dtLS08HNr167Vc5WgeFzr7NmzYteuXXgfnYQg0dG9994rNm\/eLJqbm8WWLVtETU2NWLx4sZ6rBDAEdm101K9fPxEfHy9GjRol1q9fLy5duiRef\/11PVcJYAgEiRutXLlSvPXWW+LUqVPuXC2A7hAkbjRx4kQxfPhw8cYbb7hztQC6Q5C4WUZGhvjwww\/Fn3\/+6e5VA+jGhHokAP+HszauwxYJACjD6V+AThoaGkR5ebnVe9K\/f38RGxuL98kOBAlAJz\/++KNISkqyek9mzpwpCgoK8D7ZgV0bB9D8DzpIWlxc7BHtQR90HRSVMO76QIg4gA62gn3Z2dlUIFsmJSV5RHsAT4MtEgfk5+fzx0OHDvE0d6PbA3gaBEkP\/vnnH3HgwIFrBr1R7QE8EYKkB9u3b+ePkZGRDg10vduDY+iK6+rqalFRUcFnYoxu4\/OM3rfydPfccw8fv8jNzZUhISH8eXV1tWHtwb7W1lb59ttvy5tvvpnfS3oEBgbKxx9\/XFZVVbm9TW+BILHj77\/\/liaTSQYEBMiGhgY5d+5c\/mVZs2aNzfb0fb3ag30tLS1y6tSplkEdEREh4+PjLV+HhYXJ4uJit7UpKyvrNT8yBIkDZ1NmzJjBXxcVFfHXycnJhrQH+7KysiyDmt7LtrY2fr6yslKmpqby90JDQ93WJiYmRl6+fLlX\/NgQJHaYdzvy8vL46+bmZru7H3q3B9vovQsPD+f3bu\/evd1urcTFxVm2GPRuk5CQwN8vKCjoFT82j7lor6mpiS+xb21tFePGjTO6OzwRaceOHaJv376ivr5ehISE8PPz5s0TeXl5Ys2aNWLZsmVWZ1+owDMVfNajfWNjo3jxxRe5FKCnoAl0VCXfk1BpSzrgSbcB6WrRokUiJydH3HDDDXxbED3bvPvuuyIzM1N4mrvuukscPHhQ+xeWHqKkpMSS8p70mDNnjlU\/be1+dN1N0as9HvbfgzFjxtj8HSstLZWZmZkyJydH9zYnTpzgCYae9vOKjo6WPr1FQt3o06eP1SlRo9GNragYUWhoqOU5KuJMp2r\/++8\/PuUXFxfHz48fP57ng9DWxKOPPqpb++XLl4vRo0cLT0AV8SdNmiSCgoKM7gr0oKioSMyYMUOkpaXx55qTHsScmp6u69mVrmdf3N0eoCeFhYX8O5SWlib1gAlpLpg9e7bV5DHzFtS0adMsxzr0aJ+amtptewCjIUhcMHXqVB7QZWVlfG2MecA\/8sgjurY3BwyAp0GQuCAwMFBMnz6dP8\/OzuZjF3T25cEHHzSkPYDRECQuMm8dbNiwwe5uilbtsVsDngxB4iLz7of5pJet3RSt2mO3BjwZgsRFnXc\/HNnt0Ls9gJEQJAoWLFhgqenpyNkUvdsDGAXFnxVMmTJFlJaWimHDhnlEewCjIEgUJScne1R7ACNg1wYAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAlCFIAEAZggQAvPe+Nu3t7eLYsWN8A6iysjJx5swZy\/eeeuopMXLkSJGSkiKSkpJEcHCwUd0E8Alnro6vPXv26PL6Jmm+S7Wb\/Prrr2Ljxo2ioKBANDY29tjeZDKJsWPHivT0dL7xNt0TFwCcC5GoqCjL10VFRSItLU14ZZAUFhaK1atXi5KSEstzMTExvNUxevRo\/pxult3W1ibOnTsnysvLeWvlyJEj4sqVK9w+PDxcLFy4UGRlZYmgoCB3dBvA60Pkvvvu43Fk5u\/vL\/Lz87UNE6mzM2fOyNmzZ1NY8SMsLExmZmbK6upqh5ZvbGyUW7dulUlJSZbXuOWWW+S+ffv07jqAV6urq5MjR47kMZOYmChPnz4tMzIy+Gt\/f39ZVFSk2bp0DZKvv\/5aRkREcMeDgoJkdna2vHTpkkuv1dHRIQ8cOCDvuOMOS6A8\/\/zz8sqVK5r3G8DXQqS2ttYyjvQIE92C5JNPPpHXXXcdd3jixIny+PHjmrxua2urXLlypfTz8+PXTktLk83NzZq8NoAvh4iZHmGiS5B8\/vnn0mQycUeXL18u29vbHVpu2rRp\/HDETz\/9JPv378\/reOihh7BlAiDth0jn8aV1mGgeJMXFxZathddee825zlzdZXFUeXm5JUwWL17sQm8Bes+WiOgyvrQME02DhHYxbrvtNu7Ys88+yx3VM0jMWybm4MIBWOit6noIEVvjS6sw0TRIli5dyh2iMHHkuAVtZpn\/c909HN3NoWMm5rM5dJYHoDepsxEijo4vLcJEsyCpqKiQffr04cfPP\/\/s0DJaBQkdgDWfzaFjMgC9RV0Px0QcHV+qYaJZkNCuDHXi6aefdvk1XNm16byLQ8uGh4fjLA70CnUO7M44M75UwkSTIGloaJAhISHcgd9++82QIKE3ITk5mZf\/+OOPXe4DgC+GiKPjy9Uw0SRINm3axCseP3680uuoBAmhGbC0\/NixY5X6AeBrIeLM+HIlTLp91enTp8tJkybZPBZCK9i9e7fluVmzZvFzNJBVODOPpDtNTU38H6c5LLSVBGDLggUL5AMPPGD13M6dO+X1118vV6xY4XMh4uz4cjZMug0SWogG4x9\/\/HHN9+jFhw4dajXJLDY2lld4+PBhaTTz7s3+\/fuN7gp4UZDQ7nDfvn3l+++\/L30xRFzhTJh0GyR0\/Up0dLR85ZVXrJ6\/fPmyjIyMlKtWrbI8d\/bsWV4RJbknXPdCB3upP2vXrjW6K+AlQbJu3ToOEbqswxm5ubk8oAMCAmRCQgL\/ztmbxU0Dn9bT3YA8dOgQ\/97SR08IEWfDRNibExITE2P1xmzfvp1P7548edLyHP3lp5Xceeed0hNs3LiR+\/PEE08Y3RXwgiCh3Rj6I\/jVV185tfzmzZv5j21+fj5fR\/bll1\/KqKgo+cEHH9hchgKLziq2tbV1+\/3bb79dvvDCCx4TIs6Eic0gqaysvOZYCO1f3X\/\/\/Vbt6AdA7bo+b5TPPvuM+0OlCwDsBQltHdDvyq5du5x+o2666aZrzg6uW7eOB7otFFx0PNEWGqwUGJ3RBEsjQ8RWmHz33XdW37dZszUhIUFMmDBB5Obm8tenTp0Su3fvFk8++aRVOypERPz8DKvaaIWKthBzMSQAW6icZ1xcnFi1apW4cOGCw29UfX29+Ouvv7jIFpUBDb76WLZsmaipqbG5XHV1tYiPj7d8vX79erF06VKrMVdVVWW1zNGjRy1FiTIyMqwqnbkTVSpcsmSJCAsL47G1Y8cOx4s\/U2hQWTaqWLZt2zZ+ka5VlaiqGWltbRWeoKWlhT+iJCP0ZODAgWL\/\/v3i4sWLYvLkyeL8+fMOvWkdHR38cdOmTVzJr\/zqgwb877\/\/bndZ8x9eQqFRUVFh+ZoGKA3YzpKTkzlACJUb7TqA3V1pjbIgMTFRrFixwvEgmTVrFg\/ITz\/9lLdM5s+fb\/mLbxYZGckfT548KTyBuR8RERFGdwW8wODBg8W+fftEU1MTD5R\/\/\/23x2Voq2DQoEG89UFbGPFdHrbExsaKyspKy9eHDx+2KoFIwUJtOqNgeeeddzhMKGiobrG7w6RzuUYKkb179167ZdTTvlF6erq88cYbed+I5pB01dLSwvuanjJ3Y+bMmdzXjz76yOiugBed\/qVjDyNGjOADnvX19T0uv2XLFhkYGMhnao4ePcpTH+h3bvXq1TaXycnJ4TM8dLCysLBQDhkyRKakpPAJAjppQWVIs7Kyul1Wr8pmPXH0QG+PQVJaWsovMm7cOJtt6M3wlLkb5jktR44cMbor4GUT0qi+MAUJDRwaQD3Jy8vjWsIBAQFcF+fuu+\/mg\/220BnQ5557ToaGhvIZHwoTKn1B87L69esn586da7cUqbvDxJmzRZpMkV+4cCGvrOu8E3erqanhftAPxdYpNgBv1uGmMHH6gkAtVrpnzx5e4aBBg3jSmlGWLFnC\/Zg\/f75hfQDw9jBx6YJArf5jt956K6+YJq0ZgQop0WQf6gOVewRQQXc9sPX44YcffDZM6ly9IFCTtUvJt5owz3B1dLdCq8JGZMOGDbwMXWvjbIlHgK6qqqpsPly9pYq7w8TZ8aUyg1azILl48SLv2lAn3nvvPbcGCV1cGBwczMsUFBQo\/k8AvEeHnTBxZnypTsPXtGYrTTWmjtBpMTol5g50JJxKHtB67U0\/BvBVHYq7OVpcy6P57SjoQCd1aNSoUfLcuXNSby+\/\/DKvb8CAAQ6dsgPwRR0uholWFwRqHiQUHuYDr3S8RM8wefPNN3k9dEc\/KkoD0Jt1OBkmWl5VrMud9qjMgHliGG2ZHDt2TPMzNHRDLHp9mlGLWawAzoWJ1qUJdLv3L4WJecuEjpnQAVgtJon98ssv\/B+n16UbY9HsQgBwPEz0qG+iW5AQ2q0xHzOhx5gxY3ieiSuV1GjK+6JFi7iwEr3WsGHD5MGDB3XpN4CvhkmdTkWSdA0SM6oeNXDgQEugDB48WL766qt8bY6tC\/1o64XCg8rZTZgwwbIs7cq89NJLHnMuH8BbwoQuNNSrSJJbgoRcuHCBC+vSlkTnc9kUDHSLzylTpnA92IiICL6dBF0v07kdzROhK5E9ocA0gDeGibj60KPSmon+cWdtA1rd999\/L7744gtRUlLCNRlsVTMbOnSoSElJ4aIz8+bNE6Ghoe7sKoBPkFKK4cOHc7U1Ultbq3mlNbcHSVdUWY2qSlHxlNTUVH6OCs2MGDFCDBgwwMiuAfiMwsJC8fDDD\/Mf5W+\/\/Vbz1ze80CqVaqRycp1RrVgA0I65hGNQUJDQg91SiwAAjkCQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyBAkAKEOQAIAyk5RSCg9hMpmM7gKAT4uKihK1tbW+vUUSERFhdBcAfFpAQIDvb5EAgD5omJeWlorExEQRFBSk+esjSADAt3ZtAMA7IUgAQKj6H56\/b8n6ZG0rAAAAAElFTkSuQmCC","width":274}
%---
%[output:9ba97d77]
%   data: {"dataType":"text","outputData":{"text":"Parameters defined:\n  R=2 Ohm, L=0.005 H, J=0.002 kg*m^2, B=0.001 N*m*s\/rad\n  Kt=Ke=0.05, V0=12 V, TL=0 N*m, Tsim=5 s\n  tau_elec=L\/R=0.0025 s, tau_mech=J\/B=2 s\n","truncated":false}}
%---
%[output:59de716d]
%   data: {"dataType":"text","outputData":{"text":"Hand calculation (steady state):\n  i_ss = 2.66667 A, omega_ss = 133.333 rad\/s\n  Characteristic poles [rad\/s]: -399.373, -1.12677\n","truncated":false}}
%---
%[output:00ab597c]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAjAAAAFRCAYAAABqsZcNAAAAAXNSR0IArs4c6QAAIABJREFUeF7tnUuIZUtW\/qN8JDkRCxyY4CtL5dqUqFcpiwRfdQTRFqEbwXHmBUcKIgheH4MyB4qFoMM7zMqR7UwQpAUhy0ZBRyZSYNGk5vExyL8D\/2VaYImPksisyIzcd+8da0Ws2Du+fb4DTdfNE7H2it9aK+I7sV\/33r17987xQwIkQAIkQAIkQAJABO5RwABFi66SAAmQAAmQAAlcEaCAYSKQAAmQAAmQAAnAEaCAgQsZHSYBEiABEiABEqCAYQ6QAAmQAAmQAAnAEaCAgQsZHSYBEiABEiABEqCAYQ6QAAmQAAmQAAnAEaCAgQsZHSYBEiABEiABEqCAYQ6QAAmQAAmQQIfAl7\/85au\/fPDBB2TTKAEKmEYDQ7dIICbgJ1NOpMwJEpiGQFxv4d+swWnYa45CAaOhxbYkMAMBTpwzQOchN5pAn4DxQFiLbaUFBUxb8aA3JHCHACdMJgQJzEugW4OsyXnjER+dAqadWIg8CedleW5WhGuyRjmTmqRPX5s4B+IBlpxiKj3fLxmLNBjaHJe0H2tTwnNs3BZMcm1ImHRPUYb\/Hsojic2cPModozSfSttRwJQSrNefAqYe22qWWy\/4agNv2HBOTFJ9hr7X\/j2FbWi7PNWvuwCWCKhgS7tYSNqn2qTiMMahRQGTGm93PJL22jYappq2ubHQ5LIkr618zvWL\/a4JUMAAZkJu8eT2q4moRZ9yxpszjlSfHKGSsplavPz3Whu5fSS+jNmW8ClpI8mD1gSMZLzaBVpis6+NNI+k7VLxsLIzJKYl3FI+8ntbAhQwtjwnsZZbqLn9ag6qRZ9yxpszjlQfycIxJgJ8\/6FP2C0pWXg0E3quL1MJmC4n6W7SlAKmdYZdZqn8lgiFVC0GJv7Y4Xjx31L9h75P+Z76Pve47KcjQAGj49VE627xdAvXOxlPJn0T39D3kvPfAULfItidUGJglj7FDFIT1tDENtYvZtbHpPv9kBDostIu+kPH1vxdm7Q5k3NOnzHxJeEkEXi5baTjmVLASOIoGa+WrdamVpgMzWddP8dEpqReg8iJ58ehOaA7Z+aKM0nM2CafAAVMPrvZevYVfJ9okRSddPLoio+UABpa0C19GhMHfZNfLLi6k1hqfKnvU\/ylPKSLS1\/ySXcNxhJXunBLxYemSLQLpaS9pE2fj1IOfT8OhkS7hoVWBKTaazl0fyBoBbOUn\/c7dSzpHJX6sTAmXDT+dn3OiSv72BCggLHhOKkVaUGnxIJ0UksdT1r8kkU81yfNojw2HsnxU+OQ2JBMglI7EluSBJXGsWTB18TJYlHWMJSIR41wK+GZGvsQR+14Je0lbXLYdccoPU5X8ARhEv4eRGXqR8fY96l6sYht6hj8Pk2AAibNqLkWKUExtKD19RsanEXx9\/06rSWqNAvjFAImh6t0cdRM9BI\/LARQakLvy4Xg29j1OGO+SThI2pQIsrFxp5hIFv2+xbrP31YYasYcC5iuCBljkxPT1Jyp9VvbvrlFZCEOUcAABjJVjBoBIz3tEC9AKREiPX5fO+nkpJlAUry6i0Rqu7zv2BIbUoGSWtikjKSprWE5ZLOmDe14JbFItZGOZ0oBI4lnCauhvJPalDIbq4OxY3UFr6aeNHNAinPuOFN2+b2eAAWMntnsPVLFWCIgNKIi\/gWVEjVBAKXaSY+vmURSvCy+D78gtUxSAjIlllJiJ5WsGo5jtmrZSdlNxU6STxrGJYumNhapsUvFZMpOLYap8Q7VisQfqe0ax0jx1PrG9vkEKGDy2c3SMwiBeMHUTMB9QiK22V2IwwLQHazk\/HHX19Svq9SFwbmLdWpCHOIXjmdxF9IQ15SAkSzAuVyGYpvjazeHYp8kY+yOIcVekyvdcabi2Td+qVgYi4Vk4eur75yJJmWnrybGmKcYDsVfEvvU\/NVnW2JXEwtJbPpqMSc27GNHgALGjuUiLY2JDu0kskhAEw1KOsHWcmfu49ca15R2yVBPu6X5h\/HTx692DwqY2oQXYN\/iF9ACMGzsEDhxl4eeDPMZcv7JZ7f0nhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACJEACJLB0AhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACJEACJLB0AhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACJEACJLB0AhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACJEACJLB0AhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACJEACJLB0AhQwS48wx0cCJEACJEACCyRAAbPAoHJIJEACtwTQ3kOE5i9zjQTmIkABMxd5HnexBOKXz\/GN3fMKiVgMjAmDXNHQ1y\/Efyj2Ej9y\/VlsUXFgJNBDgAKGaUECFQjUWIBKbZb2L8UkFROlx4n7d8c8JDhyhGafUJGOMeXH3LGyjAFtkUAtAhQwtcjS7kYTqLEAldos7V8aUOniXnqc0D8lEsbaSX0YE0iSnRat2JL6xXYksAkEKGA2Icoc4+QEwuIV\/793IvzSj08zdf8e7wZ0+4e2qcUxDLjveNK\/xX51AaYW7u7x\/X8PjSV8N9QnPvaY7ykfYx\/GhEMsbLo2uzs1qThoTiNJdosmT2QekAQaJkAB03Bw6BougTHh4he1ocUqJQxSpzqk\/XOOL9ktyD1+n+2hHRvpQj8kLsZ2grS7VLkCpiumpLtFuBVBz0nAngAFjD1TWiSBO7sNQzsqmr8P7R70oZYu3H27C1Jx0N1RiXdG+saVWrD7dqTGdqlSOyNjvFLCSCNiJKyHymFMSGnizXIjgU0lQAGzqZHnuKsS6J5CCgfL\/bt2QQuLv0RMSHZWxoSSdEcjJRxSjLrfpwIoERdjPvXZl5xCkgogCphUBPk9CYwToIBhhpBABQK5QqW7qHnX+nY3JIvz2K5H6SmkITGRcwppzJc4NJJdnm4oxzjFbFM7RJJdFK3IDO27fuTYqZDCNEkCzROggGk+RHQQjcDQqY94YUq1CYua5pROLCrCv8d2DGIfUhcXSxfweFEeEwh9gqErVlJiaGiMsZ05BEyf6BrjRwGDVuH0txUCFDCtRIJ+bBQB6WmGqaG05lefyNIy0Yyp79Sb9nil7TX+lh6L\/UkAmQAFDHL06DssgVYXqVb9gg00HScBEqhGYDYBc+\/ePffu3btPDcz\/3X\/6vqtGgYZJgARIgARIgASgCMwiYIZESixqhgQOFF06SwIkQAIkQAIkUIXALALGj6RPoFDAVIkxjZIACZAACZDA4gg0JWBiukM7MOv1enFB4IBIgARIgARIAI3A7u7urC43KWDGxMuDB\/MCmzVaPDgJkAAJkAAJNETg\/Hzt5hIyzQmYsWtfXrx44VarJ+7o6IWbWfhlpY\/3\/\/Dw0B0dHc0W8CzH33dC998PA30M6P4zBiUVaNcXPY\/Q\/V9SHZyfn8+2njUpYEKZdu9ECgLm\/NzBCpjVauXmDHjJFHjNH9f\/MGkgj4ExKMlgm76MgQ3HEiuMQQk9m74txGA2AZODkAImh5pdnxYStnQ06GNA958isjSDbfqj5xG6\/6wDmzymgLHhKLLy6tUr9+zZM\/fJJ5+47e1tUZ+WGqH771mijwHdf8agjYpGzyN0\/5dQBy2ISAqYCeeT169fu9PTU7e3twcpYND996FGHwO6\/4zBhBPOyKHQ8wjd\/yXUAQWMspbRTyGhFx26\/0uYNBgD5aRRoTljUAGq0iRjoARWoTkFjBIqBYwSmHFzThrGQDPMMQYZ0Iy7MAbGQDPMMQYZ0Iy7UMAogVLAKIEZN+ekYQw0wxxjkAHNuAtjYAw0wxxjkAHNuAsFjBIoBYwSmHFzThrGQDPMMQYZ0Iy7MAbGQDPMMQYZ0Iy7UMAogVLAKIEZN+ekYQw0wxxjkAHNuAtjYAw0wxxjkAHNuAsFjBIoBYwSmHFzThrGQDPMMQYZ0Iy7MAbGQDPMMQYZ0Iy7UMAogVLAKIEZN+ekYQw0wxxjkAHNuAtjYAw0wxxjkAHNuAsFjBIoBYwSmHFzThrGQDPMMQYZ0Iy7MAbGQDPMMQYZ0Iy7bLSAGXppo\/97+CztXUjoRYfuv88r9DGg+88YGK8imebQ8wjd\/yXUwcYKmCBSugKlK2q6\/80dmMzZyqgbJw0jkAVmGIMCeEZdGQMjkAVmGIMCeEZdN1bAeH59OzAUMEaZVckMJ41KYBVmGQMFrEpNGYNKYBVmGQMFrEpNKWDevbuDVipgTk7Wbnf3uuvOzk6l8Nibvby8vHoX0uPHjyHfhYTuv48o+hjQ\/WcM7OeVHIvoeYTuP2odXFxc3KTber12q9XKnZ+fu92wIOckY0Gf2V7mWLID49wD59z6atgHBwduf3+\/AMF0Xd+8eePOzs7cw4cP3dbW1nQHNjoSuv8eA\/oY0P1nDIyKsdAMeh6h+49aB8fHx+758+d3so8C5j0O6Q7M0dGLOzswKLswftvz5cuX7tGjR5A7MOj++zRDHwO6\/4xBofIw6o6eR+j+o9aB34EJuzD+FNLh4SF3YOKa5F1IRjNUBTM871wBqtIkY6AEVqE5Y1ABqtIkY6AEVqH5Rl8Dk8OTdyHlULPrw0nDjmWuJcYgl5xdP8bAjmWuJcYgl5xdP2gBE++UpJB0b5dOtR\/6ngIml5xNP04aNhxLrDAGJfRs+jIGNhxLrDAGJfRs+sILGIkwGXpgXQ5CCpgcanZ9OGnYscy1xBjkkrPrxxjYscy1xBjkkrPrRwGjZEkBowRm3JyThjHQDHOMQQY04y6MgTHQDHOMQQY04y7QAsazsNxdkbClgJFQqteGk0Y9tlLLjIGUVL12jEE9tlLLjIGUVL128AImiJiASHJKqQQnBUwJvfK+nDTKGZZaYAxKCZb3ZwzKGZZaYAxKCZb3X4SAiTGM3QJdjss5ChgLivk2OGnks7PqyRhYkcy3wxjks7PqyRhYkcy3szgB0ydmLHdlKGDyk82iJycNC4plNhiDMn4WvRkDC4plNhiDMn4WvSlglBQpYJTAjJtz0jAGmmGOMciAZtyFMTAGmmGOMciAZtxlcQKGp5DGMwS96ND999FBHwO6\/4yB8SqSaQ49j9D9X0IdLELA1BYtcX1yByZztjLqxknDCGSBGcagAJ5RV8bACGSBGcagAJ5RV3gBU+M26iCI+q6doYAxyrxMM5w0MsEZdmMMDGFmmmIMMsEZdmMMDGFmmoIWMFLxIm3nGcZt+\/pRwGRmmlE3ThpGIAvMMAYF8Iy6MgZGIAvMMAYF8Iy6UsB0QFLAGGVWJTOcNCqBVZhlDBSwKjVlDCqBVZhlDBSwKjWFFzBSLppbqSWnkE5O1m539\/roOzs7Ujdmb3d5eelOT0\/d48eP3fb29uz+aB1A99+PF30M6P4zBtqqq9MePY\/Q\/Uetg4uLi5uEXK\/XbrVaufPzc7cbFuQ66Tpo9d47jbqo7Jx0B8a5B8659ZU3BwcHbn9\/v7JnNubfvHnjzs7O3MOHD93W1paN0QmtoPvvUaGPAd1\/xmDCgh05FHoeofuPWgfHx8fu+fPndzKLAuY9DqmAOTp6cWcHBmUXxm97vnz50j169AhyBwbdf59m6GNA958xaEPAoOcRuv+odeB3YMIujD+FdHh4yB2YuKQlp5DOz92NgGljOpB5gX7eFt3\/MGn403h7e3uwIhLZf8ZANlfUboVey+j+L6EOoK+BqV1gffZ5F9Ic1G+PyUljXv5LmPSWMAbWAevAggB6HlHAKLOAAkYJzLg5esFx8TROiExz6HmE7j\/rIDNxjbuh5xEFjDIhKGCUwIyboxccJ27jhMg0h55H6P6zDjIT17gbeh4tRsDErxMIMa5xcxMFjHEFKc2hFxwnbmXAKzVHzyN0\/1kHlRJbaRY9j+AFzNgFt2PfKeN805wCJpecTT\/0guPEbZMHpVbQ8wjdf9ZBaQbb9EfPI2gBI31FgLSdJCUoYCSU6rVBLzhO3PVyQ2MZPY\/Q\/WcdaLK1Xlv0PIIWMPXCOmyZAmYO6rfHRC84Ttzz5k84OnoeofvPOmAdWBBYlIDp22mx3H3xwClgLNIu3wYn7nx2Vj0ZAyuS+XYYg3x2Vj0ZAyuS+XYWIWD6LuANSKwv5KWAyU82i56cNCwoltlgDMr4WfRmDCwoltlgDMr4WfRehIAJIKx3W\/oAU8BYpF2+DU4a+eysejIGViTz7TAG+eysejIGViTz7SxKwORjkPekgJGzqtGSk0YNqjqbjIGOV43WjEENqjqbjIGOV43W0AJGuuMibRfv5IR\/d09BUcDUSEO5TU4acla1WjIGtcjK7TIGcla1WjIGtcjK7UILGD9M6+fApMQOBYw8uWq05KRRg6rOJmOg41WjNWNQg6rOJmOg41WjNbyA6ds1Gdo9kQCMLwjuuwCYAkZCsV4bThr12EotMwZSUvXaMQb12EotMwZSUvXaLUbAWCGKd2D6dmOCgDk5Wbvd3euj7uzsWB2+up3Ly0t3enrqHj9+7La3t6sfz\/oA6P57HuhjQPefMbCuyjx76HmE7j9qHVxcXNwk3Hq9dqvVyp2fn7vdsCDnpWN2r3vvjO51tnh1gFTAOPfAObe+GvTBwYHb39\/PBjBlxzdv3rizszP38OFDt7W1NeWhTY6F7r+HgD4GdP8ZA5NSLDaCnkfo\/qPWwfHxsXv+\/Pmd\/FuEgAkjKhEyUgFzdPTizg4Myi6M3\/Z8+fKle\/ToEeQODLr\/PkfRx4DuP2NQrD1MDKDnEbr\/qHXgd2DCLow\/I3J4eLiMHZhuVeUKmbF+vAbGZO7KNsLzztnozDoyBmYosw0xBtnozDoyBmYosw0t8hqYXOEioUgBI6FUrw0njXpspZYZAympeu0Yg3pspZYZAympeu0WJWBqCpcQAgqYeskoscxJQ0KpbhvGoC5fiXXGQEKpbhvGoC5fifVFCRjJgEvbUMCUEizrz0mjjJ9Fb8bAgmKZDcagjJ9Fb8bAgmKZDQoYJT8KGCUw4+acNIyBZphjDDKgGXdhDIyBZphjDDKgGXehgFECpYBRAjNuzknDGGiGOcYgA5pxF8bAGGiGOcYgA5pxFwoYJVAKGCUw4+acNIyBZphjDDKgGXdhDIyBZphjDDKgGXehgFECpYBRAjNuzknDGGiGOcYgA5pxF8bAGGiGOcYgA5pxF2gBk3rxYmAlbSdhSwEjoVSvDSeNemyllhkDKal67RiDemyllhkDKal67RYnYPrECgXMbQKhFx26\/z4S6GNA958xqLegaCyj5xG6\/0uoAwoYTcU557gDowRm3JyThjHQDHOMQQY04y6MgTHQDHOMQQY04y4UMEqgFDBKYMbNOWkYA80wxxhkQDPuwhgYA80wxxhkQDPusggBE57AO8Ym54XXfaeeKGCMM1BpjpOGEliF5oxBBahKk4yBEliF5oxBBahKk4sQMPGYra6BGXotAQWMMsOMm3PSMAaaYY4xyIBm3IUxMAaaYY4xyIBm3IUCpgdoEEHcgTHONgNznDQMIBaaYAwKARp0ZwwMIBaaYAwKARp0p4DpQIxFy5iAOTlZu93d6847OzsGoZjGxOXlpTs9PXWPHz9229vb0xzU8Cjo\/nsU6GNA958xMCzIAlPoeYTuP2odXFxc3GTder12q9XKnZ+fu92wIBfkZE7Xe+9yLlBxzklvj5a28873XU8TuxdOITn3wDm3vhrvwcGB29\/fzxn75H3evHnjzs7O3MOHD93W1tbkxy89ILr\/fvzoY0D3nzEorUKb\/uh5hO4\/ah0cHx+758+f30lCWAGTKqVMbXRldmwH5ujoxZ0dGJRdGL\/t+fLlS\/fo0SPIHRh0\/31eoY8B3X\/GIDVrTvM9eh6h+49aB34HJuzC+A2Fw8NDzB0YSZkNXYwr7dsVQLyIV0KuXhued67HVmqZMZCSqteOMajHVmqZMZCSqtcO+hqYeliGLVPAzEH99picNOblH361+euo9vb2IHfxljAG1gHrwIIAeh4tQsDE1630nTIq2YXpJgkFjEXZ5NtALzgunvmxt+yJnkfo\/rMOLLM53xZ6HkELmLHbnbsh1VzIO5YOFDD5xWLRE73gOHFbZEG5DfQ8QvefdVCewxYW0PNoMQLGB9PvvgzdRUQBc53u6AmL7j9jYDHtlttAzyN0\/1kH5TlsYQE9jxYpYIKQ6fv\/0qBzB6aUYFl\/9ILjxF0Wf6ve6HmE7j\/rwCqTy+yg59FiBEy49qV7WklzmkmSChQwEkr12qAXHCfuermhsYyeR+j+sw402VqvLXoewQsYaWhLngcTH4MCRkq8Tjv0guPEXScvtFbR8wjdf9aBNmPrtEfPI3gBE58m8iEe2oGxCj8FjBXJPDvoBceJOy\/u1r3Q8wjdf9aBdUbn2UPPo8UIGB++mte+hPSggMkrFKte6AXHidsqE8rsoOcRuv+sg7L8teqNnkeLFDDd4FqdPvJ2KWCsSifPDnrBceLOi7t1L\/Q8QvefdWCd0Xn20PNoMQLGUqSMpQIFTF6hWPVCLzhO3FaZUGYHPY\/Q\/WcdlOWvVW\/0PIIWMCGIqSfxaoM99uReChgtTdv26AXHids2H3KtoecRuv+sg9zMte2HnkeLEDCWIY0feDf2Nurzc3fzNmrL49e2hZ6w6P5z4q6d4TL76HmE7j\/rQJantVuh5xEFTCdDKGBql0yZffSC48RdFn+r3uh5hO4\/68Aqk8vsoOcRBcxI\/Md2YE5O1jc7MDs7O2VZNGHvy8tL598k\/PjxY8g3CaP770ONPgZ0\/xmDCSeckUOh5xG6\/6h1cHFxcZNV6\/XarVYrd35+7nZ3d2dJ7HvvproCVzG8oXcnhWtgnHvgnFtfWTw4OHD7+\/sK6\/M1ffPmjTs7O3MPHz50W1tb8zmSeWR0\/\/2w0ceA7j9jkFl8xt3Q8wjdf9Q6OD4+ds+fP7+TjRQwEY6xFz8GAXN09OLODgzKLozfMnz58qV79OgR5A4Muv9h65wxMF4NlebQ8wjdf9aBMmErNUfMI78DE3Zh\/Hp8eHjIHZg4P8buauJdSJUqSWgW\/ZxtmLj9aby9vT1YEYnsP2MgLLbKzdBrGd3\/JdQBr4FRFikFjBKYcXNOGsZAM8wxBhnQjLswBsZAM8wxBhnQjLtQwCiBUsAogRk356RhDDTDHGOQAc24C2NgDDTDHGOQAc24CwWMEigFjBKYcXNOGsZAM8wxBhnQjLswBsZAM8wxBhnQjLtQwCiBUsAogRk356RhDDTDHGOQAc24C2NgDDTDHGOQAc24CwWMEigFjBKYcXNOGsZAM8wxBhnQjLswBsZAM8wxBhnQjLtQwCiBUsAogRk356RhDDTDHGOQAc24C2NgDDTDHGOQAc24CwWMEigFjBKYcXNOGsZAM8wxBhnQjLswBsZAM8wxBhnQjLtQwCiBUsAogRk356RhDDTDHGOQAc24C2NgDDTDHGOQAc24CwWMEigFjBKYcXNOGsZAM8wxBhnQjLswBsZAM8wxBhnQjLtQwCiBUsAogRk356RhDDTDHGOQAc24C2NgDDTDHGOQAc24CwWMEii6gHn16pV79uyZe\/r06Wxv71Qiv9Mc3X8\/GPQxoPvPGJRUoF1f9DxC938JdUAB01OPS34XUgsBL5kC0f33Y0cfA7r\/jEFJBdr1Rc8jdP9ZBza5fO\/du3fvbEyVW+m+ibr73+g7MOhFh+4\/J43yGrWwgJ5H6P6zDiyyuNwGeh614D+kgDk5Wbvd3fIEmtrCer12q9XKnZycQJ5CQvffxxt9DOj+MwZTzzr9x0PPI3T\/l1QH5+fns61nUALGJ+2DB165PPBLURszAb0gARIgARIggQ0k8OTJk6sf5HN9oARMUK1eyPBDAiRAAiRAAiQwH4Hd3d3Zdl\/8qOEEzHyh4pFJgARIgARIgARaIdCUgLlSVPfu3bBp6PriVuJFP0iABEiABEiABFrbgWFESIAESIAESIAESEBCoLkdmCGnEXdmxnyOv\/NjRtht6t7WLkmwuduM+YwaA5R8CbEPnPtynDGYpkKWFoM4txDmzjjKfXMSWh204i+EgEk9H2aaKUB3lJTPaGJgbALUkZmudcpnxBiEyRrF99jPoYkbaQFKjWe67JYfKeUzSi51R5yqbzmh6VoO+YwWg1b8pYCplLsSARMOjTKBt5K0mpBJd2AQYpBaiDRcpmqb8nlsl3IqH3OPs5R6QIxBYI8UgzGf0WLQir8UMLmzV6KfRMAg\/5quhM3cbErAoMVgiVvniDFAWjhTOZMSmeZFWWgQzV8\/3JTPqe8LkZl3b8VfChjz0F4bTAmY1DnRSm4VmV3SpN23HY2wC9OXW0VBnaizJHckbSZyV3QYNH8luYMwpvjXP8outsZnhBi0sn5RwIimKn2jlIBpRcFqRoZWWKkJmzHQRD+\/7ZJ2wdBzpi8WiGNK7SrlZ2v9nkuIQSs5AyFgwkKEorbj4urzOT4X6r\/nL\/96k8bQ4okcA9ZBvXyRWA6\/plHqNp4\/uz6j1sGSBAxqDFqoAxgBI5lY2IYESIAESIAESGAzCFDAbEacOUoSIAESIAESWBQBCphFhZODIQESIAESIIHNIEABsxlx5ihJgARIgARIYFEEKGAWFU4OhgRIgARIgAQ2gwAFzGbEmaMkARIgARIggUURoIBZVDg5GBIgARIgARLYDAIUMJsRZ46SBEiABEiABBZFgAJmUeHkYEiABEiABEhgMwhQwGxGnDlKEiABEiABElgUAQqYRYWTgyGB6Qh8+ctfdh988MF0B+SRTAkgxQ\/JV9Mg0dgoAQoYJogJAT\/BhM+mLWpzTK4lxyzpG2JsYcMk8QyN9I0p5HU3p4f+HvPx\/5b2S9nLHeZQnErjV9o\/ZzxzHDPHT\/aZjgAFzHSsF3uk7sQinWik7YbAlfa3CsgcflgdM9dObj8r5tZ2+gREPEbJv\/vEnaTfUBuLMVoKmJp+Ssa6tJyTjJltxglQwDBDigiUTJClE1Jp\/6KBR53n8MPqmDl2cvpYsa5MWsw3AAAgAElEQVRpZ0yIS4QIioDJjd\/cAsbzzfW9Zt7Q9nwEKGDmY7+II6cEzNCiEH7xhm32+L\/jrXdN\/6FTV91jxRPh0C\/vODjermZxC32DP6FvitXQAti1153I+8YX2oz17YtBzFDqr+ZYQyyH\/OzGYexYYwXVza84x\/q4d21pWMR9tf1S7bsiQsNtaJxD+dMdR3ysOKe7LDX52K2NsTqjgFnEkmE6CAoYU5ybZ0wz4fYtvN1FvjvJSoWDlPzQxNsnMsZ+cUp+jY5N8mOL3JDg6TvmmMAbEiNDvqcWj7EFcOxYYYGLxWJqjBK+1gtaXy7HPvct6CnRbHUNzJAfmnrp4yWN+ZBoTol0SZxjAZTyZ2i+kdY\/2y2LAAXMsuI5+WgQBEz8izBeTPsW3b62qYl\/6Ffx0LH6gjQkoLptcxeMIcEkFUASwdUncFJiqcu7K3aCzW6sYn+sLhofWxxTeT5UeNp+mvaavB4SnxoRKBH0Y\/Ecqrc+kde3U6fxdfKJkAechQAFzCzYl3PQ1IQ79otKOiFKdhKkC4jkF2HfgigZR44YGPsFLVlQc46Zw72mgJHwHlqA+8RjLPKGBFH8q19qu2+3cGjXJtU2Jey6+SzdmZDk6ZCA7mNiJXw1eTpUoxQwy1k3rEZCAWNFcoPtSCfN8OssNbnHE1VqgRo6BZValMYm1L5f9xI\/NJP00CIydg1K36InPaZmwRwTTn1cNfHX7CCl4jCUJ7kLXck4JAu9JAapHwS5eT3EJCWMJOOSxEGap0Pjy43pBk\/LGzF0CpiNCHP9QQZxMvTLNv4lrDl1EyauVP+xEca+peykFrG+\/n3iJvgztBUuETDx2Ltch445dKpFKoykC0Ufp3jMKaGT8l8Sh+7x+gRyXz4O5crQbkoqp4fGKu3XzfGc3IiPJcn3rjDpi92YH9L4pPJRKtikeVl\/puMRWiJAAdNSNDbYF8mv\/qnwjImxqXyY6ziaOGja5oxHE4duW03fHN\/Ypx6BISFpda1TPc9peWoCFDBTE+fxegnUXgyJPU2AMUgzYou6BJiDdfkuzXp1AXPv3j337t27O9z83+JP\/H38Xbff0uBzPCRAAiRAAiRAAnkEqgqYIEb6BEyfOOmKnT7xkzdM9iIBEiABEiABElgSgaoCxoNK7cB0d1\/G\/ntJ4DkWEiABEiABEiCBfAKzCZggVGKBI9mBWa\/X+aNlTxIgARIgARIgARMCu7u7JnZyjcwiYGJnNQLGi5ePPvrIvXjxIne87EcCJEACJEACJGBA4MmTJ+7o6MjNJWRmETBDoiW1A+OFy2q1mhVYScy9\/4eHh\/S\/BGJhX8agEKBBd8bAAGKhCcagEKBB96XE4Pz8fLMEjI\/92AW+ITe6F\/oGATMnsJK8pf8l9Gz6MgY2HEusMAYl9Gz6MgY2HEusMAYl9K77ju7AdG93HjvcFLc8M+DlAS+xgM7fjx19DOj+MwYlFWjXFz2P0P1nHdjkclLASITJVLc7oyftq1ev3LNnz9wnn3zitre3bSI4oRV0\/z0q9DGg+88YTFiwI4dCzyN0\/5dQBy2sxxQwE84nr1+\/dqenp25vbw9SwKD770ONPgZ0\/xmDCSeckUOh5xG6\/0uog+YFTBuldutFC8BKmKAXHbr\/S5g0GIOSCrTpyxjYcCyxwhiU0LPp28J6rL4Laey2Zxssw1ZaAFYyRvSiQ\/efAqYke+36oucRuv+sA7tcLrGEnkctrMcqAdMnXqa6\/sUnSgvANjlh0QuOE3dJ9tr1Rc8jdP9ZB3a5XGIJPY9aWI8pYEoyUNkXPWHR\/efErUzYSs3R8wjdf9ZBpcRWmkXPI1gBM9dppBaAKXP0TnP0hEX3nxN3Sfba9UXPI3T\/WQd2uVxiCT2PWliPVTswPlhziReeQiopFZu+6AXHidsmD0qtoOcRuv+sA0UGx+\/e8+\/9Sf23Ny18X5\/PI387+Icffvjpu1JTNrq+dIfkv\/ev3Om+q6jrf+xv3\/ji77\/hG5z76q++Gd\/63\/7NHf7iL7qnrT6Jd8rrWyQp1YLik\/g51AZ94kP3nxN3Sfba9UXPI3T\/e+vAL2x9L+aLF7xum+4C2f3e\/3ff37wD\/\/u\/zv3Lvzj39V\/v3Nu31\/+OP6kF\/P0jEe6\/fi1LTIE9mSG26hJYtypgwo6L\/3\/JA+1qh5YCpjbhcfuLnLjnRao+OmOgRmbeoTgG8aLet7AOLbb+7\/\/xH8798z8796\/\/er3wh4\/UDhdyWT6UvGVZ2Pft27fO\/+\/+\/ft3fRrq\/xVfcS38hj737jm3teXcf\/+3c77tN3\/zdY74Pn7n5Ou+zrmv+Rrn\/ud\/nNvZce4\/\/9O5f\/93577pm\/ypFef+8R9vd4+8D91dnM4OjX+58vPDQ3fQsoAJrIbeXSTLBptWFDA2HHOtFE\/cuQc27Ic+BnT\/fSibHUPf4u53GfwnLCrr9dWic\/FXf+V247zs9u3uXBjmcBVTY4vu0Hfdv3\/VV10vnv7zjd\/o3Ld92+2C+OTJ9b9j8RYviBHfG94jp2yuTr+8fdt\/+iUA6rNfBV6e0WbrQDicFtbjrGtg\/Pjm2JFpAZgwtr3N0BMW3f+mF09hYjEG70FJxMbf\/71zf\/3X179GLy9vF9M5xUWfGOj+zf+3\/8XsP\/4Uy3d+5+1uS9w2JQZGFnL0PEL3fwlzUQvrsVrAhJqYY0emBWDCdYYCpgRUxb7oEx+6\/2HifvXFL17\/er64uN2qjuP+539+vR3+t397+9fwC75GfvSJiHjn5Tu+w7n\/+q+r7Xa\/A+O3z3efPLl78WWfjaFrS2qMQWETPY\/Q\/aeAUSTrSNNsARMLmal2YyhgbIKea4WTRi45u35NxqArLMK58z\/7M+e+8iud+7u\/uwZgKUBisRD+7f\/\/a7\/WOX9NwQ\/9kHP\/9E93L0yV7H4IQtVkDAR+x03Qx4DuPwWMMmEHmhcLGBs3ZFYoYGScarXipFGLrNzuJDHoO8Xi\/\/YXf+Hc2ZmJGHm7s3O9exGLDy88vADxH3\/NRPyJ28lxVWk5SQyqeH5rFH0M6P5TwNgkeFLAhFNFY4fjDowsGOhFh+7\/EiaN4hjEuyD++pC\/+ZvbnZGcO1S6OyHf\/d3XIuRbv\/W2KMIdDf4vu7vtXsQrK2N4\/1kHwkBXblZcy5X9S5lvYUMhKWDiQfQ9F2bKZ8W0ACwV1LHv0RMW3f\/FT9zhuRx\/+qfXuyVBrGiFSbzb4f\/9vd\/rnBcm3YtGhbeLdmsCPY\/Q\/V98HZRM0hP2Rc+jFtZjChgmrJgAesFBT9zvxcjVLbxf+ILb\/Yd\/0F1T0hUl3\/Itt6dvwumaTEEiTqD3DdHzCN1\/6DpYSA4tIQYUMMqZrwVgSpfvNEef+ND9b3rSCLsk\/v9PTpz70pfkAiUWJ9\/1Xc799E\/f3S3pXk9SksQGfdHzCN3\/putAmF+MgRBUxWYtrMeqHRjPontNzFTXv\/hjtwCsJB\/Qiw7d\/1kn7ligeEeOj69FRnhQ2lhihWtI\/PUj3\/M9bu2c+8xnPnN9EWxj4kRSH+h5hO7\/rHUgSRBBG8ZAAKlykxbWY7WAqcxk1HwLwErGj1506P5Xn7jDNSJBlEhFSthB8WLkB3\/w+gmm\/hNf\/Mqt85LSM+3LOjDFmWWMMcjCZtqphfVYLWD67kqaahemBWAlGYBedOj+mwmYsJvihYr\/d7geZWw3JRYpP\/Ij12nkBYvyuhPGoKQCbfoyBjYcS6wwBiX0bPq2sB6rBEy44yi+84h3IcmTAb3o0P3PFjDhbh7JjkrYNfnhH3ZuterdRZFnzKdbbmwMSqAZ92UMjIFmmGMMMqAZd6GAUQJtAZjS5TvN0YsO3f+kgAnXpPj\/90+RTe2o+B2UH\/gB5779282FylCeLT4GJQU2UV\/GYCLQI4dhDOaPQQvrMXdgJswD9KJD9\/+OgPFPgv3Lv7x+xfzv\/u6wWAk7Kj\/5k859\/\/dPJlQoYCYsTOWhFlUHe3t33+ekZDFXc8ZgLvK3x4UTMDEyvsxRn0DoRQfrf9hZ8bsqY3f+eLHid1X292cXKhQw+vqaqgdsHUSA0MeA7n9yN3iqZC44DrSAKRh3dtcWgGU77xz8I8hhJo1YsIQLbbuBi8WK\/w7kdmSYGCx4+58xKJkFbfoyBjYcS6y0sB5nnUIqGXRJ3xaAlfiPXnRN+h8usPVCZei6lXAa6OlT9\/r+fXf6+rXb49Z5SSoX9W0yjxQjQvd\/Cb\/+GQNFwlZq2sJ6rBIwnoP2rqOh9vHt2PFt2EN\/98duAVhJLqAXXTP+e7EydkdQ2F15+vQ6XNGtys2MITOR0P3n4pkZeONu6HmE7v8S6qCF9VglYIbeTD30HJih62S6oqbv9uw+sdQCsJJ5BL3oZvE\/tcMSxMkv\/ZJzP\/VTyeeqzDKGkqTp9EX3fwkTN2NgmNCZphiDTHCG3VpYj0cFjHS3Zayd5A3WFDCGWVXR1GSThhctz5\/3nxKKTgf1Pak2NfzJxpByJPN7dP8pYDIDb9wNPY\/Q\/V9CHVDAvC9KrYA5OTlxu+9\/ee\/s7BiXdj1zl5eX7vT01D1+\/Bjy1sWq\/r944bb\/4A+uhUv0eRvi+yu\/4tyP\/3hyhyUVvapjSB3c4Ht0\/z0C9DGg+88YGBSigQnEPLq4uLgZ+Xq9dqvVyp2fn9+sxwZYVCaSOzBSa2OnkbrflZ5Cin06ODhw+\/62V4DPmzdv3NnZmXv48KHb2toC8Piui9b+3z89dbvHx87\/f1e0\/P\/v+z73\/37sx9zrDz805WQ9BlPnBMbQ\/fdDRB8Duv+MgaDQJmiCmEfHx8fueedHZrMCxiKGNU4hHR0d3dmBQdmF8dueL1++dI8ePYLcgSn2\/\/3Ft\/f\/8A\/vptb700JvP\/74aoflZtfFIgE7NorHUMEnjUl0\/\/1Y0ceA7j9joKm4em0R88jvwIRdGH8K6fDwsN0dGIvQ8S6kW4ro523V\/sfvEOqo9qvrV37mZ5z7uZ8rPi2kyVP1GDTGJ2iL7n9YPP2pVN7KPkHCDBwCPY\/Q\/V9CHTR\/Dcx85dV\/5BaAlTBBLzqR\/0G0HB5++vH8XrT4W5sz3sJcwj3uKxqD1cEq2EH3fwkTN2NQIbGVJhkDJbAKzVtYj1W3UVdgoDLZAjCVwz2nLxb7y9OfHuqKlsI7hkpYD\/VFn\/jQ\/aeAqZHVepvoeYTu\/xLqoIX1mAJGX\/vZPdCL7lP+hwfKxaeHYtHS4OP5FxeD7GycryNjMB\/7cGTGgDEoJUABoyTYAjCly3eaL2HSePXFL7q9L33JuU8+uR1b46KFp5BKsta+7xLqAHkndQm\/\/tFzaAkxaGE9Fu\/A9D2Fd+jWafsp79piC8BKxgZbdOHliP4Ukf93+DRwTYs2HrAxeD9QdP+XMHEzBtqqs2\/PGNgz1VpsYT1OCpih1wH4wY59p4Uhad8CMImfQ22gim7gYlx\/i\/P2b\/6mcz\/6o5PePVTCnTswVvRs7EDVQc+Q0f2niLTJ41Ir6HnUwnqcfJCdZJdF+sqB0oC3AKxkDDAJ608P+dub452WJ0\/c6899zp3evw97+ysn7pLstesLUwcDQ0b3n3Vgl8slltDzqIX1OLkDUxIg674tACsZU7MJ63db\/Omg1erurc\/hFNHBwdWwm\/VfERT0MaD7v4Q8YgwUBVepKWNQCazCbAvrsUrASJ6qqxi\/umkLwNRORx2aK7pwbctHH93dbfnsZ5375V\/+1Cmi5vzPCAb6GND9p4DJSNoKXdDzCN3\/JdRBC+uxSMD0XcAbakpyismq\/loAVjKWZorOCxd\/QW739uejo+uHzHHrvCTMVfs2k0MFo0QfA7r\/S1g8GYOCAjTq2sJ6LBIwYbxTXesyxLcFYCWxn7Xo+i7K9aeIvGDxT8d9\/3bvsfHN6n8J+JZ3wZTjYgyUwCo0ZwwqQFWaZAyUwCo0b2E9VgmYCgxUJlsApnK403iWouu7BTrz9udZ\/C8B3tMXfQzo\/vPXv3FCZ5pDzyN0\/5dQBy2sx7wLKXMCyOk2adENXd\/id1veX5SrHcOk\/mudE7ZHHwO6\/0uYuBkDYbFVbMYYVIQrNN28gPHj4HNghNEUNJuk6Lxw+f3fd+7Xfu3Wo87dRAJXe5tM4n+uc8J+6GNA958CRpiolZuh5xG6\/0uoAwgBE+qIT+Itn1GqFp0XLv6iXH9xbvj4nZb9\/dELczWjquq\/xpGCtuhjQPd\/CRM3Y1BQgEZdGQMjkAVmYAXMlHcexXxbAFYQ7zrPUekKF+WFuZrxcNLQ0KrTljGow1VjlTHQ0KrTljGow1VjtYX1OOsi3qlfIRCgtgBME+BuW9Oi88Llj\/7IuV\/4hevDVBQuYRym\/peALOiLPgZ0\/7kDU5C8hl3R8wjd\/yXUQQvrcZaACXU09W3VLQArmUNMis4Llz\/+Y+d+\/ufvChf\/DJfKHxP\/K\/uYMo8+BnT\/lzBxMwapKqv\/PWNQn3HqCC2sx0UCxg9wShHTArBUUMe+Lyq6oWtchM9wKfGbOzAW9GxsFOWQjQvFVtDHgO4\/RWRxCpsYQM+jFtZjtYDpnj6igJHnclbC9j3HxfjiXOkIsvyXGp+oHfoY0P3n4jlRoicOg55H6P4voQ6gBExXqMR3JU11UW8LwEqmH3XRhbuKvIjxH3+dS+Jx\/yX+pfqq\/U8ZnOF79DGg+7+EiZsxmKFwO4dkDOaPQQvrsWoHpk\/ETCVefLhaAFaSNuKi84LFv2DxxYtb4VLwALoSn+O+Yv+tDljBDvoY0P2ngKmQ1Bkm0fMI3f8l1EEL67FKwHjoc4qYFoBlzBU3XURF9zu\/c\/0m6LDj0oBwCQMQ+V8CaIK+6GNA938JEzdjMEGhJg7BGMwfgxbWY7WACSLG\/7\/ffeE1MPJEGiy6vme5NCRcKGDkMa7dkhN3bcJp+4xBmlHtFoxBbcJp+7ACJgxtSvHij9kCsHRYh1v0Fl3f6aKTE9HboUt8yenLSSOHmm0fxsCWZ441xiCHmm0fxsCWZ461FtbjrB2YnMFa9GkBWMk47hTdxcXdR\/8bva+oxL9UX04aKUL1v2cM6jNOHYExSBGq\/z1jUJ9x6ggtrMcUMKkoGX5\/U3SvXrntZ8+c87svXrj8+q8797M\/a3ikOqY4adThqrHKGGho1WnLGNThqrHKGGho1WlLAaPk2gIwpct3mr999cpdPHvmdv3t0f7jxUujp4v6xslJoyT6Nn0ZAxuOJVYYgxJ6Nn0ZAxuOJVZaWI+5A1MSQU3f3\/iN2zdFA5wuooDRBHe6tpy4p2M9dCTGgDGwIICeRxQwyixoAZjS5evTRNEzXS5+4ifc\/d\/7Pbf9mc+oTc3dAb3gPD\/0MaD7zxjMXcXXx0fPI3T\/lxCDFtbjWXZg4qf4+kDGD8Mbe8JvC8BU048\/VeTFi\/\/s7rrXn\/+8O\/3c59ze3p7b3t5WmWqhMSeN+aPAGDAGFgTQ8wjdfwoYiyx2bjYB0\/cE39RD8mAETPe5Lv7dRU+futf377vT01MKGJvczbKCPvGh+7+EiZsxyCo9006MgSnOLGMtrMdJARNExdgzX7TPgxnaZZEKmJOTE7frryNxzu3s7GTBr9Vp+wtfuNl1eet92993zl\/\/4py7vLy8EjCPHz+G3IFB958xqJX1OrvoeYTuP+tAl6+1WiPm0YV\/\/Mf7z3q9dqvVyp2fn9+sx7VYDdmdTcCEHZhYtEgFTDyYg4MDt+9Fwsyf7YsLt\/Mnf3Jzh9HrDz90rz7+2F2JmPefN2\/euLOzM\/fw4UO3tbU1s8f6w6P770eMPgZ0\/xkDfd3V6IGeR+j+o9bB8fGxex7uon2fmM0LmG4BhVcI+L+Xvk4gR8AcHR3d2YGZfRdmvXbbn\/2s8yLm6tZof7ro85\/\/1Lzjtz1fvnzpHj16BLkDg+6\/Dwj6GND9ZwxqyBG9TfQ8QvcftQ78DkzYhfGnkA4PD7F2YLqnlLSnj3zghkSLdAdmTsX3qamie3v0yHNd0M\/bovsfJg1eh6Rf8Cx7oOcRuv+sA8tszreFnkfNXwMTrlWJd1ksBEwQMWEHJ04BqLuQ\/B1GYTvNv3zx\/bUuQymNnrDo\/nPizp9sLXui5xG6\/6wDy2zOt4WeR80LmHi3ZEi45OzA5Ia8BWBXvvu7jFar21cBHB059+RJcljoCYvuPyfuZIpO0gA9j9D9Zx1MkubJg6DnUQvrsegi3m4kLK+BSUY5atACsKtdlsPDa6+UrwJAT1h0\/zlxa6qtXlv0PEL3n3VQL7c1ltHzqIX1WCRg+i7UHbv4VhNETdtZgXWf7SI4ZdQdG3rCovvPiVtTbfXaoucRuv+sg3q5rbGMnkezrsfvQWcLmDhQU51Gmg1Y5ikjChhNOU\/TFn3SQPefi+c0eZ46Cnoeofu\/hDqYbT2OklskYMaKoe+Juqniyf1+FmCd1wGUvD0avejQ\/V\/CpMEY5M4edv0YAzuWuZYYg1xydv1mWY877icFTGq48Z1Kqbal308OLBYvGaeMuANTGnH7\/ugTH7r\/FJH2OZ1jET2P0P1fQh1Mvh73JHqxgMkpntw+kwILF+u+fzCd8+8zKvygFx26\/0uYNBiDwiI06M4YGEAsNMEYFAI06D7pejzgb1LAxLdPBxvd1wAs6hoYo+td+nijFx26\/xQwBrOWgQn0PEL3n3VgkMQGJtDzCE7A9D3QzsdxMQKmK15Gnqqbk7\/oCYvuPyfunKy174OeR+j+sw7sczrHInoewQoYH6z44t1FCBgvXh48uM5Df9ro\/DwnJ0f7oCcsuv+cuM1TOssgeh6h+886yEpb807oedS8gIkf65+K3hR3I1UDFl+s+9u\/7dzHH6eGm\/U9esKi+8+JOyttzTuh5xG6\/6wD85TOMoieR9XWYwVN1TUw3SfwhuPA7sAYPJxOwfrqTch8kaCGmH1bxsCeqdYiY6AlZt+eMbBnqrWIHgNYAdN9Mi+kgInFiz9ltL+ffBmjNkG77dETFt1\/\/vIszWCb\/uh5hO4\/68Amj0utoOcRnIAJAYO\/C8mLF\/8m6Rcvrq93Eb6McdMTFr3gOHGXZrBNf\/Q8QvefdWCTx6VW0PMIQsCkgjTV7ov3wwRY5TuNxnihJyy6\/5y4U9U8zffoeYTuP+tgmjxPHQU9j0zW4xSkxPfia2C8nb6Leqe4eDeMoRjYjOKFk0Zhphp1R5800P1nHRglcqEZ9DxC938JdVC8Hhfm8JUmeTeiQLq7K327LTA7MDOLlyUkLCcNg4orNMEYFAI06M4YGEAsNMEYFAI06N68gOmOcUisTCViioD5Z7x4EVPpGS+SfEAvOnT\/KSIlWVq\/DXoeofvPOqif45IjoOdR0XosASRokzyFJLAxWZMsYPED6vz7jPwFuzN90BMW3X9O3DMlfuew6HmE7j\/rgHVgQSBrPbY4cGRj2QKmIfHCScM4czPNoS8+6P6zDjIT17gbeh6h+7+EOoARMJIn8k5xMa8KWGPiZQkJy0nDeBXJMMcYZEAz7sIYGAPNMMcYZEAz7qJaj42PHcyJdmDiN1J3H2LnDTV3DUyD4oUCplIGK82iT3zo\/rMOlAlbqTl6HqH7v4Q6oIBRFqcIWCxenj6t\/nRdzRDQiw7d\/yVMGoyBpuLqtGUM6nDVWGUMNLTqtBWtx3UOfWM1eRt1aBnvvEy149IdexJYozsvYRzoRYfuPwVM5dlEaB49j9D9Zx0IE7VyM\/Q8Sq7Hlfldnf2RPAdm7gfYBQ6jwGLx8lu\/5dyv\/uoE+HSHQE9YdP85cevytVZr9DxC9591UCuzdXbR8whKwDS9AxM\/pG7mW6XHUhg9YdH958Stm2BrtUbPI3T\/WQe1MltnFz2PKGB08e5\/FxKIeOGkoQx2pebokwa6\/6yDSomtNIueR+j+L6EOmhcwV+eY7t27Ko0md2Bi8fLkiXMnJ8oynrY5etGh+7+ESYMxmLZm+47GGDAGFgTQ8whCwMQipi9oUzz\/JRz3DjD\/x9Vq9tcDaBL51atX7tmzZ+7p06du17\/SAOyD7r\/HjT4GdP8ZgzaKHj2P0P1fQh1ACZghoRLv0FiUZnzBcPeYN8BOTtzu4aFzL17M+m4j7XhbCLjW57g9uv9+LOhjQPefMSipQLu+6HmE7j\/rwCaXRQ+yszlU2krq7dc+aT9ardzJ7q7bDS9m9KeNQHYz0IsO3X9OGukanKIFeh6h+886mCLL08dAz6MW\/IcTMCerlTt0zq19fgCJF+\/uer12Ky\/A\/A4SiOiKyxDdf8YgPalO0QI9j9D9Zx1MkeXpY6DnUfD\/\/Px8tvUMSsB4YLsPHlyJl4\/86YB0jrAFCZAACZAACZBABQJPnjy5+kE+1wdKwIRfDl7I8EMCJEACJEACJDAfAX8mYc6zCXACZr5Q8cgkQAIkQAIkQAKtEGhKwHgoY3chtQKNfpAACZAACZAACcxLoDkBMy8OHp0ESIAESIAESACBAIyAQdyZGfO5+4LMKR8ImJuYc72FPNffsKOXeoZRsI8SA+8vgq+B69izolDrgDEoqUq7vkuZk9DqoBV\/IQRM6vkwduVgZynlM1rhWT+w0I70sKWUz4gxCMIFxffYzz6fUcYRizHGYIrqTR8jVd9pC9O3GPIZuQ6mp3h7RAqYSvQlAgbpl39qN6MSxmKzYxMD2q5eSgwUw6pgIOUzWgxiRGiLzlANI8YgsEeKwZjPaDFoxV8KmAqTdt9EMSZoUIoQxU\/pIpNaXCulhonZpcQCNQZL4d+dqxDGhZgzKZ9T35tMGoZGWvGXAsYwqGMLZ2onAOGaBoTJrRtOqc\/SdpXSRWUWyde+Uy9Dg0UbF5q\/kl1UhDHFv\/5RdrE1PiPEQPojUTWxZTSmgMmAJukytuOC+KtHMvlJuEzdRiocUSYNFD+lE1wrv+SkeYnmr2SuQRyTRhhLYztVu74aRotBK\/5CCJhQhChqOy6uPp9D8IMqR9h9WZqAQY4B62Cqpab\/OGh1G8+f3bkGtQ6WJGBQY9BCHcAImHmnLB6dBEiABEiABEigJQIUMC1Fg76QALkPGtMAAAInSURBVAmQAAmQAAmICFDAiDCxEQmQAAmQAAmQQEsEKGBaigZ9IQEAAkMXIXZd99dbaO6+SA09tiV5ujLKtWWpcfN7EiCBfgIUMMwMEiCBTxHoEwtjYmTorrvU3Xga9Jo7sDRtNT6wLQmQQDsEKGDaiQU9IYFmCMR3RgzduRI7OyRuNDswKdGR+r7rD3dgmkknOkICVQhQwFTBSqMkgE2gK2D6hEgYYThVFAuGIQE0JkJSAiX1PQUMds7RexLQEqCA0RJjexLYAALS603iFxt2sWiugdEezx9rrI9G7GxAODlEElgkAQqYRYaVgyKBMgJjp5CC5VgkSAWD1Q5M6toaqT9llNibBEhgTgIUMHPS57FJoFECJaeQNBf7ak77pESLxlaj2OkWCZCAggAFjAIWm5LAphDo24EZExBjuzHSnZrUrknf90EsSS403pTYcZwksCkEKGA2JdIcJwkoCAxdXzIkRrp\/7x4qvlZm7BkuY3cOSUWSP3ZKDClQsCkJkECjBChgGg0M3SKB1glIxExXTKSEheYaGV7E23qG0D8SqEuAAqYuX1ongUUS6J66kezADJ3ukQKS3qkU7PE5MFKybEcCmAQoYDDjRq9JgARIgARIYKMJUMBsdPg5eBIgARIgARLAJEABgxk3ek0CJEACJEACG02AAmajw8\/BkwAJkAAJkAAmAQoYzLjRaxIgARIgARLYaAIUMBsdfg6eBEiABEiABDAJ\/B\/\/nWEn9YImQAAAAABJRU5ErkJggg==","height":337,"width":560}}
%---
%[output:9b89c989]
%   data: {"dataType":"text","outputData":{"text":"Simulink model \"DCMotor_Model\" completed. omega(end)=132.855 rad\/s\n","truncated":false}}
%---
