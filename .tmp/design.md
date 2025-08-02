# 掲示板サービス - イミュータブルデータモデル設計書（Rails 8版）

## システム概要

Rails 8.xとHotwire（Turbo + Stimulus）を使用した、**イミュータブルデータモデル**を採用したモダンな掲示板サービス。関数型プログラミングの原則に従い、データの不変性を保証し、予測可能で安全なアプリケーションを構築。

## イミュータブル設計原則

### 1. データ不変性（Data Immutability）
- 一度作成されたデータオブジェクトは変更されない
- 状態変更は新しいオブジェクトの作成によって実現
- データの歴史追跡と監査性の向上

### 2. 純粋関数（Pure Functions）
- 同じ入力に対して常に同じ出力を返す
- 副作用を持たない関数設計
- テスタビリティの向上

### 3. コマンド・クエリ責任分離（CQRS）
- データの読み取り（Query）と書き込み（Command）を分離
- 最適化された読み取り専用ビュー
- イベントソーシングとの親和性

## 技術スタック

### フレームワーク・言語
- **Ruby**: 3.2+ 系
- **Ruby on Rails**: 8.x系（2024年11月リリース）
- **データベース**: SQLite3（Solid Cacheサポート）

### Rails 8の新機能を活用
- **Solid Cache**: Redisの代替として、データベースベースのキャッシュ
- **Solid Queue**: バックグラウンドジョブ処理（Sidekiqの代替）
- **Built-in Authentication**: Rails 8の認証ジェネレーター（将来的な拡張用）
- **Propshaft**: 新しいアセットパイプライン（Sprocketsの後継）
- **Kamal 2**: デプロイメントツール

### モダンフロントエンド
- **Hotwire**: HTML Over The Wire
  - **Turbo Drive**: ページ遷移の高速化
  - **Turbo Frames**: 部分更新
  - **Turbo Streams**: リアルタイム更新
- **Stimulus**: 軽量JavaScript フレームワーク（jQueryの代替）
- **Tailwind CSS**: ユーティリティファーストCSSフレームワーク（Bootstrapの代替）

### パフォーマンス最適化
- **ViewComponent**: コンポーネントベースのビュー
- **ImportMaps**: ES6モジュールのネイティブサポート
- **HTTPStreaming**: Turbo Streamsによるリアルタイム更新

## アーキテクチャ設計

### Hotwire + Rails MVCアーキテクチャ

#### Models
- **Post**: 投稿データモデル
- **Reply**: 返信データモデル
- ViewComponentとの統合

#### Controllers
- **PostsController**: Turbo対応CRUD操作
- **RepliesController**: Turbo Streams対応の返信作成
- **ApplicationController**: Hotwire対応の共通機能

#### Views（ViewComponent採用）
- **Posts**: 投稿関連のコンポーネント
- **Shared**: 共通コンポーネント
- **Layouts**: Hotwire対応レイアウト

### ルーティング設計

```ruby
Rails.application.routes.draw do
  root 'posts#index'
  resources :posts, only: [:index, :show, :new, :create] do
    resources :replies, only: [:create]
  end
end
```

#### URL構成（Turbo対応）
- `GET /` - 投稿一覧（Turbo Drive）
- `GET /posts/new` - 新規投稿フォーム（Turbo Frame）
- `POST /posts` - 投稿作成（Turbo Stream）
- `GET /posts/:id` - 投稿詳細（Turbo Frame）
- `POST /posts/:id/replies` - 返信作成（Turbo Stream）

## データベース設計

### Rails 8対応のテーブル構造

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

### Solid Cache対応インデックス
```sql
-- パフォーマンス最適化用インデックス
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX idx_replies_post_created ON replies(post_id, created_at);

-- Solid Cache用テーブル（自動生成）
-- solid_cache_entries テーブルがRails 8で自動作成される
```

### 制約・バリデーション
- NOT NULL制約（必須項目）
- 文字数制限（アプリケーションレベル）
- 外部キー制約

## イミュータブルモデル設計（Rails 8対応）

### イミュータブルデータ構造の実装

