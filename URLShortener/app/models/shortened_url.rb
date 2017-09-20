require 'SecureRandom'


class ShortenedURL < ApplicationRecord
  validate :non_premium_limit, :no_spam

  def self.random_code
    SecureRandom.urlsafe_base64(16)
  end

  def self.shorten!(user, long_url)
    new_short_url = ShortenedURL.new(user_id: user.id, long_url: long_url)
    short_url = nil
    loop do
      short_url = ShortenedURL.random_code
      break unless ShortenedURL.exists?(short_url: short_url)
    end
    new_short_url.short_url = short_url
    new_short_url.save!
    new_short_url
  end

  def self.prune(n)
    recent_visits = Visit.where(created_at: (n.minutes.ago..Time.now))
    recent_v_ids = recent_visits.map { |visit| visit.url_id }
    recently_created = ShortenedURL.where(created_at: (n.minutes.ago..Time.now))
    recent_c_ids = recently_created.map { |url| url.id }
    dont_delete = recent_v_ids | recent_c_ids
    ShortenedURL.where.not(id: dont_delete).each do |url|
      url.visits.each { |visit| url.visits.destroy(visit) }
      url.taggings.each { |tagging| url.taggings.destroy(tagging) }
      url.delete
    end
  end


  def no_spam
    submitter = User.find(user_id)
    unless submitter.submitted_urls.where({created_at:(1.minutes.ago..Time.now)}).count < 5
      errors.add(:num_submissions, "cannot exceed 5 in one minute")
    end
  end

  def non_premium_limit
    submitter = User.find(user_id)
    if submitter.submitted_urls.count == 5 && !submitter.premium
      errors.add(:nonpremium_users, "cannot shorten more than 5 links")
    end
  end

  belongs_to(:submitter,
    class_name: User,
    foreign_key: :user_id
  )

  has_many( :visits,
    class_name: :Visit,
    foreign_key: :url_id
  )

  has_many( :visitors,
    ->{ distinct },
    through: :visits,
    source: :visitor
  )

  has_many( :taggings,
    class_name: :Tagging,
    foreign_key: :url_id
  )

  has_many( :tags,
    through: :taggings,
    source: :tag
  )

  def num_clicks
    self.visits.count
  end

  def num_uniques
    self.visitors.count
  end

  def num_recent_uniques
    self.visits.where({created_at: (10.minutes.ago..Time.now)}).select(:user_id).distinct.count

  end




end
