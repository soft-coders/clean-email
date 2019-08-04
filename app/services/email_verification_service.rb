class EmailVerificationService
  require 'resolv'

  # Original REGEX is this https://github.com/ruby/ruby/blob/ruby_2_5/lib/uri/mailto.rb#L56
  # We have modified it to not allow email with format like "something@somewhere"
  EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\.[a-z]{2,}\z/

  def self.call(email_list_id: nil)
    new(email_list_id).call
  end

  def call
    @email_list.emails.find_each do |email|
      host = host(email.address)
      update_params = {
        format_validity: (email.address =~ EMAIL_REGEXP).present?,
        mx_record_validity: mx_record_exists?(host),
        domain_validity: ns_record_exists?(host),
      }

      update_params.merge!(is_valid: update_params.values.uniq.exclude?(false))
      
      email.update_columns(update_params)
    end
    @email_list.update_columns(verified: true)
  end

  def host(email_address)
    email_address.match(/\@(.+)/)[1]
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