#### Value Objects（値オブジェクト）
```ruby
# 投稿データの値オブジェクト
class PostData
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  
  attribute :title, :string
  attribute :content, :string
  attribute :author_name, :string
  attribute :created_at, :datetime
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 },
            format: { with: /\A[^\r\n\t]+\z/, message: "改行・タブ文字は使用できません" }
  
  def initialize(attributes = {})
    super(attributes)
    @created_at ||= Time.current
    freeze # オブジェクトを不変にする
  end
  
  # 新しいインスタンスを作成する純粋関数
  def with_updates(updates = {})
    self.class.new(
      title: updates.fetch(:title, title),
      content: updates.fetch(:content, content),
      author_name: updates.fetch(:author_name, author_name),
      created_at: created_at
    )
  end
  
  # 派生データを計算する純粋関数
  def summary_content
    content.truncate(100)
  end
  
  def ==(other)
    other.is_a?(self.class) &&
      title == other.title &&
      content == other.content &&
      author_name == other.author_name
  end
  
  def hash
    [title, content, author_name].hash
  end
end

# 返信データの値オブジェクト
class ReplyData
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  
  attribute :content, :string
  attribute :author_name, :string
  attribute :created_at, :datetime
  
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 },
            format: { with: /\A[^\r\n\t]+\z/, message: "改行・タブ文字は使用できません" }
  
  def initialize(attributes = {})
    super(attributes)
    @created_at ||= Time.current
    freeze
  end
  
  def with_updates(updates = {})
    self.class.new(
      content: updates.fetch(:content, content),
      author_name: updates.fetch(:author_name, author_name),
      created_at: created_at
    )
  end
  
  def ==(other)
    other.is_a?(self.class) &&
      content == other.content &&
      author_name == other.author_name
  end
  
  def hash
    [content, author_name].hash
  end
end
```

#### イミュータブルコレクション
```ruby
# 投稿集約（Aggregate）
class PostAggregate
  attr_reader :id, :post_data, :replies
  
  def initialize(id:, post_data:, replies: [])
    @id = id
    @post_data = post_data.freeze
    @replies = replies.map(&:freeze).freeze
    freeze
  end
  
  # 新しい返信を追加した新しい集約を作成
  def add_reply(reply_data)
    raise ArgumentError, "無効な返信データ" unless reply_data.valid?
    
    new_replies = @replies + [reply_data]
    self.class.new(
      id: @id,
      post_data: @post_data,
      replies: new_replies
    )
  end
  
  # 返信数を取得する純粋関数
  def reply_count
    @replies.length
  end
  
  # 時系列順の返信を取得する純粋関数
  def replies_chronological
    @replies.sort_by(&:created_at)
  end
  
  # 最新の返信を取得する純粋関数
  def latest_reply
    @replies.max_by(&:created_at)
  end
  
  def ==(other)
    other.is_a?(self.class) &&
      id == other.id &&
      post_data == other.post_data &&
      replies == other.replies
  end
end
```

### Persistence Layer（永続化層）

#### Read Model（読み取り専用モデル）
```ruby
class Post < ApplicationRecord
  self.table_name = 'posts'
  
  has_many :replies, dependent: :destroy
  
  # 読み取り専用：更新メソッドを無効化
  def readonly?
    !new_record?
  end
  
  # データベースからイミュータブルオブジェクトを作成
  def to_post_data
    PostData.new(
      title: title,
      content: content,
      author_name: author_name,
      created_at: created_at
    )
  end
  
  def to_post_aggregate
    reply_objects = replies.order(:created_at).map(&:to_reply_data)
    PostAggregate.new(
      id: id,
      post_data: to_post_data,
      replies: reply_objects
    )
  end
  
  scope :by_newest, -> { order(created_at: :desc) }
  scope :with_replies, -> { includes(:replies) }
end

class Reply < ApplicationRecord
  self.table_name = 'replies'
  
  belongs_to :post
  
  def readonly?
    !new_record?
  end
  
  def to_reply_data
    ReplyData.new(
      content: content,
      author_name: author_name,
      created_at: created_at
    )
  end
  
  scope :chronological, -> { order(created_at: :asc) }
end
```

