# 掲示板サービス - イミュータブルデータモデル実装タスク分解

## 実装タスクリスト

### フェーズ1: プロジェクト初期設定

#### T001: Railsアプリケーション生成（Rails 8対応）
- [ ] 新しいRailsアプリケーションを生成（Tailwind CSS + ImportMaps）
- [ ] プロジェクトディレクトリに移動
- [ ] Gitリポジトリとして初期化
- **コマンド**: `rails new bulletin_board_app --css=tailwind --javascript=importmap`
- **所要時間**: 10分

#### T002: Rails 8新機能の設定
- [ ] Solid Cacheを有効化（`rails generate solid_cache:install`）
- [ ] Solid Queueを有効化（`rails generate solid_queue:install`）
- [ ] Propshaftアセットパイプライン設定確認
- **ファイル**: `config/environments/*.rb`
- **所要時間**: 10分

#### T003: Tailwind CSS・Stimulus設定
- [ ] Tailwind設定ファイルを確認・カスタマイズ
- [ ] Stimulusコントローラーの設定確認
- [ ] カスタムTailwindコンポーネント追加
- **ファイル**: `app/assets/stylesheets/application.tailwind.css`, `config/importmap.rb`
- **所要時間**: 15分

### フェーズ2: イミュータブルドメインモデル設計・実装

#### T004: データベーススキーマ設計
- [ ] Postテーブルのマイグレーションを生成
- [ ] Replyテーブルのマイグレーションを生成
- [ ] インデックスの最適化（Solid Cache対応）
- **コマンド**: `rails generate model Post title:string content:text author_name:string`
- **コマンド**: `rails generate model Reply post:references content:text author_name:string`
- **所要時間**: 15分

#### T005: Value Objects実装
- [ ] PostDataクラスを作成（不変値オブジェクト）
- [ ] ReplyDataクラスを作成（不変値オブジェクト）
- [ ] バリデーション機能の実装
- [ ] 等価性メソッド（==, hash）の実装
- [ ] with_updatesメソッドの実装
- **ファイル**: `app/models/concerns/post_data.rb`, `app/models/concerns/reply_data.rb`
- **所要時間**: 25分

#### T006: Domain Aggregates実装
- [ ] PostAggregateクラスを作成
- [ ] 集約ルートとしての責務を定義
- [ ] add_replyメソッドの実装（不変）
- [ ] 派生データ計算メソッドの実装（純粋関数）
- **ファイル**: `app/models/post_aggregate.rb`
- **所要時間**: 20分

#### T007: Read Models実装（ActiveRecord）
- [ ] Postモデルを読み取り専用に設定
- [ ] Replyモデルを読み取り専用に設定
- [ ] to_post_data、to_reply_dataメソッド実装
- [ ] to_post_aggregateメソッド実装
- [ ] アソシエーションとスコープの設定
- **ファイル**: `app/models/post.rb`, `app/models/reply.rb`
- **所要時間**: 20分

#### T008: Command Models実装
- [ ] PostCommandクラスを作成（書き込み専用）
- [ ] ReplyCommandクラスを作成（書き込み専用）
- [ ] executeメソッドの実装（副作用の隔離）
- [ ] バリデーション機能の実装
- **ファイル**: `app/commands/post_command.rb`, `app/commands/reply_command.rb`
- **所要時間**: 20分

#### T009: Repository Pattern実装
- [ ] PostRepositoryクラスを作成
- [ ] クエリメソッドの実装（all_posts, find_post）
- [ ] コマンドメソッドの実装（create_post, add_reply）
- [ ] CQRS パターンの実装
- **ファイル**: `app/repositories/post_repository.rb`
- **所要時間**: 25分

### フェーズ3: イミュータブル・コントローラー実装

#### T010: Application Controller設計
- [ ] 純粋関数ベースのヘルパーメソッド実装
- [ ] エラーレスポンス生成関数
- [ ] 成功レスポンス生成関数
- [ ] Hotwire対応の共通機能
- **ファイル**: `app/controllers/application_controller.rb`
- **所要時間**: 15分

