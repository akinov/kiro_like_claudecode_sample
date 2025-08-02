class PostCommand
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :content, :string
  attribute :author_name, :string

  validates :title, presence: true, length: { maximum: 100 }
  validates :content, presence: true, length: { maximum: 1000 }
  validates :author_name, presence: true, length: { maximum: 50 }

  def execute
    return nil unless valid?

    post_record = Post.create!(
      title: title,
      content: content,
      author_name: author_name
    )

    post_record.to_post_aggregate
  end
end
