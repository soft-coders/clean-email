class Email < ApplicationRecord
  validates :address, presence: true
  belongs_to :email_list
end
