# -----------------------------------------------------------
# 01.01 2019/01/10 by Arief Maulana as Ota-san requested
# 01.02 2019/01/17 by Arief Maulana as Ota-san requested
# -----------------------------------------------------------
# 01.01 2019/01/10 Yokyu sentence input is valid for all user
# 01.02 2019/01/17 Answers show on sentence list and confirm list
# -----------------------------------------------------------
class YokyuController < ApplicationController
  def index
    @benkyo=params['benkyo'].to_i
    init_index
  end

  def write
    natural_language_understanding = ibmwatson(0)
    
    init_index
    noprocess=false
    ws_from = writing_params['worksheetfrom'].to_i
    ws_to = writing_params['worksheetto'].to_i
    if ws_from==0
      noprocess=true
    end
    if ws_to<ws_from
      ws_to=ws_from
    end
    if writing_params['filename']!=nil && noprocess == false
      file_xls= writing_params['filename']
      ws_to=ws_to
      ws_from=ws_from
      first_row = writing_params['first_row'].to_i-1
      hospital_id = Hospital.where("company_id=?",writing_params['hospital'].to_i).first.id 
      vendor_id = Vendor.where("company_id=?",writing_params['vendor'].to_i).first.id 

      file_manager = FileManager.create!(name: file_xls.original_filename, 
                                        content_type: file_xls.content_type.chomp, 
                                        data: file_xls.read,
                                        user_id: current_user.id,
                                        status: 0,
                                        hospital_id: hospital_id,
                                        vendor_id: vendor_id,
                                        question_id: @question.id)

      question_col = file_manager.string_to_col(writing_params['question'])
      answers_col = Array.new(@question.answers.count)

      (0..answers_col.count-1).each do |ans|
        answers_col[ans] = file_manager.string_to_col(writing_params['answer'][ans])
      end
      if noprocess==false
        file_manager.delay.writing(ws_from, ws_to, hospital_id, vendor_id, first_row, @question, question_col, answers_col, current_user, natural_language_understanding)
      end
      flash[:info] = "ファイルを登録しています"
    else
      flash[:warning] = "入力エラー"
    end
    #redirect_to yokyu_path(:benkyo => 0)
    redirect_to yokyu_download_path
  end
  
  def rewrite
    natural_language_understanding = ibmwatson(0)

    init_index
    file_manager = FileManager.find(params[:id])
    #ws_from = file_manager.ws_from-1
    #ws_to = file_manager.ws_to-1
    #hospital_id = file_manager.hospital_id
    #vendor_id = file_manager.vendor_id
    #first_row = file_manager.first_row
    @question= Question.find(file_manager.question_id)
    #question_col =file_manager.question_col
    ans_col=file_manager.answer_col.split(',')
    answers_col = Array.new(@question.answers.count)
    (0..ans_col.count-1).each do |i|
      answers_col[i]=ans_col[i].to_i
    end
    file_manager.update_attributes(status: 0)
    file_manager.delay.writing(file_manager.ws_from, file_manager.ws_to, file_manager.hospital_id, file_manager.vendor_id, file_manager.first_row, @question, file_manager.question_col, answers_col, current_user, natural_language_understanding)
    #writing(ws_from, ws_to, hospital_id, vendor_id, first_row, @question, question_col, answers_col, current_user, natural_language_understanding, file_manager)
    
    
      
    redirect_to yokyu_download_path
  end

  def learn
    init_index
    if learning_params['filename']!=nil
      # check variables
      ws_from = learning_params['worksheetfrom'].to_i
      ws_to = learning_params['worksheetto'].to_i

      noprocess=false
      if ws_from==0 
        noprocess=true
      end
      if ws_to<ws_from
        ws_to=ws_from
      end
      ws_to=ws_to-1
      ws_from=ws_from-1
      
      hospital_id = Hospital.first.id 
      vendor_id = Vendor.first.id 
      benkyo=learning_params['benkyo'].to_i
      if benkyo==0
        hospital_id = Hospital.where("company_id=?",learning_params['hospital'].to_i).first.id 
        vendor_id = Vendor.where("company_id=?",learning_params['vendor'].to_i).first.id 
      end
      if noprocess==false
        natural_language_understanding = ibmwatson(0)

        # check variables
        # ws_from = learning_params["worksheetfrom"].to_i-1
        # ws_to = learning_params['worksheetto'].to_i-1
        first_row = learning_params['first_row'].to_i-1
        file_xls = learning_params['filename']


        file_manager = FileManager.create!(name: file_xls.original_filename, 
                                  data: file_xls.read,
                                  user_id: current_user.id,
                                  status: 0,
                                  hospital_id: hospital_id,
                                  vendor_id: vendor_id,
                                  question_id: @question.id)

        question_col = file_manager.string_to_col(learning_params['question'])
        answer_cols = ""
        (0..learning_params['answer'].count-1).each do |ans|
          answer_cols+= file_manager.string_to_col(learning_params['answer'][ans]).to_s
          if ans!=learning_params['answer'].count-1
            answer_cols+=","
          end
        end
        file_manager.update_attributes(question_col: question_col, answer_col: answer_cols)
        
        answers_count = @question.answers.count

        # read file
        workbook = RubyXL::Parser.parse(file_xls.path)
        (ws_from..ws_to).each do |ws|
          worksheet = workbook[ws] 
          question=Array.new(worksheet.count)
          answer=Array.new(answers_count)
          answer_id=Array.new(answers_count)
          (0..answers_count-1).each do |ans|
            answer[ans]=Array.new(worksheet.count)
            if benkyo==0
              answer_id[ans]=learning_params['answer_id'][ans].to_i
            end
          end
          
          (first_row..worksheet.count-1).each do |row|
            if worksheet[row][question_col]!=nil
            if worksheet[row][question_col]!=""
              question[row]=worksheet[row][question_col].value.to_s
              (0..answers_count-1).each do |ans|
                if benkyo==0
                  answer_col = file_manager.string_to_col(learning_params['answer'][ans])
                  if worksheet[row][answer_col]!= nil
                    answer[ans][row] = worksheet[row][answer_col].value.to_s
                  end
                end
              end
            end
            end
          end
          #learning(natural_language_understanding, file_manager, question, answer, current_user, answer_id, hospital_id, vendor_id, learning_params['benkyo'].to_i)
          file_manager.delay.learning(natural_language_understanding, question, answer, current_user, answer_id, hospital_id, vendor_id, learning_params['benkyo'].to_i)
        end
        flash[:info] = "取り込んでいます"
        
      else
        flash[:warning] = "入力エラー"
      end
    else
      flash[:success] = "ファイルなし"
    end
    redirect_to yokyufile_path
    #render 'index'
  end
  

  def answer
  end
  
  def questions
    @selected_item=4;
    # 01.01 2019/01/10 >>>
    #@questions= Question.where("user_id=?", current_user.id)
    @questions= Question.all
    @setting = Setting.where("user_id=? AND shorui=1", current_user.id).first
    if @setting==nil && Question.count>0
      question= Question.first
      @setting = Setting.create(user_id: current_user.id, shorui: 1, target: question.id)
    end
    # 01.01 2019/01/10 <<<
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
    # 01.01 2019/01/10 >>>
    #if Question.where("user_id=?", current_user.id).count==0
    #  @question.mark=1
    #else
    #  @question.mark=0
    #end
    # 01.01 2019/01/10 <<<

    if @question.save
      # 01.01 2019/01/10 >>>
      if Setting.where("shorui = 1 AND user_id=?", current_user.id).count == 0
        Setting.create!(shorui: 1, user_id:1, target: @question.id)
      end
      # 01.01 2019/01/10 <<<
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
    # 01.01 2019/01/10 >>>
    # question = Question.where("user_id=? AND mark=?", current_user.id, 1).first
    # question.update_attributes(mark: 0)
    # question = Question.find(params[:id])
    # question.update_attributes(mark: 1)
    setting = Setting.where("shorui = 1 AND user_id = ?",current_user.id).first
    setting.update_attributes(target: params[:id].to_i)
    # 01.01 2019/01/10 <<<
    redirect_to questions_url
  end  
  
  def question_destroy
    
    question = Question.find(params[:id])
    # 01.01 2019/01/10 >>>
    if question.mark==1
      questions = Question.where("user_id=?",current_user)
      if questions.count>0
        questions[0].update_attributes(mark: 1)
      end
    end
    # 01.01 2019/01/10 <<<
    question.destroy
    if Question.count>0
      question = Question.first
      setting = Setting.where("user_id=? AND shorui=1", current_user.id).first
      setting.update_attributes(target: question.id)
    else
      setting = Setting.where("user_id=? AND shorui=1", current_user.id).first
      setting.destroy
    end
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
    # 01.01 2019/01/10 >>>
    #@sentences = Sentence.where("user_id=?",current_user.id)
    @sentences = Sentence.all.paginate(:page => params[:sentence_page], :per_page => 10)
    # 01.01 2019/01/10 <<<
    @check = params[:check].to_i
    # 01.02 2019/01/17 >>>
    @counter = params[:sentence_page].to_i
    if @counter==0
      @counter=1
    end
    setting =Setting.where("shorui=1 AND user_id=?", current_user.id).first
    if setting!= nil
      @question = Question.find_by(id: setting.target)
    end
    # 01.02 2019/01/17 <<<
  end
  
  def confirmed
    onaji = check_box_bug(kakunin_params['onaji'])
    (0..kakunin_params['sentence_id'].count-1).each do |i|
      sentence = Sentence.find_by(id: kakunin_params['sentence_id'][i])
      if onaji[i]==1 #if similar
        wlm = WatsonLanguageMaster.find_by(id: sentence.watson_language_master_id)
        # check anchoring
        wlm_anchor = WatsonLanguageMaster.find_by(id: sentence.wlu)
        while wlm_anchor.anchor!=-1 do
          wlm_anchor = WatsonLanguageMaster.find_by(id: wlm_anchor.anchor)
        end
        wlm.update_attributes(anchor: wlm_anchor.id)
        answers = AnswerDenpyo.where("watson_language_master_id=?", sentence.watson_language_master_id)
        answers.each do |answer|
          answer.update_attributes(watson_language_master_id: wlm_anchor.id)
        end
      end
      sentence.destroy
    end
    redirect_to senconfirm_path
  end
  
  def onaji
    # 01.02 2019/01/17 >>>
    sentence = Sentence.find(params[:id])
    wlm = WatsonLanguageMaster.find_by(id: sentence.watson_language_master_id)
    # check anchoring
    wlm_anchor = WatsonLanguageMaster.find_by(id: sentence.wlu)
    while wlm_anchor.anchor!=-1 do
      wlm_anchor = WatsonLanguageMaster.find_by(id: wlm_anchor.anchor)
    end
    wlm.update_attributes(anchor: wlm_anchor.id)
    answers = AnswerDenpyo.where("watson_language_master_id=?", sentence.watson_language_master_id)
    answers.each do |answer|
      answer.update_attributes(watson_language_master_id: wlm_anchor.id)
    end
    sentence.destroy
    redirect_to senconfirm_path
    # 01.02 2019/01/17 <<<
  end
  
  def chigau
    # 01.02 2019/01/17 >>>
    sentence = Sentence.find(params[:id])
    sentence.destroy
    redirect_to senconfirm_path
    # 01.02 2019/01/17 <<<
  end

  def filelist
    @selected_item=1
    # 01.01 2019/01/10 >>>
    #@files = FileManager.where("user_id=? AND content_type IS NULL",current_user.id)
    @files = FileManager.where("content_type IS NULL AND status<2")
    #wlm_ids = Sentence.where("user_id = ?",current_user.id).pluck(:wlu)
    wlm_ids = Sentence.all.pluck(:wlu)
    @file_manager_ids = WatsonLanguageMaster.where("id IN (?)", wlm_ids).pluck(:file_manager_id)
    #@inprogress = FileManager.where("user_id =? AND status=0 AND content_type IS NULL",current_user.id).count
    @inprogress = FileManager.where("status=0 AND content_type IS NULL").count
    # 01.01 2019/01/10 <<<
  end

  def file_destroy
    file = FileManager.find(params[:id])
    file.update_attributes(status: 2)
    #file.destroy
    file.delay.deleting()
    
    flash[:success] = "ファイルを削除しました"
    redirect_back fallback_location: root_path
    #if params[:download].to_i == 0
    #  redirect_to yokyufile_path
    #else
    #  redirect_to yokyu_download_path
    #end
  end
  
  def senmanage
    @selected_item=2
    # 01.01 2019/01/01 >>>
    #@watson_language_master = WatsonLanguageMaster.where("user_id=? AND anchor = -1", current_user.id)
    @counter = params[:sentence_page].to_i
    @in_sentence_array=[]
    wlms = WatsonLanguageMaster.where("anchor = -1")
    wlms.each do |wlm|
      if Sentence.find_by(watson_language_master_id: wlm.id) == nil && AnswerDenpyo.where("watson_language_master_id = ?",wlm.id).first == nil
        @in_sentence_array.push(wlm.id)
      end
    end
    
    if @counter==0
      @counter=1
    end
    if params[:keywords]!=nil
      keywords= "%"+params[:keywords]+"%"
      @keywords=params[:keywords]
      @watson_language_master = WatsonLanguageMaster.where("anchor = -1 AND content LIKE ?",keywords).paginate(:page => params[:sentence_page], :per_page => 10)
      @search_mode= 1
    elsif params[:noanswer]!=nil
      @watson_language_master = WatsonLanguageMaster.where("anchor = -1 AND id IN (?)", @in_sentence_array).paginate(:page => params[:sentence_page], :per_page => 10)
      @search_mode= 2
    else
      @watson_language_master = WatsonLanguageMaster.where("anchor = -1").paginate(:page => params[:sentence_page], :per_page => 10)
      @search_mode= 0
    end
    # 01.01 2019/01/01 <<<
    # 01.02 2019/01/17 >>>
    setting =Setting.where("shorui=1 AND user_id=?", current_user.id).first
    if setting!=nil 
      @question = Question.find_by(id: setting.target)
    end
    # 01.02 2019/01/17 <<<
  end
  

  def sentence_search
    @search_mode= true
    @selected_item=2
    # 01.01 2019/01/01 >>>
    #@watson_language_master = WatsonLanguageMaster.where("user_id=? AND anchor = -1", current_user.id)
 
    @in_sentence_array=[]
    wlms = WatsonLanguageMaster.where("anchor = -1")
    wlms.each do |wlm|
      if Sentence.find_by(watson_language_master_id: wlm.id) == nil && AnswerDenpyo.where("watson_language_master_id = ?",wlm.id).first == nil
        @in_sentence_array.push(wlm.id)
      end
    end
 
    @counter = params[:sentence_page].to_i
    if @counter==0
      @counter=1
    end
    keywords= "%"+params[:words][:sentence]+"%"
    @keywords=params[:words][:sentence]
    if params[:words][:sentence] == ''
      @watson_language_master = WatsonLanguageMaster.where("anchor = -1").paginate(:page => params[:sentence_page], :per_page => 10)
      @search_mode= false
    else
      @watson_language_master = WatsonLanguageMaster.where("anchor = -1 AND content LIKE ?",keywords).paginate(:page => params[:sentence_page], :per_page => 10)
      @search_mode= 1
    end
    # 01.01 2019/01/01 <<<
    # 01.02 2019/01/17 >>>
    setting =Setting.where("shorui=1 AND user_id=?", current_user.id).first
    if setting!=nil 
      @question = Question.find_by(id: setting.target)
    end
    render 'senmanage'
  end
  
  def sentence
    @selected_item=2
    anchor_id = params[:id].to_i
    @sentence = WatsonLanguageMaster.find(params[:id])
    if @sentence.anchor!=-1
      anchor_id = @sentence.anchor
    end
    @sentences = WatsonLanguageMaster.where("anchor = ? OR id = ?",anchor_id, anchor_id)
    setting =Setting.where("shorui=1 AND user_id=?", current_user.id).first
    @question = Question.find_by(id: setting.target)
    answers_count = @question.answers.count
    @answers = {}
    @answerdenpyoids = {}
    iteration_count=0
    @question.answers.each do |answer|
      answerdenpyos= AnswerDenpyo.where("watson_language_master_id=? AND answer_id=?",anchor_id, answer.id)
      answerdenpyos.each do |ad|
        hashstring="#{ad.hospital_id}-#{ad.vendor_id}"
        if @answers[hashstring]==nil
          @answers[hashstring]=Array.new(answers_count)
          @answerdenpyoids[hashstring] = ad.id
        end
        if @answers[hashstring][iteration_count]==nil
          @answers[hashstring][iteration_count]=ad.content
        end
      end
      iteration_count+=1
    end
  end
  

  def watson_update
  end
  
  def betsu
    wlm = WatsonLanguageMaster.find(params[:id])
    wlm.update_attributes(anchor: -1)
    flash[:primary] = "文章を分けました"
    redirect_to manage_sentences_path
  end
  
  def attach
    @watson_language_master = WatsonLanguageMaster.find(params[:id])
    if params[:keywords]!=nil
      keywords= "%"+params[:keywords]+"%"
      @keywords=params[:keywords]
      @watson_language_masters = WatsonLanguageMaster.where("anchor = -1 AND content LIKE ?",keywords).paginate(:page => params[:sentence_page], :per_page => 10)
    else
      @watson_language_masters = WatsonLanguageMaster.where("anchor = -1").paginate(:page => params[:sentence_page], :per_page => 10)
    end
    @selected_item=2
  end

  def sentence_filter
    @watson_language_master = WatsonLanguageMaster.find(params[:words][:watson_id].to_i)
    keywords= "%"+params[:words][:sentence]+"%"
    @keywords=params[:words][:sentence]
    if params[:words][:sentence] != ''
      @watson_language_masters = WatsonLanguageMaster.where("anchor = -1 AND content LIKE ?",keywords).paginate(:page => params[:sentence_page], :per_page => 10)
    else
      @watson_language_masters = WatsonLanguageMaster.where("anchor = -1").paginate(:page => params[:sentence_page], :per_page => 10)
      @keywords=nil
    end
    @selected_item=2
    render 'attach'
  end
  
  def attached
    source = WatsonLanguageMaster.find(params[:sid])
    target_id = params[:id].to_i
    source.update_attributes(anchor: target_id)
    
    attached_sentences = WatsonLanguageMaster.where("anchor = ?",source.id)
    attached_sentences.each do |attached_sentence|
      attached_sentence.update_attributes(anchor: target_id)
    end
    
    answer_denpyos = AnswerDenpyo.where("watson_language_master_id = ?", source)
    answer_denpyos.each do |answer_denpyo|
      answer_denpyo.update_attributes(watson_language_master_id: target_id)
    end
    
    flash[:primary] = "文章を参照しました"
    redirect_to manage_sentences_path
  end
  
  def delete_sentence
    wlm = WatsonLanguageMaster.find(params[:id])
    wlm.destroy
    flash[:warning] = "分を削除しました"
    redirect_to manage_sentences_path
  end
  
  def download
    @selected_item=7
    #@files = FileManager.where("user_id=? AND content_type IS NOT NULL",current_user.id)
    @files = FileManager.where("content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' AND status < 2")
  end
  
  def download_file
    #@selected_item=7
    #@files = FileManager.where("user_id=? AND content_type IS NOT NULL",current_user.id)
    file = FileManager.find(params[:id])
    send_data( file.data, :disposition => 'attachment', :type => 'application/excel', :filename => file.name)
    # redirect_to yokyu_download_path
    
  end
  
  def documentation
    @selected_item=9
  end
  private
  
  def learning_params
    params.require(:learning).permit(:filename, :question, :worksheetfrom, :worksheetto, :vendor, :hospital, :first_row, :benkyo, :answer=>[], :answer_id=>[])    
  end
  
  def writing_params
    params.require(:writing).permit(:filename, :question, :worksheetfrom, :worksheetto, :vendor, :hospital, :first_row, :answer=>[], :answer_id=>[])    
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
    if @benkyo==1
      @selected_item=8
    end
    # 01.01 2019/01/10 >>>
    #@hospital_ids = Hospital.where("user_id = ?", current_user.id).pluck(:company_id)
    #@vendor_ids = Vendor.where("user_id = ?", current_user.id).pluck(:company_id)
    @hospital_ids = Hospital.all.pluck(:company_id)
    @vendor_ids = Vendor.all.pluck(:company_id)
    if Question.count>0
      setting = Setting.where("shorui=1 AND user_id=?", current_user.id).first
      if setting==nil 
        question= Question.first
        setting = Setting.create(user_id: current_user.id, shorui: 1, target: question.id)
      end
      @question = Question.find(setting.target)
    end
    # @question = Question.where("user_id = ? AND mark = 1", current_user.id).first
    # 01.01 2019/01/10 <<<
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
  
  def ibmwatson(indexing)
    if indexing==0
      # IBMWatson::NaturalLanguageUnderstandingV1.new(version: "2018-03-16",iam_apikey: "oZL8aWn9Z0I8U0vOXBPRfev9YbGUrGoFkmnvGK6TGUox", url: "https://gateway.watsonplatform.net/natural-language-understanding/api")
      IBMWatson::NaturalLanguageUnderstandingV1.new(version: "2018-03-16",iam_apikey: ENV['WATSON_NLU'], url: "https://gateway.watsonplatform.net/natural-language-understanding/api")
    end
  end
  


end
