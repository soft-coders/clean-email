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
    params = email_list_params
    params[:name] = params[:email_csv].original_filename.split(".csv").first unless params[:name].present?
    email_list = EmailList.new(params.merge(user_id: current_user.id))

    if email_list.save!
      
      FilterEmailJob.perform_later(email_list.id)
      redirect_to email_list, notice: "Email list was imported sucessfully"
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
