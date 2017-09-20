class Tag < ApplicationRecord
  validates :topic, presence: true

  has_many( :taggings,
    class_name: :Tagging,
    foreign_key: :tag_id
  )

  has_many( :tagged_urls,
    through: :taggings,
    source: :url
  )

  def popular_links
    #sort urls by clicks desc
    sorted_urls = self.tagged_urls.sort { |url1, url2| url2.num_clicks <=> url1.num_clicks }.take(5)
    #map to hash of ShortenedURL => num_clicks
    sorted_urls.map do |url|
      [url, url.num_clicks]
    end.to_h
  end


end
