# ブラシ付き DC モータ — モデリング・ダイナミクス解析・制御

ブラシ付き DC モータを題材に、**モデリング → ダイナミクス解析 → Simulink シミュレーション → 速度制御** までを学ぶ演習教材です。

**前提教材：** [RLC回路モデリング演習（study-dynamics-matlab）](https://github.com/enotyama19xx/study-dynamics-matlab) を修了していることを想定しています。

---

## 教材の構成

| ファイル / フォルダ | 内容 |
|----------|------|
| `DCMotor_Modeling_Lecture.m` | メイン教材（Live Script 形式） |
| `setupPaths.m` | 教材用パス設定（`simulink-utils` / `plot-utils` を追加） |
| `simulink-utils/` | Simulink 実行・定常値計算ヘルパー |
| `plot-utils/` | グラフ描画ヘルパー（白背景・2 段プロット・ボード線図） |
| `README.md` | 本ファイル（セットアップ手順） |

**Simulink モデル（`DCMotor_Model.slx` 等）はリポジトリに含まれません。** 第 2 章以降の手順に従い、各自で作成してください（`.gitignore` で `*.slx` を除外）。

---

## 必要な環境

| 項目 | 要件 |
|------|------|
| OS | Windows 10 / 11（64bit）推奨 |
| MATLAB | **R2025b 以降**（必須） |
| Simulink | 第 2 章以降で使用 |
| Simscape / Simscape Electrical | 第 2 章（**必修**）で使用。**ライセンスに含まれていること** |
| Control System Toolbox | 第 3 章（ボード線図・伝達関数・ループ整形）で使用 |
| ストレージ | 空き容量 約 10 GB 以上（MATLAB 本体用） |

> **注意：** 本教材は R2025b の **プレーンテキスト Live Code 形式**（`%[text]` 記法）を使用しています。**R2024b 以前では正しく表示されません。**

> **MATLAB Connector / MATLAB Drive は不要です。** 教材はローカルにクローンまたは ZIP 展開して利用します。

---

## 章構成（目安）

| 章 | 内容 |
|----|------|
| 第 1 章 | モデリング（RL 復習、DC モータ等価回路、連立微分方程式） |
| 第 2 章 | ダイナミクス解析（手計算 ＋ Simulink Integrator 方式 ＋ Simulink Simscape 方式） |
| 第 3 章 | 制御系設計（ボード線図、一巡伝達関数によるループ整形、カスケード構成） |

Simulink の詳細手順は **教材 `.m` 内** に記載します。本 README はセットアップと全体像に絞っています。

---

## 教材の使い方

### 1. Live Script として開く

1. MATLAB を起動する
2. Files パネルで `DCMotor_Modeling_Lecture.m` を **ダブルクリック** する（**テキストとして開く** は選ばない）
3. Live Editor で解説・数式・コードが一体として表示されれば成功

### 2. セクションごとに実行する

Live Editor の **Run Section**（`Ctrl+Enter`）でセクション単位に実行します。

- **第 1 章：** 1.8 節でパラメータがワークスペースに定義される
- **第 2 章以降：** Simulink モデル作成後、シミュレーションとプロットを実行

---

## GitHub から教材を取得する

### ZIP でダウンロード

1. リポジトリページ → **Code** → **Download ZIP**
2. 任意のフォルダに解凍（例：`C:\Users\<ユーザー名>\Documents\study-dynamics-matlab-dcmotor`）

### Git でクローン

```powershell
cd C:\Users\<ユーザー名>\Documents
git clone https://github.com/enotyama19xx/study-dynamics-matlab-dcmotor.git
cd study-dynamics-matlab-dcmotor
```

---

## よくあるトラブル

| 症状 | 対処 |
|------|------|
| `%[text]` がそのまま表示される | Live Editor で **開く**（テキストとして開かない）。R2025b 以降を使用 |
| 節末尾に空のコード枠が出る | テキスト行とコード行の間に空行を入れない（教材ファイルは空行なしで記述） |
| Simulink モデルが見つからない | `DCMotor_Model.slx` を教材 `.m` と **同じフォルダ** に保存。Current Folder を確認 |
| 第 3 章 Simscape が使えない | Simscape / Simscape Electrical のライセンスを確認（第 3 章は必修） |

---

## 参考リンク

| リソース | URL |
|----------|-----|
| 前提教材（RLC 回路） | https://github.com/enotyama19xx/study-dynamics-matlab |
| MATLAB ダウンロード | https://www.mathworks.com/downloads/ |
| プレーンテキスト Live Code 形式 | https://www.mathworks.com/help/matlab/matlab_prog/plain-text-file-format-for-live-scripts.html |
| Simulink 入門 | https://www.mathworks.com/help/simulink/getting-started-with-simulink.html |

---

## 問い合わせ

不明点は **担当教員** まで連絡してください。

---

*本 README は DC モータ演習教材（GitHub 配布版）に付属するセットアップガイドです。*
