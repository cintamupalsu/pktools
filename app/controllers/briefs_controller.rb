class BriefsController < ApplicationController
  def index
    @selected_item=5

  end
  
  def kenteidate
  end
  
  def kentei
    @selected_item=4
    @selected_date=Time.zone.now.to_date
    dailyexcercise = Dailyexcercise.where("DATE(daily)='#{@selected_date.to_date}'").first
    if dailyexcercise==nil
      @decided=false
      @kenteis=Kmondai.all
    else
      @decided=true
      @kentei=Kmondai.find(dailyexcercise.kmondai_id)
      @kchoice=@kentei.kchoices[0]
    end
  end
  
  def kenteidecided
    selected_date = Date.parse(decideexercise_params['decideddate'])
    Dailyexcercise.create!(kmondai_id: decideexercise_params['kenteino'].to_i,
                           user_id: current_user.id, daily: selected_date+9.hours)
    redirect_to kentei_path
  end
  
  def kenteianswer
    redirect_to briefs_path
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
 
end
