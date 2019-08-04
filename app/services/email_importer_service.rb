class EmailImporterService
  require 'csv'

  def self.call(email_list: nil)
    new(email_list).call
  end

  def call
    email_column = @email_list.email_column
    csv_path = ActiveStorage::Blob.service.send(:path_for, @email_list.email_csv.key)
    CSV.foreach(csv_path, headers: true) do |row|
      Email.create(email_list: @email_list, address: row[email_column])
    end
  end

  private

  def initialize(email_list)
    @email_list = email_list
  end
end
