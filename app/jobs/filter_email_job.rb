class FilterEmailJob < ApplicationJob
  queue_as :default

  def perform(email_list_id)
    FilterEmailService.call(email_list_id: email_list_id)
  end
end
