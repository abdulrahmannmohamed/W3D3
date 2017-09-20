class Tagging < ApplicationRecord
  validates :tag_id, presence: true
  validates :url_id, presence: true

  belongs_to( :tag,
    class_name: :Tag,
    foreign_key: :tag_id
  )

  belongs_to( :url,
    class_name: :ShortenedURL,
    foreign_key: :url_id
  )

  def self.add_tag(url, tag)
    Tagging.new(url_id: url.id, tag_id: tag.id)
  end

end
