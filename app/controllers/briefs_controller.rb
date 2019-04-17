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
    render 'kentei'
  end
  
  def kentei
    @selected_item=4
    @selected_date=Time.zone.now.to_date
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
          question, answers=q_and_a(raw_question)
          kmondai=Kmondai.create(question: question, 
                                 oriquestion: raw_question,
                                 explanation: worksheet[row][3].value, 
                                 number: Kmondai.count+1, 
                                 system: worksheet[row][5].value,
                                 order: worksheet[row][6].value,
                                 suborder: worksheet[row][7].value,
                                 answer: ans,
                                 level: level)
          answers.each do |k,v|
            Kchoice.delay.create(number: k, sentence: v, kmondai_id: kmondai.id)
          end
        end
      end
    end
    redirect_to kentei_path
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
    kentei= Kmondai.where("number=?", randomnumber).first
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
end
