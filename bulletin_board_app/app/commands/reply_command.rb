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

    post_record.reload.to_post_aggregate
  end
end
