class ReplyViewModel
  attr_reader :content, :author_name, :created_at

  def initialize(reply_data)
    @content = reply_data.content
    @author_name = reply_data.author_name
    @created_at = reply_data.created_at
    freeze
  end

  def formatted_created_at
    @created_at.strftime("%Y年%m月%d日 %H:%M")
  end

  def ==(other)
    other.is_a?(self.class) &&
      content == other.content &&
      author_name == other.author_name &&
      created_at == other.created_at
  end
end