#### Write Model（書き込み専用コマンド）
```ruby
class PostCommand
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :title, :string
  attribute :content, :string
  attribute :author_name, :string
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 }
  
  # コマンドの実行（副作用を持つ唯一の場所）
  def execute
    return nil unless valid?
    
    post_record = Post.create!(
      title: title,
      content: content,
      author_name: author_name
    )
    
    # 新しく作成されたレコードからイミュータブルオブジェクトを返す
    post_record.to_post_aggregate
  end
end

class ReplyCommand
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :post_id, :integer
  attribute :content, :string
  attribute :author_name, :string
  
  validates :post_id, presence: true
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 }
  
  def execute
    return nil unless valid?
    
    post_record = Post.find(post_id)
    reply_record = post_record.replies.create!(
      content: content,
      author_name: author_name
    )
    
    # 更新された集約を返す
    post_record.reload.to_post_aggregate
  end
end
```

### Repository Pattern（リポジトリパターン）
```ruby
class PostRepository
  class << self
    # すべての投稿を取得（クエリ）
    def all_posts
      Post.by_newest.with_replies.map(&:to_post_aggregate)
    end
    
    # 投稿を取得（クエリ）
    def find_post(id)
      post_record = Post.find(id)
      post_record.to_post_aggregate
    rescue ActiveRecord::RecordNotFound
      nil
    end
    
    # 投稿を作成（コマンド）
    def create_post(post_data)
      command = PostCommand.new(
        title: post_data.title,
        content: post_data.content,
        author_name: post_data.author_name
      )
      command.execute
    end
    
    # 返信を追加（コマンド）
    def add_reply(post_id, reply_data)
      command = ReplyCommand.new(
        post_id: post_id,
        content: reply_data.content,
        author_name: reply_data.author_name
      )
      command.execute
    end
  end
end
```

## イミュータブル・コントローラー設計（関数型アプローチ）

### Application Controller（純粋関数ベース）
```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  private
  
  # 純粋関数：エラーレスポンスを生成
  def render_error_response(errors, status: :unprocessable_entity)
    {
      success: false,
      errors: errors,
      timestamp: Time.current.iso8601
    }
  end
  
  # 純粋関数：成功レスポンスを生成
  def render_success_response(data, message: nil)
    {
      success: true,
      data: data,
      message: message,
      timestamp: Time.current.iso8601
    }
  end
end
```

### PostsController（イミュータブル設計）
```ruby
class PostsController < ApplicationController
  # 読み取り専用アクション（純粋関数）
  def index
    posts = PostRepository.all_posts
    @posts_data = posts.map { |post| post_view_model(post) }
  end
  
  def show
    post_aggregate = PostRepository.find_post(params[:id])
    
    if post_aggregate
      @post_data = post_view_model(post_aggregate)
      @new_reply_form = reply_form_model
    else
      redirect_to root_path, alert: '投稿が見つかりませんでした。'
    end
  end
  
  def new
    @post_form = post_form_model
  end
  
  # 書き込みアクション（副作用の隔離）
  def create
    post_data = build_post_data(post_params)
    
    if post_data.valid?
      result = create_post_command(post_data)
      handle_post_creation_result(result)
    else
      @post_form = post_form_model(post_params, post_data.errors)
      render :new, status: :unprocessable_entity
    end
  end
  
  private
  
  # 純粋関数：PostDataオブジェクトを構築
  def build_post_data(params)
    PostData.new(
      title: params[:title],
      content: params[:content],
      author_name: params[:author_name]
    )
  end
  
  # 純粋関数：投稿作成コマンドを実行
  def create_post_command(post_data)
    PostRepository.create_post(post_data)
  end
  
  # 純粋関数：作成結果を処理
  def handle_post_creation_result(post_aggregate)
    if post_aggregate
      respond_to do |format|
        format.html { redirect_to post_path(post_aggregate.id), notice: '投稿が作成されました。' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend(
            "posts_list",
            partial: "posts/post_card",
            locals: { post: post_view_model(post_aggregate) }
          )
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # 純粋関数：ビューモデルを生成
  def post_view_model(post_aggregate)
    PostViewModel.new(post_aggregate)
  end
  
  def post_form_model(params = {}, errors = nil)
    PostFormModel.new(params, errors)
  end
  
  def reply_form_model(params = {}, errors = nil)
    ReplyFormModel.new(params, errors)
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :author_name)
  end
end
```

