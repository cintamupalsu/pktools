class BriefsController < ApplicationController
  def index
    @selected_item=5

  end
  
  def kenteidate
    @selected_item=4

    if params[:changedate][:selected_date]==""
      @selected_date=Time.zone.now.to_date
    else
      @selected_date = Date.strptime(params[:changedate][:selected_date], '%m/%d/%Y')
    end

    if @selected_date <= (Time.zone.now).to_date
      @kenteidummy=true
      
      @answered=Kenteikaitou.where("user_id=? AND DATE(datetest)='#{@selected_date.to_date}'",current_user.id).first
      if @answered!=nil
        @decided=false
      else
        dailyexcercise = Dailyexcercise.where("DATE(daily)='#{@selected_date.to_date}'").first
        if dailyexcercise==nil
          #mondai selected randomly
          dailyexcercise= randomkentei(@selected_date)
        end
        @decided=true
        @kentei=Kmondai.find(dailyexcercise.kmondai_id)
        @kchoice=@kentei.kchoices[0]
      end
    else
      @kenteidummy=false
    end
    render 'kentei'
  end
  
  def kentei
    @selected_item=4
    @selected_date=Time.zone.now.to_date
    @kenteidummy=true
    if Kmondai.count>0
      dailyexcercise = Dailyexcercise.where("DATE(daily)='#{@selected_date.to_date}'").first
      @answered=Kenteikaitou.where("user_id=? AND DATE(datetest)='#{@selected_date.to_date}'",current_user.id).first
      if @answered!=nil
        @decided=false
      else
        if dailyexcercise==nil
          #mondai selected randomly
          dailyexcercise= randomkentei(@selected_date)
          @decided=true
          @kentei=Kmondai.find(dailyexcercise.kmondai_id)
          @kchoice=@kentei.kchoices[0]
        else
          @kentei=Kmondai.find(dailyexcercise.kmondai_id)
          @kchoice=@kentei.kchoices[0]
        end
        @decided=true
      end
    end
  end
  
  def kenteidecided
    selected_date = Date.parse(decideexercise_params['decideddate'])
    Dailyexcercise.create!(kmondai_id: decideexercise_params['kenteino'].to_i,
                           user_id: current_user.id, daily: selected_date+9.hours)
    redirect_to kentei_path
  end
  
  def kenteianswer
    @decided=false
    @selected_item=4
    kmondai= Kmondai.find(answerquestion_params['kmondai_id'])
    if params[:answerquestion][:c_date]==""
      @selected_date=Time.zone.now.to_date
    else
      @selected_date = Date.parse(params[:answerquestion][:c_date])
    end

    cbchoice=[]
    if answerquestion_params['cbchoice']!=nil
      cbchoice=check_box_bug(answerquestion_params['cbchoice'])
      answerstring =""
      answercount =0
      cbchoice.each do |k,v|
        answercount+=1
        if v==1
          answerstring+=answercount.to_s+","
        end
      end
      answerstring=answerstring[0..answerstring.length-2]
      if answerstring!=""
        saveanswer(@selected_date,answerstring,kmondai)
      else
        @angry=true
      end
    else
      if answerquestion_params['choices']=="choice1"; answerstring='1' end
      if answerquestion_params['choices']=="choice2"; answerstring='2' end
      if answerquestion_params['choices']=="choice3"; answerstring='3' end
      if answerquestion_params['choices']=="choice4"; answerstring='4' end
      if answerquestion_params['choices']=="choice5"; answerstring='5' end
      if answerquestion_params['choices']=="choice6"; answerstring='6' end
      if answerquestion_params['choices']=="choice7"; answerstring='7' end
      if answerstring!=nil
        saveanswer(@selected_date,answerstring,kmondai)
      else
        @angry=true
      end
    end
    @answered=Kenteikaitou.where("user_id=? AND DATE(datetest)='#{@selected_date.to_date}'",current_user.id).first
    if @answered!=nil
      @decided=false
    else
      dailyexcercise = Dailyexcercise.where("DATE(daily)='#{@selected_date.to_date}'").first
      if dailyexcercise==nil
        #mondai selected randomly
        dailyexcercise= randomkentei(@selected_date)
      end
      @decided=true
      @kentei=Kmondai.find(dailyexcercise.kmondai_id)
      @kchoice=@kentei.kchoices[0]
    end
    @kenteidummy=true
    render 'kentei'
  end
  
  def kentei_excel
    file_xls=excelupload_params['filename']
    workbook=RubyXL::Parser.parse_buffer(file_xls.read)
    worksheet=workbook[0]
    (2..worksheet.count-1).each do |row|
      raw_question = worksheet[row][1]
      if raw_question!=nil
        raw_question = worksheet[row][1].value
        level=getlevel(worksheet[row][4].value)
        ans=getans(worksheet[row][2].value)
        
        if Kmondai.where("oriquestion=?",raw_question).first==nil
          
          kmondai = Kmondai.where("number=?",worksheet[row][0].value.to_i).first
          question, answers=q_and_a(raw_question)
          if kmondai==nil
            kmondai=Kmondai.create(question: question, 
                                   oriquestion: raw_question,
                                   explanation: worksheet[row][3].value, 
                                   number: worksheet[row][0].value.to_i, 
                                   system: worksheet[row][5].value,
                                   order: worksheet[row][6].value,
                                   suborder: worksheet[row][7].value,
                                   answer: ans,
                                   level: level,
                                   demasu: false)
          else
            kmondai.update_attributes(question: question, 
                                   oriquestion: raw_question,
                                   explanation: worksheet[row][3].value, 
                                   number: worksheet[row][0].value.to_i, 
                                   system: worksheet[row][5].value,
                                   order: worksheet[row][6].value,
                                   suborder: worksheet[row][7].value,
                                   answer: ans,
                                   level: level)
          end
          answers.each do |k,v|
            kchoice= Kchoice.where("kmondai_id=? AND number=?", kmondai.id, k ).first
            if kchoice==nil
              Kchoice.delay.create(number: k, sentence: v, kmondai_id: kmondai.id)
            else
              kchoice.update_attributes(sentence: v, kmondai_id: kmondai.id)
            end
          end
        end
      end
    end
    redirect_to kentei_path
  end
  
  def exam 
    @selected_item=7
    @naiyo=0
    @fukusus= Fukusu.all
    render "exam"
  end
  
  def newtest
    @selected_item=7
    @naiyo=1
    @error_messages=""
    render "exam"
  end
  
  def createtest
    @selected_item=7
    @naiyo=3
    @error_messages=""
    if fukusu_params['testname']=="" || fukusu_params['testname']==nil
      @naiyo=1
      @error_messages="テスト名前を書いてください。"
    elsif fukusu_params['numofexams'].to_i<=0
      @naiyo=1
      @error_messages="問題数を決めてください。"
    else
      @fukusu=Fukusu.create(user_id: current_user.id, fname: fukusu_params['testname'], numofexam: fukusu_params['numofexams'].to_i)
      @kenteis=Kmondai.all.order("number")
    end
    render "exam"
  end
  
  def choosemondai
    @selected_item=7
    @naiyo=4
    @chosen=check_box_bug(choosemondai_params['chosen'])
    @fukusu=Fukusu.find(choosemondai_params['fukusu_id'].to_i)
    @fukusu.fmondais.destroy_all
    # counting checked
    countcheck=0
    @chosen.each do |k,v|
      if v==1
        countcheck+=1
        kmondai=Kmondai.where("number=?", k+1).first 
        Fmondai.create(fukusu_id: @fukusu.id, kmondai_id: kmondai.id, kettei: false)
      end
    end
    @different = countcheck-@fukusu.numofexam
    if @different!=0
      @kenteis=Kmondai.all.order("number")
      @naiyo=3
    else
      @fukusu.fmondais.each do |fmondai|
        fmondai.update_attributes(kettei: true)
      end
      @users=User.all.order("email")
    end
      
    render "exam"
  end
  
  def chooseuser
    @selected_item=7
    fukusu = Fukusu.find(chooseuser_params['fukusu_id'].to_i)
    users=User.all.order("email")
    chosen=check_box_bug(chooseuser_params['chosen'])
    chosen.each do |k,v|
      if v==1
        Fuser.create(fukusu_id: fukusu.id, user_id: users[k].id)
      end
    end
    redirect_to kenteiexam_path
  end
  
  def managetest
    @selected_item=7
    @naiyo=2
    @fukusus= Fukusu.all.order("created_at DESC")
    render "exam"
  end
  
  def kenteitest
    @selected_item=7
   
    if params[:id]!=nil
      @fukusu=Fukusu.find(params[:id].to_i)
      @mondai_no=params[:mondai_no].to_i-1
      if @mondai_no<0 ; @mondai_no=0 end
    else
      @fukusu=Fukusu.find(kenteitest_params['fukusu_id'].to_i)
      @mondai_no=kenteitest_params['mondai_no'].to_i+1
      if @mondai_no>@fukusu.numofexam-1; @mondai_no=0 end
    end
    
    @fmondais= Fmondai.where("fukusu_id=?",@fukusu.id).order("id")
   
    if params[:kenteitest]!=nil   
      cbchoice=[]
      fmondai=@fmondais[kenteitest_params['mondai_no'].to_i]
      if kenteitest_params['cbchoice']!=nil
        cbchoice=check_box_bug(kenteitest_params['cbchoice'])
        answerstring =""
        answercount =0
        cbchoice.each do |k,v|
          answercount+=1
          if v==1
            answerstring+=answercount.to_s+","
          end
        end
        answerstring=answerstring[0..answerstring.length-2]
        if answerstring!=""
          savetestanswer(answerstring,fmondai,@fukusu, false)
        end
      else
        if kenteitest_params['choices']=="choice1"; answerstring='1' end
        if kenteitest_params['choices']=="choice2"; answerstring='2' end
        if kenteitest_params['choices']=="choice3"; answerstring='3' end
        if kenteitest_params['choices']=="choice4"; answerstring='4' end
        if kenteitest_params['choices']=="choice5"; answerstring='5' end
        if kenteitest_params['choices']=="choice6"; answerstring='6' end
        if kenteitest_params['choices']=="choice7"; answerstring='7' end
        if answerstring!=nil
          savetestanswer(answerstring,fmondai,@fukusu, false)
        end
      end
    end
  end
  
  def kenteiend 
    @selected_item=7
    @fukusu=Fukusu.find(params[:id])
    countcorrect=0
    countstar=0
    @fukusu.fmondais.each do |mondai|
      fkaito=Fkaito.where("user_id=? AND fukusu_id=? AND fmondai_id=?", current_user.id, @fukusu.id, mondai.id).first
      fkaito.update_attributes(kettei: true)
      if fkaito.correct
        countcorrect+=1
        countstar+=Kmondai.find(fkaito.kmondai_id).level
      end 
    end
    @fuser=Fuser.where("user_id=? AND fukusu_id=?", current_user.id, @fukusu.id).first
    resultfloat=countcorrect.to_f/@fukusu.numofexam.to_f
    @fuser.update_attributes(testdone: true, result: countstar, resultfloat: resultfloat)
    
  end
  
  def edit_test
    @selected_item=7
    @naiyo=5
    render "exam"
  end
  
  def test_delete
    Fukusu.find(params[:id]).destroy
    flash[:success] = "テストを削除しました"
    redirect_to managetest_url
  end

  private
  
  def excelupload_params
    params.require(:excelupload).permit(:filename)
  end
  
  def decideexercise_params
    params.require(:decideexercise).permit(:kenteino, :decideddate)
  end
  
  def changedate_params
    params.require(:changedate).permit(:selected_date)
  end
  
  def answerquestion_params
    params.require(:answerquestion).permit(:c_date, :kmondai_id, :choices, :cbchoice=>[])
  end
  
  def fukusu_params
    params.require(:fukusu).permit(:testname, :numofexams)
  end
  
  def choosemondai_params
    params.require(:choosemondai).permit(:fukusu_id, :chosen=>[])
  end
  
  def chooseuser_params
    params.require(:chooseuser).permit(:fukusu_id, :chosen=>[])
  end
  
  def kenteitest_params
    params.require(:kenteitest).permit(:fukusu_id, :mondai_no, :choices, :cbchoice=>[] )
  end
  
  def q_and_a(r_question)
    question=""
    answers={}
    inquestion=true
    split_question=r_question.split("\n")
    (0..split_question.count-1).each do |line|
      if split_question[line][0]!=nil
        if split_question[line][0]=="①"
          answers[1]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="②"
          answers[2]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="③"
          answers[3]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="④"
          answers[4]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="⑤"
          answers[5]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="⑥"
          answers[6]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        elsif split_question[line][0]=="⑦"
          answers[7]=split_question[line][1..split_question[line].length-1]
          inquestion=false
        end
      end
    
      if inquestion==true
        question+=split_question[line]
      end
    end
    return question, answers
  end
  
  def getans(ans)
    correct_ans=""
    (0..ans.length-1).each do |i|
      if ans[i]=="①"
        correct_ans+="1,"
      elsif ans[i]=="②"
        correct_ans+="2,"
      elsif ans[i]=="③"
        correct_ans+="3,"
      elsif ans[i]=="④"
        correct_ans+="4,"
      elsif ans[i]=="⑤"
        correct_ans+="5,"
      elsif ans[i]=="⑥"
        correct_ans+="6,"
      elsif ans[i]=="⑦"
        correct_ans+="7,"
      end
    end
    correct_ans=correct_ans[0..correct_ans.length-2]
  end
  
  def getlevel(level) #levelabamba
    intlevel=0
    (0..level.length-1).each do |i|
      if level[i]=="★"
        intlevel+=1
      end
    end
    return intlevel
  end
  
  def randomkentei(selected_date)
    # random
    randomnumber=Random.rand(1..Kmondai.count)
    #selected_date = Date.parse(decideexercise_params['decideddate'])
    #selected_date = Time.zone.now.to_date
    
    # check new excercise
    kentei = Kmondai.where(demasu: false).first
    if kentei==nil
      kentei = Kmondai.where("number=?", randomnumber).first
      kentei.update_attributes(demasu: true)
    end
    kentei.update_attributes(demasu: true)
    Dailyexcercise.create!(kmondai_id: kentei.id,
                           user_id: current_user.id, 
                           daily: selected_date+9.hours)
    kmondai = Dailyexcercise.last
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
  
  def saveanswer(c_date, answer, kmondai)
    if kmondai.answer==answer 
      Kenteikaitou.create(user_id: current_user.id, kmondai_id: kmondai.id, correct: true, datetest: c_date.to_date+9.hours, answer: answer)
    else
      Kenteikaitou.create(user_id: current_user.id, kmondai_id: kmondai.id, correct: false, datetest: c_date.to_date+9.hours, answer: answer)
    end
  end
  
  def savetestanswer(answerstring, fmondai, fukusu, kettei)
    correct=false
    kmondai = Kmondai.find(fmondai.kmondai_id)
    if answerstring==kmondai.answer
      correct=true
    end
    fkaito=Fkaito.where("fukusu_id=? AND fmondai_id=? AND user_id=?", fukusu.id, fmondai.id, current_user.id).first
    if fkaito==nil
      Fkaito.create(user_id: current_user.id, fukusu_id: fukusu.id, kmondai_id: kmondai.id, fmondai_id: fmondai.id, answerstring: answerstring, kettei: kettei, correct: correct)
    else
      fkaito.update_attributes(answerstring: answerstring, kettei: kettei, correct: correct)
    end
  end
end
