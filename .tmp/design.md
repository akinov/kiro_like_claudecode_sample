# 掲示板サービス - 技術設計書

## システム概要

Ruby on Rails 7.xを使用したシンプルな掲示板サービス。投稿の作成・表示・返信機能を提供するWebアプリケーション。

## 技術スタック

### フレームワーク・言語
- **Ruby**: 3.x系
- **Ruby on Rails**: 7.x系（最新安定版）
- **データベース**: SQLite3（開発環境）

### フロントエンド
- **Bootstrap**: 5.3系（twbs/bootstrap-rubygem使用）
- **JavaScript**: Rails標準のImportmaps + Stimulus
- **CSS**: Sass（.scss）

### その他の主要Gem
- `jquery-rails`（Bootstrap JavaScript コンポーネント用）
- Rails標準gem（sqlite3、turbo-rails、stimulus-rails等）

## アーキテクチャ設計

### MVCアーキテクチャ

#### Models
- **Post**: 投稿データモデル
- **Reply**: 返信データモデル

#### Controllers
- **PostsController**: 投稿の CRUD 操作
- **RepliesController**: 返信の作成操作
- **ApplicationController**: 共通機能

#### Views
- **Posts**: 投稿関連のビュー
- **Shared**: 共通パーシャル
- **Layouts**: レイアウトファイル

### ルーティング設計

```ruby
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts, only: [:index, :show, :new, :create] do
    resources :replies, only: [:create]
  end
end
```

#### URL構成
- `GET /` - 投稿一覧（ルート）
- `GET /posts/new` - 新規投稿フォーム
- `POST /posts` - 投稿作成
- `GET /posts/:id` - 投稿詳細
- `POST /posts/:id/replies` - 返信作成

## データベース設計

### テーブル構造

#### postsテーブル
```sql
CREATE TABLE posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  author_name VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL
);
```

#### repliesテーブル
```sql
CREATE TABLE replies (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id INTEGER NOT NULL,
  content TEXT NOT NULL,
  author_name VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  FOREIGN KEY (post_id) REFERENCES posts(id)
);
```

### インデックス設計
- `replies(post_id)`: 投稿に対する返信取得の高速化
- `posts(created_at)`: 投稿一覧の日時順ソートの高速化

### 制約・バリデーション
- NOT NULL制約（必須項目）
- 文字数制限（アプリケーションレベル）
- 外部キー制約

## モデル設計

### Post モデル
```ruby
class Post < ApplicationRecord
  has_many :replies, dependent: :destroy
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 }
  
  scope :recent, -> { order(created_at: :desc) }
end
```

### Reply モデル
```ruby
class Reply < ApplicationRecord
  belongs_to :post
  
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 }
  
  scope :chronological, -> { order(created_at: :asc) }
end
```

## コントローラー設計

### PostsController
```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.recent.includes(:replies)
  end
  
  def show
    @post = Post.find(params[:id])
    @reply = Reply.new
    @replies = @post.replies.chronological
  end
  
  def new
    @post = Post.new
  end
  
  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to @post, notice: '投稿が作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  def post_params
    params.require(:post).permit(:title, :content, :author_name)
  end
end
```

### RepliesController
```ruby
class RepliesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @reply = @post.replies.build(reply_params)
    
    if @reply.save
      redirect_to @post, notice: '返信が投稿されました。'
    else
      @replies = @post.replies.chronological
      render 'posts/show', status: :unprocessable_entity
    end
  end
  
  private
  
  def reply_params
    params.require(:reply).permit(:content, :author_name)
  end
end
```

## フロントエンド設計

### Bootstrap統合

#### Gemfile
```ruby
gem 'bootstrap', '~> 5.3.3'
gem 'jquery-rails'
```

#### 設定ファイル（config/importmap.rb）
```ruby
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
```

#### スタイルシート（app/assets/stylesheets/application.scss）
```scss
@import "bootstrap";

// カスタムスタイル
.post-card {
  margin-bottom: 1rem;
}

.reply-section {
  background-color: #f8f9fa;
  padding: 1rem;
  border-radius: 0.375rem;
}
```

### レスポンシブデザイン
- Bootstrap Gridシステム使用
- モバイルファーストアプローチ
- ブレークポイント: sm（576px）、md（768px）、lg（992px）

### UI/UXデザイン
- **カラースキーム**: Bootstrap デフォルト
- **タイポグラフィ**: Bootstrap Typography
- **フォーム**: Bootstrap Form components
- **アラート**: Bootstrap Alerts（成功・エラーメッセージ）

## セキュリティ設計

### Rails標準セキュリティ機能
- **CSRF保護**: `protect_from_forgery`
- **SQLインジェクション対策**: Strong Parameters
- **XSS対策**: ERB自動エスケープ

### バリデーション
- **入力値検証**: presence、length
- **HTMLサニタイゼーション**: Rails標準機能

## パフォーマンス設計

### データベース最適化
- **N+1問題対策**: `includes`使用
- **インデックス**: 外部キー、ソート用カラム

### キャッシング戦略
- 開発段階では基本的なキャッシングのみ
- 将来的にフラグメントキャッシング検討

## 開発・デプロイメント

### 開発環境
- **Rails server**: Puma
- **データベース**: SQLite3
- **アセット**: Sprockets + Importmaps

### ファイル構成
```
app/
├── controllers/
│   ├── application_controller.rb
│   ├── posts_controller.rb
│   └── replies_controller.rb
├── models/
│   ├── application_record.rb
│   ├── post.rb
│   └── reply.rb
├── views/
│   ├── layouts/
│   │   └── application.html.erb
│   ├── posts/
│   │   ├── index.html.erb
│   │   ├── show.html.erb
│   │   └── new.html.erb
│   └── shared/
│       └── _form_errors.html.erb
└── assets/
    ├── stylesheets/
    │   └── application.scss
    └── javascripts/
        └── application.js
```

### Railsアプリケーション生成コマンド
```bash
rails new bulletin_board_app
cd bulletin_board_app
```

### 必要なGem追加
```ruby
# Gemfile
gem 'bootstrap', '~> 5.3.3'
gem 'jquery-rails'
```

## テスト戦略

### テストフレームワーク
- **単体テスト**: Rails標準（Minitest）
- **統合テスト**: System tests

### テスト対象
- **モデル**: バリデーション、アソシエーション
- **コントローラー**: アクション、リダイレクト
- **システム**: エンドツーエンド動作確認

## エラーハンドリング

### バリデーションエラー
- フォーム画面でエラーメッセージ表示
- Bootstrap Alert componentを使用

### 404エラー
- Rails標準の例外処理
- 将来的にカスタム404ページ検討

## 今後の拡張予定

### フェーズ2機能
- ユーザー認証（Devise）
- 投稿編集・削除機能
- ページネーション（Kaminari）

### フェーズ3機能
- いいね機能
- 検索機能
- カテゴリ機能
- 画像添付（Active Storage）