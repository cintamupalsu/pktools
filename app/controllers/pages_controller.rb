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
  
  def user_statistic
    @selected_item=1
    @users = User.all
    @bunsho = {}
    @kaito = {}
    @file_use ={}
    @sentence_use ={}
    @users.each do |user|
      @bunsho[user.id]=user.watson_language_master_ids.count
      @kaito[user.id]=user.answer_denpyo_ids.count
      @file_use[user.id]=user.file_manager_ids.count
      @sentence_use[user.id]=user.sentence_ids.count
    end
  end
  
end