#### T011: Posts Controller実装（イミュータブル設計）
- [ ] indexアクション（読み取り専用・純粋関数）
- [ ] showアクション（読み取り専用・純粋関数）
- [ ] newアクション（フォーム表示）
- [ ] createアクション（副作用の隔離）
- [ ] プライベートメソッド（純粋関数）
- [ ] Turbo Stream対応
- **ファイル**: `app/controllers/posts_controller.rb`
- **所要時間**: 30分

#### T012: Replies Controller実装（イミュータブル設計）
- [ ] createアクション（副作用の隔離）
- [ ] エラーハンドリング（純粋関数）
- [ ] 成功時処理（純粋関数）
- [ ] Turbo Stream対応
- **ファイル**: `app/controllers/replies_controller.rb`
- **所要時間**: 25分

#### T013: ルーティング設定
- [ ] config/routes.rbを編集
- [ ] resources :postsを追加（index, show, new, create）
- [ ] nested resources :repliesを追加（create）
- [ ] root routeを設定
- **ファイル**: `config/routes.rb`
- **所要時間**: 5分

### フェーズ4: Presentation Layer（ViewModel・ビュー）実装

#### T014: ViewModel実装
- [ ] PostViewModelクラスを作成（不変プレゼンテーション）
- [ ] ReplyViewModelクラスを作成（不変プレゼンテーション）
- [ ] PostFormModelクラスを作成（フォーム状態管理）
- [ ] ReplyFormModelクラスを作成（フォーム状態管理）
- [ ] 日付フォーマット等のヘルパーメソッド
- **ファイル**: `app/view_models/*.rb`
- **所要時間**: 25分

#### T015: レイアウトファイル作成（Tailwind対応）
- [ ] application.html.erbを編集
- [ ] Tailwind CSSクラスでスタイリング
- [ ] Hotwire（Turbo）対応の設定
- [ ] ナビゲーションバーを追加
- [ ] フラッシュメッセージ表示を追加
- [ ] レスポンシブmeta tagを追加
- **ファイル**: `app/views/layouts/application.html.erb`
- **所要時間**: 20分

#### T016: 投稿一覧ページ作成（ViewModelベース）
- [ ] posts/index.html.erbを作成
- [ ] ViewModelを使ったデータ表示
- [ ] Tailwind Cardコンポーネントを使用
- [ ] Turbo Frame対応
- [ ] 新規投稿ボタンを追加
- **ファイル**: `app/views/posts/index.html.erb`
- **所要時間**: 25分

#### T017: 投稿詳細ページ作成（ViewModelベース）
- [ ] posts/show.html.erbを作成
- [ ] ViewModelを使ったデータ表示
- [ ] 返信一覧の表示（ReplyViewModel使用）
- [ ] 返信フォームを実装（ReplyFormModel使用）
- [ ] Turbo Stream対応
- **ファイル**: `app/views/posts/show.html.erb`
- **所要時間**: 30分

#### T018: 新規投稿ページ作成（FormModelベース）
- [ ] posts/new.html.erbを作成
- [ ] PostFormModelを使ったフォーム作成
- [ ] Tailwind formコンポーネントを適用
- [ ] バリデーションエラー表示を実装
- [ ] Turbo Frame対応
- **ファイル**: `app/views/posts/new.html.erb`
- **所要時間**: 25分

#### T019: 共通パーシャル・コンポーネント作成
- [ ] _form_errors.html.erbを作成
- [ ] _post_card.html.erbを作成（再利用可能コンポーネント）
- [ ] _reply_item.html.erbを作成
- [ ] Tailwind alertコンポーネントを使用
- **ファイル**: `app/views/shared/*.html.erb`
- **所要時間**: 20分

### フェーズ5: Stimulus Controllers（モダンJavaScript）

#### T020: 投稿フォーム用Stimulusコントローラー
- [ ] post_form_controller.jsを作成
- [ ] 文字数カウンター機能実装
- [ ] リアルタイムバリデーション
- [ ] Tailwindクラスでスタイル制御
- **ファイル**: `app/javascript/controllers/post_form_controller.js`
- **所要時間**: 20分

