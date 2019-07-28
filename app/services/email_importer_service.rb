class EmailImporterService
  require 'csv'

  def self.call(email_list: nil, csv_file: nil)
    new(email_list, csv_file).call
  end

  def call
    CSV.foreach(@csv_file.path, headers: true) do |row|
      Email.new(email_list: @email_list, address: row[0]).save
    end
  end

  private

  def initialize(email_list, csv_file)
    @email_list = email_list
    @csv_file = csv_file
  end
end