### RepliesController（イミュータブル設計）
```ruby
class RepliesController < ApplicationController
  def create
    reply_data = build_reply_data(reply_params)
    
    if reply_data.valid?
      result = create_reply_command(params[:post_id], reply_data)
      handle_reply_creation_result(result)
    else
      handle_reply_creation_error(reply_data.errors)
    end
  end
  
  private
  
  # 純粋関数：ReplyDataオブジェクトを構築
  def build_reply_data(params)
    ReplyData.new(
      content: params[:content],
      author_name: params[:author_name]
    )
  end
  
  # 純粋関数：返信作成コマンドを実行
  def create_reply_command(post_id, reply_data)
    PostRepository.add_reply(post_id, reply_data)
  end
  
  # 純粋関数：成功時の処理
  def handle_reply_creation_result(post_aggregate)
    if post_aggregate
      latest_reply = post_aggregate.latest_reply
      respond_to do |format|
        format.html { redirect_to post_path(post_aggregate.id), notice: '返信が投稿されました。' }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              "replies_list",
              partial: "replies/reply_item",
              locals: { reply: reply_view_model(latest_reply) }
            ),
            turbo_stream.replace(
              "reply_form",
              partial: "replies/form",
              locals: { post_id: post_aggregate.id, form: reply_form_model }
            )
          ]
        end
      end
    else
      handle_reply_creation_error(['投稿の更新に失敗しました。'])
    end
  end
  
  # 純粋関数：エラー時の処理
  def handle_reply_creation_error(errors)
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: errors.join(', ')) }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reply_form",
          partial: "replies/form_with_errors",
          locals: { errors: errors, form: reply_form_model(reply_params, errors) }
        )
      end
    end
  end
  
  # 純粋関数：ビューモデルを生成
  def reply_view_model(reply_data)
    ReplyViewModel.new(reply_data)
  end
  
  def reply_form_model(params = {}, errors = nil)
    ReplyFormModel.new(params, errors)
  end
  
  def reply_params
    params.require(:reply).permit(:content, :author_name)
  end
end
```

### ビューモデル（Presentation Layer）

#### PostViewModel
```ruby
class PostViewModel
  attr_reader :id, :title, :content, :author_name, :created_at, :reply_count, :summary
  
  def initialize(post_aggregate)
    @id = post_aggregate.id
    @post_data = post_aggregate.post_data
    @title = @post_data.title
    @content = @post_data.content
    @author_name = @post_data.author_name
    @created_at = @post_data.created_at
    @reply_count = post_aggregate.reply_count
    @summary = @post_data.summary_content
    @replies = post_aggregate.replies_chronological.map { |reply| ReplyViewModel.new(reply) }
    freeze
  end
  
  def replies
    @replies
  end
  
  def formatted_created_at
    @created_at.strftime('%Y年%m月%d日 %H:%M')
  end
  
  def has_replies?
    @reply_count > 0
  end
  
  def ==(other)
    other.is_a?(self.class) && id == other.id
  end
end
```

#### ReplyViewModel
```ruby
class ReplyViewModel
  attr_reader :content, :author_name, :created_at
  
  def initialize(reply_data)
    @content = reply_data.content
    @author_name = reply_data.author_name
    @created_at = reply_data.created_at
    freeze
  end
  
  def formatted_created_at
    @created_at.strftime('%Y年%m月%d日 %H:%M')
  end
  
  def ==(other)
    other.is_a?(self.class) &&
      content == other.content &&
      author_name == other.author_name &&
      created_at == other.created_at
  end
end
```

#### フォームモデル
```ruby
class PostFormModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :title, :string
  attribute :content, :string
  attribute :author_name, :string
  
  def initialize(params = {}, errors = nil)
    super(params)
    @custom_errors = errors || {}
    freeze
  end
  
  def errors_for(field)
    @custom_errors[field] || []
  end
  
  def has_errors?
    @custom_errors.any?
  end
end

class ReplyFormModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :content, :string
  attribute :author_name, :string
  
  def initialize(params = {}, errors = nil)
    super(params)
    @custom_errors = errors || {}
    freeze
  end
  
  def errors_for(field)
    @custom_errors[field] || []
  end
  
  def has_errors?
    @custom_errors.any?
  end
end
```

