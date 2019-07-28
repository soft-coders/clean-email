class EmailList < ApplicationRecord
  require 'csv'

  validates :name, presence: true

  has_many :emails, dependent: :destroy
end
