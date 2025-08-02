class RepliesController < ApplicationController
  def create
    reply_data = build_reply_data(reply_params)

    if reply_data.valid?
      result = create_reply_command(params[:post_id], reply_data)
      handle_reply_creation_result(result)
    else
      handle_reply_creation_error(reply_data.errors.full_messages)
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
        format.html { redirect_to post_path(post_aggregate.id), notice: "返信が投稿されました。" }
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
      handle_reply_creation_error([ "投稿の更新に失敗しました。" ])
    end
  end

  # 純粋関数：エラー時の処理
  def handle_reply_creation_error(errors)
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: errors.join(", ")) }
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
