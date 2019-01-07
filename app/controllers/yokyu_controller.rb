class YokyuController < ApplicationController
  before_action :notices
  def index
    init_index
  end

  def learn
    init_index
    if learning_params['filename']!=nil
      # check variables
      ws_from = learning_params['worksheetfrom'].to_i
      ws_to = learning_params['worksheetto'].to_i
      hospital_id = Hospital.where("company_id=?",learning_params['hospital'].to_i).first.id 
      vendor_id = Vendor.where("company_id=?",learning_params['vendor'].to_i).first.id 
      if ws_from<=ws_to
        backjob = Backjob.create(name: "Read XLS", status: 0)

        threshold = 0.1
        # check variables
        ws_from = learning_params["worksheetfrom"].to_i-1
        ws_to = learning_params['worksheetto'].to_i-1
        question_col = backjob.string_to_col(learning_params['question'])
        first_row = learning_params['first_row'].to_i-1
        file_xls = learning_params['filename']
        file_manager = FileManager.create(name: file_xls.path, user_id: current_user.id)
        # read file
        workbook = RubyXL::Parser.parse(file_xls.path)
        (ws_from..ws_to).each do |ws|
          worksheet = workbook[ws] 
          question=Array.new(worksheet.count)
          answer=Array.new(@question.answers.count)
          answer_id=Array.new(@question.answers.count)
          (0..@question.answers.count-1).each do |ans|
            answer[ans]=Array.new(worksheet.count)
            answer_id[ans]=learning_params['answer_id'][ans].to_i
          end
          
          (first_row..worksheet.count-1).each do |row|
            if worksheet[row][question_col]!=nil
              question[row]=worksheet[row][question_col].value.to_s
            end
            (0..@question.answers.count-1).each do |ans|
              answer_col = backjob.string_to_col(learning_params['answer'][ans])
              if worksheet[row][answer_col]!= nil
                answer[ans][row] = worksheet[row][answer_col].value.to_s
              end
            end
          end
          #learning(natural_language_understanding, file_manager, question, answer, current_user, answer_id, hospital_id, vendor_id)
          backjob.delay.learning(natural_language_understanding, file_manager, question, answer, current_user, answer_id, hospital_id, vendor_id)
        end
        flash[:info] = "取り込んでいます"
        
      else
        flash[:danger] = "Error!"
      end
    else
      flash[:success] = "ファイルなし"
    end
    
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
  
  def confirm
    @selected_item = 3
    @sentences = Sentence.where("user_id=?",current_user.id)
  end
  
  def confirmed
    onaji = check_box_bug(kakunin_params['onaji'])
    (0..kakunin_params['sentence_id'].count-1).each do |i|
      sentence = Sentence.find_by(id: kakunin_params['sentence_id'][i])
      if onaji[i]==1 #if similar
        wlm = WatsonLanguageMaster.find_by(id: sentence.watson_language_master_id)
        wlm.update_attributes(anchor: sentence.wlu)
        answers = AnswerDenpyo.where("watson_language_master_id=?", sentence.watson_language_master_id)
        answers.each do |answer|
          answer.update_attributes(watson_language_master_id: sentence.wlu)
        end
      end
      sentence.destroy
    end
    redirect_to yokyu_path
  end
  
  private
  
  def learning_params
    params.require(:learning).permit(:filename, :question, :worksheetfrom, :worksheetto, :vendor, :hospital, :first_row, :answer=>[], :answer_id=>[])    
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
  
  def kakunin_params
    params.require(:kakunin).permit(:sentence_id=>[], :onaji=>[])
  end
  
  def string_to_col(colname)
    colname = colname.upcase
    colnumber = 0
    (1..colname.length).each do |i|
      j=colname.length-i
      ordval=colname[j].ord
      if ordval<65 || ordval>90; return -1 end
      colnumber += (ordval-65)*26**(i-1)
    end
    colnumber
  end
  
  def init_index
    @selected_item=0;
    @hospital_ids = Hospital.where("user_id = ?", current_user.id).pluck(:company_id)
    @vendor_ids = Vendor.where("user_id = ?", current_user.id).pluck(:company_id)
    @question = Question.where("user_id = ? AND mark = 1", current_user.id).first
  end
  
  def notices 
    @sentence_count = Sentence.where("user_id=?",current_user.id).count
  end
  
  def check_box_bug(param_checkbox)
    count_array=0
    result={}
    (0..param_checkbox.count-1).each do |i|
      if param_checkbox[i]=='1'
        count_array -= 1
        result[count_array]=1
        count_array += 1
      else
        result[count_array]=0
        count_array += 1
      end
    end
    return result
  end

end
