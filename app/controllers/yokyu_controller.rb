class YokyuController < ApplicationController
  def index
    @selected_item=0;
  end

  def learn
    if params[:learning]!=nil
      t_learn = Thread.new{
        read_file(learning_params)
        similarity_check
      }
      flash[:info] = "取り込んでいます"
    else
      flash[:success] = "ファイルなし"
    end
    @selected_item=0;
    render 'index'
  end
  
  def write
  end

  def answer
  end
  
  def questions
    @selected_item=4;
    @questions= Question.where("user_id=?", current_user.id)
  end
  
  def question_show
    @selected_item=4;
    @question = Question.find(params[:id])
    @answers = Answer.where("question_id=?", @question.id)
  end
  
  def question_new
    @selected_item=4;
    @question = Question.new
  end
  
  def question_create
    @question = Question.new(question_params)
    @question.user_id = current_user.id
    if Question.where("user_id=?", current_user.id).count==0
      @question.mark=1
    else
      @question.mark=0
    end
    if @question.save
      flash[:info] = "要求を登録しました。"
      redirect_to question_path(:id => @question.id)
    else
      render 'question_new'
    end
  end
  
  def question_edit
    @question = Question.find(params[:id])
  end
  
  def question_update
    @question = Question.find(question_params['id'].to_i)
    if @question.update_attributes(question_params)
       flash[:success] = "要求を編集した"
       redirect_to question_path(:id => @question.id)
    else
       render 'edit'
    end
  end
  
  def question_default
    question = Question.where("user_id=? AND mark=?", current_user.id, 1).first
    question.update_attributes(mark: 0)
    question = Question.find(params[:id])
    question.update_attributes(mark: 1)
    redirect_to questions_url
  end  
  
  def question_destroy
    
    question = Question.find(params[:id])
    if question.mark==1
      questions = Question.where("user_id=?",current_user)
      if questions.count>0
        questions[0].update_attributes(mark: 1)
      end
    end
    question.destroy
    flash[:success] = "要求を削除しました"
    redirect_to questions_url
    
  end

  
  def answer_new
    @answer = Answer.new
    @question = Question.find(params[:id])
  end
  
  def answer_create
    @answer = Answer.new(answer_params)
    @answer.user_id = current_user.id
    if @answer.save
      flash[:info] = "回答を登録しました。"
      redirect_to question_path(:id => @answer.question_id)
    else
      render 'answer_new'
    end
  end
  
  def answer_edit
    @answer = Answer.find(params[:id])
    @question = Question.find(@answer.question_id)
  end
  
  def answer_update
    @answer = Answer.find(answer_params['id'].to_i)
    if @answer.update_attributes(answer_params)
       flash[:success] = "回答を編集した"
       redirect_to question_path(:id => @answer.question_id)
    else
       render 'answer_edit'
    end
  end
  
  def answer_destroy
    answer = Answer.find(params[:id])
    question_id=answer.question_id
    answer.destroy
    flash[:success] = "回答を削除しました"
    redirect_to question_path(:id => question_id)
  end
  
  private
  
  def learning_params
    params.require(:learning).permit(:filename)    
  end
  
  def company_params
    params.require(:company).permit(:name, :address, :co_type)
  end
  
  def question_params
    params.require(:question).permit(:id, :name, :column)
  end

  def answer_params
    params.require(:answer).permit(:id, :name, :column, :question_id)
  end
  
  def read_file(input_params)
    # read excels
    file_xls = input_params["filename"]
    workbook = RubyXL::Parser.parse(file_xls.path)
    
    worksheet = workbook[0]
    (4..6).each do |row|
      WatsonLanguageMaster.create!(content: worksheet[row][3].value, user_id: current_user.id)
    end
  end
  
  def similarity_check
  end
  
  
end
