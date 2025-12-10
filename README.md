# Flutter Scene Samples

`flutter_scene` パッケージを使用した、Flutterにおける3Dレンダリングの実験的サンプルプロジェクトです。
3Dモデルのインポート、描画、およびインタラクティブな操作のデモを含んでいます。

## プロジェクトの概要

このリポジトリには、以下の2つの主要なサンプルが含まれています。

- **Model Viewer (`model_viewer`)**
  - `flutter_scene` を使用して不動モデルに対する基本的なモデル・カメラ操作を行うデモです。
    <video src="https://github.com/user-attachments/assets/8f356490-d509-4027-a76f-a32a2fa1dac2" height="240" controls="true">

- **Solar System (`solar_system`)**
  - `flutter_scene` を使用して不動モデルおよび動的モデル（惑星）を描画するデモです。
  - 3Dオブジェクトの階層構造やアニメーションの基礎を確認できます。

- **Rocket Game (`rocket_game`)**
  - ユーザー入力に基づくインタラクティブな操作を伴う3Dゲームのデモです。
  - 動的な更新処理や状態管理の実装例が含まれています。

## 動作プラットフォーム

- **Mac** (Impeller有効化推奨)

## セットアップ方法

このプロジェクトは **FVM (Flutter Version Management)** を使用して管理されています。
開発環境として **VS Code (Visual Studio Code)** の使用を推奨します。

### 前提条件

事前に以下のツールをインストールしてください。

1. [Visual Studio Code](https://code.visualstudio.com/)
2. [FVM (Flutter Version Management)](https://fvm.app/)

### インストール手順

1. ターミナルでプロジェクトのルートディレクトリに移動し、指定されたFlutterバージョンを適用します。

    ```bash
    fvm use
    ```

2. 依存パッケージをインストールします。

    ```bash
    flutter pub get
    ```

### アプリの実行

VS Codeの「実行とデバッグ」機能を使用して、起動するアプリを選択してください。

1. VS Codeを開き、左側のサイドバーから **「実行とデバッグ (Run and Debug)」** を選択します（または `Cmd+Shift+D` / `Ctrl+Shift+D`）。
2. 上部のドロップダウンメニューから、実行したい構成を選択します。
    * **solar_system**
    * **rocket_game**
3. `F5` キーを押すか、再生ボタンをクリックしてアプリをビルド・実行してください。

