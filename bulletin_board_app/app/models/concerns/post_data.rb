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
    freeze
  end

  def with_updates(updates = {})
    self.class.new(
      title: updates.fetch(:title, title),
      content: updates.fetch(:content, content),
      author_name: updates.fetch(:author_name, author_name),
      created_at: created_at
    )
  end

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
    [ title, content, author_name ].hash
  end
end
