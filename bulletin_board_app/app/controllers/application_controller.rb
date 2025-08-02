class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