#### T021: モーダル用Stimulusコントローラー
- [ ] modal_controller.jsを作成
- [ ] 開閉アニメーション実装
- [ ] キーボードイベント対応
- [ ] Tailwindを使ったスタイリング
- **ファイル**: `app/javascript/controllers/modal_controller.js`
- **所要時間**: 15分

### フェーズ6: テスト実装（イミュータブル対応）

#### T022: Value Objects単体テスト
- [ ] PostDataのテスト実装
- [ ] ReplyDataのテスト実装
- [ ] 不変性のテスト
- [ ] 等価性テスト
- [ ] with_updatesメソッドのテスト
- **ファイル**: `spec/models/concerns/*_spec.rb`
- **所要時間**: 25分

#### T023: Domain Aggregates単体テスト
- [ ] PostAggregateのテスト実装
- [ ] add_replyメソッドのテスト
- [ ] 派生データ計算のテスト
- [ ] 不変性のテスト
- **ファイル**: `spec/models/post_aggregate_spec.rb`
- **所要時間**: 20分

#### T024: Repository統合テスト
- [ ] PostRepositoryのテスト実装
- [ ] クエリメソッドのテスト
- [ ] コマンドメソッドのテスト
- [ ] データベース相互作用のテスト
- **ファイル**: `spec/repositories/post_repository_spec.rb`
- **所要時間**: 20分

#### T025: Controller統合テスト
- [ ] PostsControllerのテスト実装
- [ ] RepliesControllerのテスト実装
- [ ] Turbo Stream レスポンスのテスト
- [ ] エラーハンドリングのテスト
- **ファイル**: `spec/controllers/*_spec.rb`
- **所要時間**: 25分

#### T026: ViewModel単体テスト
- [ ] PostViewModelのテスト実装
- [ ] ReplyViewModelのテスト実装
- [ ] フォーマット関数のテスト
- [ ] 不変性のテスト
- **ファイル**: `spec/view_models/*_spec.rb`
- **所要時間**: 20分

#### T027: System Tests（E2Eテスト）
- [ ] 投稿作成フローのテスト
- [ ] 返信作成フローのテスト
- [ ] バリデーションエラーのテスト
- [ ] Turbo動作のテスト
- **ファイル**: `spec/system/*_spec.rb`
- **所要時間**: 25分

### フェーズ7: パフォーマンス最適化・最終調整

#### T028: パフォーマンス最適化
- [ ] N+1クエリの確認と修正
- [ ] データベースインデックス最適化
- [ ] メモ化（Memoization）の実装
- [ ] Solid Cache活用の確認
- **所要時間**: 20分

#### T029: セキュリティ確認
- [ ] CSRF保護の確認
- [ ] XSS対策の確認
- [ ] SQLインジェクション対策の確認
- [ ] Strong Parametersの確認
- **所要時間**: 15分

#### T030: コードレビュー・リファクタリング
- [ ] イミュータブル設計原則の遵守確認
- [ ] 純粋関数の実装確認
- [ ] CQRS パターンの実装確認
- [ ] Rails規約との整合性確認
- **所要時間**: 20分

#### T031: ドキュメント更新
- [ ] README.mdの更新（イミュータブル設計の説明）
- [ ] アーキテクチャドキュメントの作成
- [ ] API仕様書の作成
- [ ] 設計判断の記録
- **ファイル**: `README.md`, `docs/*.md`
- **所要時間**: 25分

#### T032: 最終動作確認
- [ ] 全機能の動作確認
- [ ] エラーケースの確認
- [ ] レスポンシブデザインの確認
- [ ] ブラウザ互換性の確認
- [ ] パフォーマンステスト
- **所要時間**: 20分

## 実装順序

1. **フェーズ1**: プロジェクト初期設定（T001-T003）
2. **フェーズ2**: イミュータブルドメインモデル設計・実装（T004-T009）
3. **フェーズ3**: イミュータブル・コントローラー実装（T010-T013）
4. **フェーズ4**: Presentation Layer（T014-T019）
5. **フェーズ5**: Stimulus Controllers（T020-T021）
6. **フェーズ6**: テスト実装（T022-T027）
7. **フェーズ7**: パフォーマンス最適化・最終調整（T028-T032）

