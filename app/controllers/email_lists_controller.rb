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
    email_list = EmailList.new(email_list_params.merge(user_id: current_user.id))

    if email_list.save!
      EmailImporterService.call(email_list: email_list)
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
    params.require(:email_list).permit(:name, :email_column, :email_csv)
  end
end
