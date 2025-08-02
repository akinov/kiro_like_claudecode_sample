class Reply < ApplicationRecord
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
