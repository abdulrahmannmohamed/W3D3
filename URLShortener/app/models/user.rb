class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_many(:submitted_urls,
    class_name: :ShortenedURL,
    foreign_key: :user_id
  )

  has_many( :visits,
    class_name: :Visit,
    foreign_key: :user_id
  )

  has_many( :visited_urls,
    ->{ distinct },
    through: :visits,
    source: :url_visited
  )
end
