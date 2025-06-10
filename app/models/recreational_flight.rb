class RecreationalFlight < ApplicationRecord
  before_validation :strip_phone_number
  after_save :to_ghl
  after_save :to_portal

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, format: { with: /\A\d{10}\z/, message: "must be a valid 10-digit phone number" }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }

  def strip_phone_number
    self.phone = phone.to_s.gsub(/[-() ]/, "")
  end

  def to_ghl
    ghl_url = ENV['ghl_recreational']
    ghl_payload = {
      "first-name" => "#{self.first_name}",
      "last-name" => "#{self.last_name}",
      "email" => "#{self.email}",
      "phone" => "#{self.phone}",
      "occasion" => "#{self.occasion}",
      "preferred-date" => "#{self.preferred_date}",
      "preferred-availability" => "#{self.preferred_availability}",
      "alternate-date" => "#{self.alternate_date}",
      "alternate-availability" => "#{self.alternate_availability}",
      "comments" => "#{self.comments}"
    }
    HTTParty.post(ghl_url, body: ghl_payload.to_json, headers: { "Content-Type" => "application/json" })
  end

  def to_portal
    portal_url = "https://portal.rightruddermarketing.com/api/leads"
    api_key = ENV['PORTAL_API_KEY']
    portal_payload = {
      "first_name": "#{self.first_name}",
      "last_name": "#{self.last_name}",
      "email": "#{self.email}",
      "phone": "#{self.phone}",
      "campaign": "recreational_flight",
      "account_random_id": "ac_h1zhallf",
      "metadata": {
        "occasion": "#{self.occasion}",
        "preferred-date": "#{self.preferred_date}",
        "preferred-availability": "#{self.preferred_availability}",
        "alternate-date": "#{self.alternate_date}",
        "alternate-availability": "#{self.alternate_availability}",
        "comments": "#{self.comments}"
      }
    }     
    HTTParty.post(portal_url, body: portal_payload.to_json, headers: { "Content-Type": "application/json", "X-API-Key": api_key })
  end
end
