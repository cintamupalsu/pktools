class PagesController < ApplicationController
  def index

  end
  
  def user_management
    @users = User.all
    @selected_item=0
  end
  
  def downgrade 
    if current_user.marshal
      user = User.find(params[:id])
      user.update_attributes(marshal: false)
      flash[:info] = user.email + " has been downgraded"
    else
      flash[:danger] = "You are not an admin, get away!"
    end
    redirect_to user_management_path
  end
  
  def promote
    if current_user.marshal
      user = User.find(params[:id])
      user.update_attributes(marshal: true)
      flash[:success] = user.email + " has been Promoted"
    else
      flash[:danger] = "You are not an admin, get away!"
    end
    redirect_to user_management_path
  end
  
  def detach
    if current_user.marshal
      user = User.find(params[:id])
      user.update_attributes(activated: false)
      flash[:info] = user.email + " has been detached"
    else
      flash[:danger] = "You are not an admin, get away!"
    end
    redirect_to user_management_path
  end
  
  def activate
    if current_user.marshal
      user = User.find(params[:id])
      user.update_attributes(activated: true)
      flash[:success] = user.email + " has been activated"
    else
      flash[:danger] = "You are not an admin, get away!"
    end
    redirect_to user_management_path
  end
  
end
