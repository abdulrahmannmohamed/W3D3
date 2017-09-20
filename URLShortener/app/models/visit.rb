class Visit < ApplicationRecord

 validates :user_id, presence: true
 validates :url_id, presence: true

 belongs_to( :visitor,
   class_name: :User,
   foreign_key: :user_id
 )
 belongs_to( :url_visited,
   class_name: :ShortenedURL,
   foreign_key: :url_id
 )

 def self.record_visit!(user, shortened_url)
   Visit.new(user_id: user.id, url_id: shortened_url.id)
 end


end
