class PostRepository
  class << self
    def all_posts
      Post.by_newest.with_replies.map(&:to_post_aggregate)
    end

    def find_post(id)
      post_record = Post.find(id)
      post_record.to_post_aggregate
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def create_post(post_data)
      command = PostCommand.new(
        title: post_data.title,
        content: post_data.content,
        author_name: post_data.author_name
      )
      command.execute
    end

    def add_reply(post_id, reply_data)
      command = ReplyCommand.new(
        post_id: post_id,
        content: reply_data.content,
        author_name: reply_data.author_name
      )
      command.execute
    end
  end
end
