class PagesController < ApplicationController
  def index
     @countrecords = countStorage
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
    @countrecords = countStorage
    @noanswer=0.0
    @countsentence = Sentence.count.to_f
    allsent=0
    wlus = WatsonLanguageMaster.where("anchor = -1")
    wlus.each do |wlu|
      if wlu.answer_denpyo_ids.count==0
        @noanswer+=1
      end
      allsent+=1
    end
    @rep01 = (@noanswer.to_f/allsent.to_f*20-10)*-1
    @rep02 = (@countsentence/allsent.to_f*20-10)*-1

  end
  
  def countStorage
    countrecords=0
    countrecords=User.count
    countrecords+=WatsonLanguageMaster.count
    countrecords+=Question.count
    countrecords+=Answer.count
    countrecords+=FileManager.count
    countrecords+=Company.count
    countrecords+=Hospital.count
    countrecords+=Vendor.count
    countrecords+=Sentence.count
    countrecords+=AnswerDenpyo.count
    countrecords+=Setting.count
    countrecords=(countrecords/50)
    return countrecords
  end
end
