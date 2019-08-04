class EmailList < ApplicationRecord

  validates :name, :email_column, presence: true

  has_many :emails, dependent: :destroy
  has_one_attached :email_csv
  has_one_attached :filtered_email_csv

end
