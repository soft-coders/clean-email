class VefifyEmailJob < ApplicationJob
  queue_as :default

  def perform(email_list_id)
    EmailVerificationService.call(email_list_id: email_list_id)
  end
end
