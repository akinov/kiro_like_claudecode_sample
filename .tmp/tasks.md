# 掲示板サービス - タスク分解

## 実装タスクリスト

### フェーズ1: プロジェクト初期設定

#### T001: Railsアプリケーション生成
- [ ] 新しいRailsアプリケーションを生成
- [ ] プロジェクトディレクトリに移動
- [ ] Gitリポジトリとして初期化
- **コマンド**: `rails new bulletin_board_app`
- **所要時間**: 5分

#### T002: Gemfile設定
- [ ] Bootstrap gemを追加（`gem 'bootstrap', '~> 5.3.3'`）
- [ ] jQuery Rails gemを追加（`gem 'jquery-rails'`）
- [ ] bundle installを実行
- **ファイル**: `Gemfile`
- **所要時間**: 3分

#### T003: Bootstrap・CSS設定
- [ ] application.cssをapplication.scssにリネーム
- [ ] Bootstrapのimportを追加
- [ ] カスタムCSSを追加
- **ファイル**: `app/assets/stylesheets/application.scss`
- **所要時間**: 5分

#### T004: JavaScript設定
- [ ] importmap.rbにBootstrapとPopperを追加
- [ ] assets.rbに設定を追加
- **ファイル**: `config/importmap.rb`, `config/initializers/assets.rb`
- **所要時間**: 5分

### フェーズ2: データベース設計・実装

#### T005: Postモデル作成
- [ ] Postモデルとマイグレーションを生成
- [ ] マイグレーションファイルを確認・調整
- [ ] モデルにバリデーションを追加
- [ ] モデルにscopeを追加
- **コマンド**: `rails generate model Post title:string content:text author_name:string`
- **所要時間**: 10分

#### T006: Replyモデル作成
- [ ] Replyモデルとマイグレーションを生成
- [ ] belongs_to関連付けを確認
- [ ] モデルにバリデーションを追加
- [ ] モデルにscopeを追加
- **コマンド**: `rails generate model Reply post:references content:text author_name:string`
- **所要時間**: 10分

#### T007: モデル関連付け設定
- [ ] Postモデルにhas_many :repliesを追加
- [ ] dependent: :destroyオプションを設定
- [ ] 関連付けの動作確認
- **ファイル**: `app/models/post.rb`
- **所要時間**: 5分

#### T008: データベースマイグレーション実行
- [ ] マイグレーションを実行
- [ ] スキーマファイルを確認
- [ ] インデックスの追加（必要に応じて）
- **コマンド**: `rails db:migrate`
- **所要時間**: 3分

### フェーズ3: ルーティング・コントローラー実装

#### T009: ルーティング設定
- [ ] config/routes.rbを編集
- [ ] resources :postsを追加（index, show, new, create）
- [ ] nested resources :repliesを追加（create）
- [ ] root routeを設定
- **ファイル**: `config/routes.rb`
- **所要時間**: 5分

#### T010: PostsController作成
- [ ] PostsControllerを生成
- [ ] indexアクションを実装
- [ ] showアクションを実装
- [ ] newアクションを実装
- [ ] createアクションを実装
- [ ] privateメソッドを実装
- **コマンド**: `rails generate controller Posts`
- **所要時間**: 20分

#### T011: RepliesController作成
- [ ] RepliesControllerを生成
- [ ] createアクションを実装
- [ ] privateメソッドを実装
- [ ] エラーハンドリングを実装
- **コマンド**: `rails generate controller Replies`
- **所要時間**: 15分

### フェーズ4: ビュー実装

#### T012: レイアウトファイル作成
- [ ] application.html.erbを編集
- [ ] Bootstrap CDN または gem設定を確認
- [ ] ナビゲーションバーを追加
- [ ] フラッシュメッセージ表示を追加
- [ ] レスポンシブmeta tagを追加
- **ファイル**: `app/views/layouts/application.html.erb`
- **所要時間**: 15分

#### T013: 投稿一覧ページ作成
- [ ] posts/index.html.erbを作成
- [ ] Bootstrap cardコンポーネントを使用
- [ ] 投稿の一覧表示を実装
- [ ] 新規投稿ボタンを追加
- [ ] 投稿詳細へのリンクを追加
- **ファイル**: `app/views/posts/index.html.erb`
- **所要時間**: 20分

