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
      redirect_to root_path, alert: "投稿が見つかりませんでした。"
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
        format.html { redirect_to post_path(post_aggregate.id), notice: "投稿が作成されました。" }
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
