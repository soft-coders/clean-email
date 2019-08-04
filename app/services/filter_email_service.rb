class FilterEmailService
  require 'resolv'
  require 'csv'

  # Original REGEX is this https://github.com/ruby/ruby/blob/ruby_2_5/lib/uri/mailto.rb#L56
  # We have modified it to not allow email with format like "something@somewhere"
  EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-z]{2,}\z/

  def self.call(email_list_id: nil)
    new(email_list_id).call
  end

  def call
    email_column = @email_list.email_column
    csv_path = ActiveStorage::Blob.service.send(:path_for, @email_list.email_csv.key)


    filtered_csv = CSV.generate do |csv|
                    csv << headers(csv_path)
                    CSV.foreach(csv_path, headers: true) do |row|
                      email_address = row[email_column]
                      email = import_email(email_address)
                      csv << row.to_h.values if email.is_valid?
                    end
                  end
      
    @email_list.filtered_email_csv.attach(io: StringIO.new(filtered_csv), filename: "filtered_#{@email_list.name}.csv", content_type: "application/csv")
    
    @email_list.update_columns(verified: true)
  end

  def headers(csv_path)
    CSV.open(csv_path, &:readline)
  end

  def import_email(email_address)
    host = host(email_address)
    params = {
      address: email_address,
      format_validity: (email_address =~ EMAIL_REGEXP).present?,
      mx_record_validity: !!(mx_record_exists?(host) if host),
      domain_validity: !!(ns_record_exists?(host) if host),
    }

    params.merge!(email_list_id: @email_list.id, is_valid: params.values.uniq.exclude?(false))
    
    Email.create!(params)
  end

  def host(email_address)
    email_address.match(/\@(.+)/).to_a[1]
  end

  def mx_record_exists?(host)
    Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::MX).any?
  end

  def ns_record_exists?(host)
    Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::NS).any?
  end

  def initialize(email_list_id)
    @email_list = EmailList.find(email_list_id)
  end
end