## 推定作業時間

- **合計**: 約7-8時間
- **フェーズ1**: 35分
- **フェーズ2**: 2時間5分
- **フェーズ3**: 1時間15分
- **フェーズ4**: 2時間5分
- **フェーズ5**: 35分
- **フェーズ6**: 2時間15分
- **フェーズ7**: 1時間40分

## 成果物チェックリスト

### ドメイン層
- [ ] `app/models/concerns/post_data.rb` - 投稿値オブジェクト
- [ ] `app/models/concerns/reply_data.rb` - 返信値オブジェクト
- [ ] `app/models/post_aggregate.rb` - 投稿集約
- [ ] `app/commands/post_command.rb` - 投稿作成コマンド
- [ ] `app/commands/reply_command.rb` - 返信作成コマンド
- [ ] `app/repositories/post_repository.rb` - リポジトリ

### インフラストラクチャ層
- [ ] `app/models/post.rb` - 読み取り専用モデル
- [ ] `app/models/reply.rb` - 読み取り専用モデル
- [ ] `db/migrate/*_create_posts.rb` - マイグレーション
- [ ] `db/migrate/*_create_replies.rb` - マイグレーション

### アプリケーション層
- [ ] `app/controllers/application_controller.rb` - 基底コントローラー
- [ ] `app/controllers/posts_controller.rb` - 投稿コントローラー
- [ ] `app/controllers/replies_controller.rb` - 返信コントローラー
- [ ] `config/routes.rb` - ルーティング設定

### プレゼンテーション層
- [ ] `app/view_models/post_view_model.rb` - 投稿ビューモデル
- [ ] `app/view_models/reply_view_model.rb` - 返信ビューモデル
- [ ] `app/view_models/post_form_model.rb` - 投稿フォームモデル
- [ ] `app/view_models/reply_form_model.rb` - 返信フォームモデル
- [ ] `app/views/layouts/application.html.erb` - レイアウト
- [ ] `app/views/posts/*.html.erb` - 投稿ビュー
- [ ] `app/views/shared/*.html.erb` - 共通パーシャル

### フロントエンド
- [ ] `app/assets/stylesheets/application.tailwind.css` - スタイル
- [ ] `app/javascript/controllers/post_form_controller.js` - フォームコントローラー
- [ ] `app/javascript/controllers/modal_controller.js` - モーダルコントローラー

### テスト
- [ ] `spec/models/concerns/*_spec.rb` - Value Objects テスト
- [ ] `spec/models/post_aggregate_spec.rb` - Aggregate テスト
- [ ] `spec/repositories/post_repository_spec.rb` - Repository テスト
- [ ] `spec/controllers/*_spec.rb` - Controller テスト
- [ ] `spec/view_models/*_spec.rb` - ViewModel テスト
- [ ] `spec/system/*_spec.rb` - System テスト

## 動作確認項目（イミュータブル設計対応）

### 機能確認
- [ ] 投稿一覧が表示される（ViewModelベース）
- [ ] 新規投稿が作成できる（Command/Repository経由）
- [ ] 投稿詳細が表示される（PostAggregate経由）
- [ ] 返信が投稿できる（Command/Repository経由）
- [ ] バリデーションエラーが適切に表示される
- [ ] Turbo Stream によるリアルタイム更新が動作する

### アーキテクチャ確認
- [ ] Value Objects が不変（freeze）されている
- [ ] Aggregates が不変性を保持している
- [ ] Repository パターンが CQRS を実現している
- [ ] Controller が純粋関数ベースになっている
- [ ] ViewModel が不変データを提供している
- [ ] 副作用が Command クラスに隔離されている

### パフォーマンス確認
- [ ] N+1 クエリが発生していない
- [ ] メモ化が適切に働いている
- [ ] Solid Cache が効いている
- [ ] データベースインデックスが最適化されている

イミュータブルデータモデルの採用により、従来のRailsアプリケーションと比較して、より安全で予測可能、テストしやすいアーキテクチャを実現します。