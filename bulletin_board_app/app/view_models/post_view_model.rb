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
    @created_at.strftime("%Y年%m月%d日 %H:%M")
  end

  def has_replies?
    @reply_count > 0
  end

  def ==(other)
    other.is_a?(self.class) && id == other.id
  end
end