## フロントエンド設計（モダン技術）

### Tailwind CSS統合

#### Gemfile
```ruby
gem 'tailwindcss-rails', '~> 2.0'
# jQueryは不要
```

#### 設定ファイル（config/importmap.rb）
```ruby
# Stimulus
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# Turbo
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
```

#### Tailwindスタイル（app/assets/stylesheets/application.tailwind.css）
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* カスタムコンポーネント */
@layer components {
  .post-card {
    @apply bg-white rounded-lg shadow-md p-6 mb-4 hover:shadow-lg transition-shadow;
  }
  
  .reply-section {
    @apply bg-gray-50 rounded-lg p-4 mt-4;
  }
  
  .btn-primary {
    @apply bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition-colors;
  }
}
```

### Stimulus Controllers（jQueryの代替）

#### 投稿フォーム Controller
```javascript
// app/javascript/controllers/post_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "counter"]
  
  connect() {
    this.updateCounter()
  }
  
  updateCounter() {
    const remaining = 1000 - this.contentTarget.value.length
    this.counterTarget.textContent = `残り${remaining}文字`
    
    if (remaining < 0) {
      this.counterTarget.classList.add("text-red-500")
    } else {
      this.counterTarget.classList.remove("text-red-500")
    }
  }
}
```

#### モーダル Controller
```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]
  
  open() {
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }
  
  close() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
  
  closeOnClickOutside(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
```

### レスポンシブデザイン
- Tailwind Gridシステム使用
- モバイルファーストアプローチ
- ブレークポイント: sm（640px）、md（768px）、lg（1024px）、xl（1280px）

## セキュリティ設計（Rails 8対応）

### Rails 8標準セキュリティ機能
- **CSRF保護**: `protect_from_forgery`（Turbo対応）
- **SQLインジェクション対策**: Strong Parameters
- **XSS対策**: ERBとTailwindの組み合わせで安全なHTML生成
- **Built-in Authentication**: 将来的な拡張で認証機能を簡単に追加可能

### Hotwireセキュリティ
- **Turbo Security**: CSRFトークンの自動処理
- **Stimulus Security**: XSS攻撃に対する堅牢性

## パフォーマンス設計（Rails 8最適化）

### Solid Cache活用
```ruby
# config/environments/production.rb
config.cache_store = :solid_cache_store
```

### Turboによる最適化
- **Turbo Drive**: ページ遷移の高速化
- **Turbo Frames**: 部分更新によるトラフィック削減
- **Turbo Streams**: リアルタイム更新の効率化

### データベース最適化
- **N+1問題対策**: `includes`と`preload`の適切な使用
- **インデックス最適化**: Solid Cache対応インデックス
- **ViewComponent**: ビューロジックの効率化

## 開発・デプロイメント（Rails 8対応）

### 開発環境
- **Rails server**: Puma
- **データベース**: SQLite3 + Solid Cache
- **アセット**: Propshaft + ImportMaps
- **CSS**: Tailwind CSS Rails gem

### Kamal 2デプロイメント
```yaml
# config/deploy.yml
service: bulletin_board_app

image: bulletin_board_app

servers:
  web:
    - 192.168.1.1

registry:
  username: your_username

env:
  clear:
    DB_HOST: localhost
  secret:
    - RAILS_MASTER_KEY
```

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

### Railsアプリケーション生成（Rails 8）
```bash
rails new bulletin_board_app --css=tailwind --javascript=importmap
cd bulletin_board_app

# Rails 8の新機能を有効化
rails generate solid_cache:install
rails generate solid_queue:install
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

## イミュータブル設計のメリット

### 1. 予測可能性（Predictability）
- データの状態が不変なため、デバッグが容易
- 副作用の発生箇所が限定される
- 並行処理でのデータ競合を防ぐ

### 2. テスタビリティ（Testability）
- 純粋関数は同じ入力に対して同じ出力を保証
- モックの必要性が減少
- 単体テストが書きやすい

### 3. 保守性（Maintainability）
- データフローが明確
- 変更の影響範囲が限定される
- リファクタリングが安全

### 4. パフォーマンス（Performance）
- オブジェクトの共有が安全
- メモ化（Memoization）が適用しやすい
- ガベージコレクションの最適化

## アーキテクチャ図

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐  │
│  │   Controllers   │  │  View Models    │  │   Views  │  │
│  │  (Side Effects) │  │ (Immutable)     │  │ (Turbo)  │  │
│  └─────────────────┘  └─────────────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────┐
│                   Application Layer                     │
│  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Repositories  │  │    Commands     │                │
│  │  (Query/CQRS)   │  │ (Side Effects)  │                │
│  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐  │
│  │  Value Objects  │  │   Aggregates    │  │  Domain  │  │
│  │  (Immutable)    │  │  (Immutable)    │  │ Services │  │
│  └─────────────────┘  └─────────────────┘  └──────────┘  │
└─────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────┐
│                 Infrastructure Layer                    │
│  ┌─────────────────┐  ┌─────────────────┐                │
│  │  ActiveRecord   │  │   Database      │                │
│  │  (Read Models)  │  │   (SQLite3)     │                │
│  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────┘
```

## テスト戦略（イミュータブル対応）

### 単体テスト（Unit Tests）
```ruby
# 値オブジェクトのテスト
RSpec.describe PostData do
  describe '#with_updates' do
    it '新しいインスタンスを返す' do
      original = PostData.new(title: 'タイトル', content: '内容', author_name: '作者')
      updated = original.with_updates(title: '新タイトル')
      
      expect(updated).not_to be(original)
      expect(updated.title).to eq('新タイトル')
      expect(updated.content).to eq('内容')
    end
  end
  
  describe 'immutability' do
    it 'オブジェクトが凍結されている' do
      post_data = PostData.new(title: 'タイトル', content: '内容', author_name: '作者')
      expect(post_data).to be_frozen
    end
  end
end

# 集約のテスト
RSpec.describe PostAggregate do
  describe '#add_reply' do
    it '新しい集約を返す' do
      post_data = PostData.new(title: 'タイトル', content: '内容', author_name: '作者')
      original_aggregate = PostAggregate.new(id: 1, post_data: post_data)
      reply_data = ReplyData.new(content: '返信', author_name: '返信者')
      
      updated_aggregate = original_aggregate.add_reply(reply_data)
      
      expect(updated_aggregate).not_to be(original_aggregate)
      expect(updated_aggregate.reply_count).to eq(1)
      expect(original_aggregate.reply_count).to eq(0)
    end
  end
end
```

### 統合テスト（Integration Tests）
```ruby
RSpec.describe PostRepository do
  describe '.create_post' do
    it 'PostAggregateを返す' do
      post_data = PostData.new(title: 'テスト', content: '内容', author_name: '作者')
      result = PostRepository.create_post(post_data)
      
      expect(result).to be_a(PostAggregate)
      expect(result.post_data.title).to eq('テスト')
    end
  end
end
```

## 今後の拡張予定（イミュータブル対応）

### フェーズ2機能
- **Event Sourcing**: イベントストリームによる状態管理
- **Snapshot Pattern**: 集約の状態スナップショット
- **Time Travel Debugging**: 状態の履歴追跡

### フェーズ3機能
- **Redux Pattern**: フロントエンドとの状態同期
- **Functional Reactive Programming**: リアクティブな状態更新
- **Microservices**: サービス間の不変データ交換

## パフォーマンス指標（イミュータブル対応）

### メモリ使用量の最適化
- **Object Sharing**: 不変オブジェクトの安全な共有
- **Structural Sharing**: 部分的な変更時の効率的なコピー
- **Garbage Collection**: 不要オブジェクトの効率的な回収

### データベースクエリの最適化
- **CQRS**: 読み取りと書き込みの分離によるパフォーマンス向上
- **Read Models**: 最適化された読み取り専用ビュー
- **Command Batching**: 書き込み処理のバッチ化

イミュータブルデータモデルを採用することで、従来のRails MVCパターンをより安全で予測可能なアーキテクチャに変革し、大規模なアプリケーションでも保守性とパフォーマンスを両立できます。