# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true
  
  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: 'User'
  
  has_many :visits, 
    primary_key: :id, 
    foreign_key: :shortened_url_id,
    class_name: 'Visit'
  
  has_many :visitors,
    { distinct },
    through: :visits,
    source: :visitor
    
  def self.shorty_code(user, longy_code)
    ShortenedUrl.create!(long_url: longy_code, short_url: ShortenedUrl.random_code, user_id: user.id)
  end
  
  def self.random_code
    loop do
      random_code = SecureRandom.urlsafe_base64(16)
      return random_code unless ShortenedUrl.exists?(short_url: random_code)
    end
  end
  
  def num_clicks
    visits.count
  end
  
  def num_uniques
    visitors.count
  end
  
  def num_recent_uniques
    visits.select('user_id').where('created_at > ?', 10.minutes.ago).distinct.count
  end
  
end
