class EmailListsController < ApplicationController
  def index
    @email_lists = EmailList.all
  end

  def new
    @email_list = EmailList.new
  end

  def show
    @email_list = EmailList.find(params[:id])
    @emails = @email_list.emails.page params[:page]
  end

  def create
    file = email_list_params[:csv_file]
    email_list = EmailList.new(name: email_list_params[:name] || file.original_filename)
    if email_list.save!
      if file.present?
        byebug
        EmailImporterService.call(email_list: email_list, csv_file: file)
      end
      VefifyEmailJob.perform_later(email_list.id)
      redirect_to email_list
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
