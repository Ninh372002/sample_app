class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  def show; end



  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def set_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:warning] = 'User not found!'
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit :name, :email, :password,
                                 :password_confirmation
  end
end
