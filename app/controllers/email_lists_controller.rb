class EmailListsController < ApplicationController
  before_action :authenticate_user!
  def index
    @email_lists = EmailList.where(user_id: current_user.id)
  end

  def new
    @email_list = EmailList.new
  end

  def show
    @email_list = EmailList.find_by(user_id: current_user.id, id: params[:id])
    @emails = @email_list.emails.page params[:page]
  end

  def create
    file = email_list_params[:csv_file]
    list_name = email_list_params[:name].present? ? email_list_params[:name] : file.original_filename
    
    email_list = EmailList.new(name: list_name, user_id: current_user.id)

    if email_list.save!
      if file.present?
        EmailImporterService.call(email_list: email_list, csv_file: file)
      end
      VefifyEmailJob.perform_later(email_list.id)
      redirect_to email_list, notice: "Emails list was imported sucessfully"
    else
      render :new
    end
  end

  def edit
  end

  def update

  end

  def destroy
  end

  private

  def email_list_params
    params.require(:email_list).permit(:name, :csv_file)
  end
end
