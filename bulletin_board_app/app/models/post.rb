class Post < ApplicationRecord
  has_many :replies, dependent: :destroy

  def readonly?
    !new_record?
  end

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
