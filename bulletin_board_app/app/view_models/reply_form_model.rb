class ReplyFormModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :content, :string
  attribute :author_name, :string

  def initialize(params = {}, errors = nil)
    super(params)
    @custom_errors = errors || {}
    freeze
  end

  def errors_for(field)
    @custom_errors[field] || []
  end

  def has_errors?
    @custom_errors.any?
  end
end
