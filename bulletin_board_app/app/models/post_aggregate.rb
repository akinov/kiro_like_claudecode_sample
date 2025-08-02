class PostAggregate
  attr_reader :id, :post_data, :replies

  def initialize(id:, post_data:, replies: [])
    @id = id
    @post_data = post_data.freeze
    @replies = replies.map(&:freeze).freeze
    freeze
  end

  def add_reply(reply_data)
    raise ArgumentError, "無効な返信データ" unless reply_data.valid?

    new_replies = @replies + [ reply_data ]
    self.class.new(
      id: @id,
      post_data: @post_data,
      replies: new_replies
    )
  end

  def reply_count
    @replies.length
  end

  def replies_chronological
    @replies.sort_by(&:created_at)
  end

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