#### T014: 投稿詳細ページ作成
- [ ] posts/show.html.erbを作成
- [ ] 投稿内容の詳細表示を実装
- [ ] 返信一覧の表示を実装
- [ ] 返信フォームを実装
- [ ] Bootstrap formコンポーネントを使用
- **ファイル**: `app/views/posts/show.html.erb`
- **所要時間**: 25分

#### T015: 新規投稿ページ作成
- [ ] posts/new.html.erbを作成
- [ ] フォームヘルパーを使用したフォーム作成
- [ ] Bootstrap formコンポーネントを適用
- [ ] バリデーションエラー表示を実装
- **ファイル**: `app/views/posts/new.html.erb`
- **所要時間**: 20分

#### T016: 共通パーシャル作成
- [ ] _form_errors.html.erbを作成
- [ ] エラーメッセージ表示の共通化
- [ ] Bootstrap alertコンポーネントを使用
- **ファイル**: `app/views/shared/_form_errors.html.erb`
- **所要時間**: 10分

### フェーズ5: テスト・検証

#### T017: 基本機能テスト
- [ ] 投稿作成機能のテスト
- [ ] 投稿一覧表示のテスト
- [ ] 投稿詳細表示のテスト
- [ ] 返信作成機能のテスト
- [ ] バリデーションエラーのテスト
- **所要時間**: 15分

#### T018: UI/UX確認
- [ ] レスポンシブデザインの確認
- [ ] フォームの使いやすさ確認
- [ ] エラーメッセージの表示確認
- [ ] ナビゲーションの動作確認
- **所要時間**: 10分

#### T019: パフォーマンス確認
- [ ] N+1クエリの確認
- [ ] ページ読み込み速度の確認
- [ ] データベースクエリの最適化
- **所要時間**: 10分

### フェーズ6: 最終調整・ドキュメント

#### T020: コードレビュー・リファクタリング
- [ ] コードの品質確認
- [ ] 不要なコメントの削除
- [ ] メソッドの分割・統合
- [ ] Rails規約に沿っているか確認
- **所要時間**: 15分

#### T021: README更新
- [ ] プロジェクトの説明を追加
- [ ] セットアップ手順を記載
- [ ] 使用技術の記載
- [ ] 機能一覧の記載
- **ファイル**: `README.md`
- **所要時間**: 10分

#### T022: 最終動作確認
- [ ] 全機能の動作確認
- [ ] エラーケースの確認
- [ ] ブラウザ互換性の確認
- **所要時間**: 10分

## 実装順序

1. **フェーズ1**: プロジェクト初期設定（T001-T004）
2. **フェーズ2**: データベース設計・実装（T005-T008）
3. **フェーズ3**: ルーティング・コントローラー実装（T009-T011）
4. **フェーズ4**: ビュー実装（T012-T016）
5. **フェーズ5**: テスト・検証（T017-T019）
6. **フェーズ6**: 最終調整・ドキュメント（T020-T022）

## 推定作業時間

- **合計**: 約3-4時間
- **フェーズ1**: 18分
- **フェーズ2**: 28分
- **フェーズ3**: 40分
- **フェーズ4**: 90分
- **フェーズ5**: 35分
- **フェーズ6**: 35分

## 成果物チェックリスト

### 必須ファイル
- [ ] `app/models/post.rb`
- [ ] `app/models/reply.rb`
- [ ] `app/controllers/posts_controller.rb`
- [ ] `app/controllers/replies_controller.rb`
- [ ] `app/views/layouts/application.html.erb`
- [ ] `app/views/posts/index.html.erb`
- [ ] `app/views/posts/show.html.erb`
- [ ] `app/views/posts/new.html.erb`
- [ ] `app/views/shared/_form_errors.html.erb`
- [ ] `config/routes.rb`
- [ ] `app/assets/stylesheets/application.scss`
- [ ] `db/migrate/*_create_posts.rb`
- [ ] `db/migrate/*_create_replies.rb`

### 動作確認項目
- [ ] 投稿一覧が表示される
- [ ] 新規投稿が作成できる
- [ ] 投稿詳細が表示される
- [ ] 返信が投稿できる
- [ ] バリデーションエラーが適切に表示される
- [ ] レスポンシブデザインが動作する