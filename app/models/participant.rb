require 'date_of_birth'

# Person registered in the system.
class Participant < ActiveRecord::Base
  def to_param  # overridden
    external_id
  end

  has_one :date_of_birth, -> { select(:participant_id, :date_of_birth) }
  has_one :name
  has_one :social_security_number

  has_many :addresses, (lambda do
    select(:participant_id, :name, :street_1, :street_2, :city, :state, :zip,
           :primary)
  end)
  has_many :emails
  has_many :health_insurance_beneficiary_numbers
  has_many :ip_address_numbers
  has_many :medical_record_numbers
  has_many :phones, -> { select(:participant_id, :name, :number, :primary) }
end
