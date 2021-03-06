# -----------------------------------------------------------
# 01.01 2019/01/10 by Arief Maulana as Ota-san requrested
# -----------------------------------------------------------
# 01.01 2019/01/10 Yokyu sentence input is valid for all user
# -----------------------------------------------------------
class FileManager < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :hospital
  belongs_to :vendor
  has_many :answer_denpyos, dependent: :destroy
  has_many :sentences, dependent: :destroy
  has_many :watson_language_masters, dependent: :destroy
  mount_uploader :picture, PictureUploader
  validate :picture_size
  

  
  def learning(natural_language_understanding, question, answer, user, answer_id, hospital_id, vendor_id, benkyo)
    threshold = 0.1

    (0..question.count-1).each do |row|
      if question[row]!=nil
        if question[row]!=""
          variant= question[row].gsub(/。|、|\ |\.|,|　|\n/,'')
          if variant!=""
            # check answer ( if no answer, dont process)
            answer_exist=false
            (0..answer.count-1).each do |checkanswer|
              if(answer[checkanswer][row])!=""
                answer_exist=true
              end
            end
            if answer_exist 
              # ----
              # find same Watson
              # 01.01 2019/01/10 >>>
              # wlm = WatsonLanguageMaster.where("variant = ? AND user_id= ?",variant, user.id).first
              wlm = WatsonLanguageMaster.where("variant = ?",variant).first
              # 01.01 2019/01/10 <<<
              find_similar=-1
              # if not found check similarity
              if wlm == nil
                watson_response = natural_language_understanding.analyze(
                  text: variant,
                  features: {keywords: {limit: 50, sentiment: 0, emotion: 0}}
                )
                
                # Save WatsonLanguageMaster with no achor
                wlm = WatsonLanguageMaster.create(content: question[row], variant: variant, anchor: -1, user_id: user.id, file_manager_id: self.id)
                          
                filter = {} # filter is to count the similar keyword in an ID of WatsonLanguageMaster.
                chosen_word=0
                (0..watson_response.result["keywords"].length-1).each do |k|
                  if watson_response.result["keywords"][k]["relevance"].to_f>threshold
                    chosen_word+=1
                    wlks = WatsonLanguageKeyword.where("keyword = ?", watson_response.result["keywords"][k]["text"])  
                    (0..wlks.count-1).each do |j|
                      if filter[wlks[j].watson_language_master.id]==nil
                        filter[wlks[j].watson_language_master.id]=1
                      else
                        filter[wlks[j].watson_language_master.id]+=1
                      end
                    end
                  end
                end
    
                #save WatsonLanguageKeyword
                (0..watson_response.result["keywords"].length-1).each do |i|
                  if watson_response.result["keywords"][i]["relevance"].to_f>threshold
                    WatsonLanguageKeyword.create(keyword: watson_response.result["keywords"][i]["text"], 
                                               relevance: watson_response.result["keywords"][i]["relevance"].to_f,
                                               watson_language_master_id: wlm.id)
                  end
                end
          
                filter.each do |k,v|
                  if v == chosen_word
                    find_similar=k.to_i
                  end
                end
                
              end
              anchor=wlm.id
              if wlm.anchor!=-1
                anchor=wlm.anchor
              end
              (0..answer.count-1).each do |ans|
                if answer[ans][row]=="" 
                else
                  if benkyo==0
                    AnswerDenpyo.create!(user_id: user.id, 
                                        watson_language_master_id: anchor, 
                                        content: answer[ans][row],
                                        answer_id: answer_id[ans],
                                        hospital_id: hospital_id,
                                        vendor_id: vendor_id,
                                        file_manager_id: self.id
                                        )
                  end
                end
              end
              
              if find_similar!=-1
                # Need Confirmation
                sentence = Sentence.create!(content: question[row], 
                                            watson_language_master_id: wlm.id,
                                            user_id: user.id,
                                            hospital: hospital_id,
                                            vendor: vendor_id,
                                            file_manager_id: self.id,
                                            wlu: find_similar)
              end
            end
          end
        end
      end
    end
    update_attributes(status: 1,)
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
  
  def uploaded_file(xls_field)
    self.name         = base_part_of(xls_field.original_filename)
    self.content_type = xls_field.content_type.chomp
    self.data         = xls_field.read
  end
  
  def base_part_of(file_name)
    File.basename(file_name).gsub(/[^\w._-]/,'')
  end
  
  def writing(ws_from, ws_to, hospital_id, vendor_id, first_row, question, question_col, answers_col, current_user, natural_language_understanding)
    variant=""
    if ws_from<=ws_to
      workbook = RubyXL::Parser.parse_buffer(self.data)
      (ws_from-1..ws_to-1).each do |ws|
        worksheet = workbook[ws]
        (first_row..worksheet.count-1).each do |row|
          if worksheet[row]!=nil
          if worksheet[row].hidden != true
          if worksheet[row][question_col]!= nil 
          if worksheet[row][question_col].value!= ""
            variant = worksheet[row][question_col].value.to_s.gsub(/。|、|\ |\.|,|　|\n/,'')
            # 01.01 2019/01/10 >>>
            watson_language_master = WatsonLanguageMaster.where("variant=?",variant).first
            #watson_language_master = WatsonLanguageMaster.where("user_id=? AND variant=?",current_user.id, variant).first
            # 01.01 2019/01/10 <<<
            if watson_language_master!=nil 
              if watson_language_master.anchor != -1
                watson_language_master = WatsonLanguageMaster.find(watson_language_master.anchor)
              end
              (0..question.answers.count-1).each do |ans|
                # 01.01 2019/01/10 >>>
                #answer = AnswerDenpyo.where("user_id=? AND watson_language_master_id=? AND hospital_id=? AND vendor_id=? AND answer_id=?", current_user.id, watson_language_master.id, hospital_id, vendor_id, question.answers[ans].id).first
                answer = AnswerDenpyo.where("watson_language_master_id=? AND hospital_id=? AND vendor_id=? AND answer_id=?", watson_language_master.id, hospital_id, vendor_id, question.answers[ans].id).first
                # 01.01 2019/01/10 <<<
                
                if answer!=nil
                  worksheet[row][answers_col[ans]].change_contents(answer.content, worksheet[row][answers_col[ans]].formula)
                end
              end # answers_col
            else 
              if variant!=""
                find_similar = similar_register(natural_language_understanding, variant, worksheet[row][question_col].value.to_s, hospital_id, vendor_id, user_id)
              end
            end #end if watson
          end # end if
          end # end if
          end # end if
          end # end if
        end # worksheet row loop
      end # ws
      answers_col_str=""
      (0..answers_col.count-1).each do |i|
        answers_col_str+=answers_col[i].to_s
        if i!=answers_col.count-1
          answers_col_str+=","
        end
      end
      self.update_attributes(status: 1, data: workbook.stream.read, ws_from: ws_from, ws_to: ws_to, first_row: first_row, question_col: question_col, answer_col: answers_col_str)
    end
  end
  
  def similar_register(natural_language_understanding, variant, origin, hospital_id, vendor_id, user_id)
    threshold=0.1
    find_similar=-1
    watson_response = natural_language_understanding.analyze(
      text: variant,
      features: {keywords: {limit: 50, sentiment: 0, emotion: 0}}
    )
    # Save WatsonLanguageMaster with no achor
    wlm = WatsonLanguageMaster.create(content: origin, variant: variant, anchor: -1, user_id: user.id, file_manager_id: self.id)
              
    filter = {} # filter is to count the similar keyword in an ID of WatsonLanguageMaster.
    chosen_word=0
    (0..watson_response.result["keywords"].length-1).each do |k|
      if watson_response.result["keywords"][k]["relevance"].to_f>threshold
        chosen_word+=1
        wlks = WatsonLanguageKeyword.where("keyword = ?", watson_response.result["keywords"][k]["text"])  
        (0..wlks.count-1).each do |j|
          if filter[wlks[j].watson_language_master.id]==nil
            filter[wlks[j].watson_language_master.id]=1
          else
            filter[wlks[j].watson_language_master.id]+=1
          end
        end
      end
    end

    #save WatsonLanguageKeyword
    (0..watson_response.result["keywords"].length-1).each do |i|
      if watson_response.result["keywords"][i]["relevance"].to_f>threshold
        WatsonLanguageKeyword.create(keyword: watson_response.result["keywords"][i]["text"], 
                                   relevance: watson_response.result["keywords"][i]["relevance"].to_f,
                                   watson_language_master_id: wlm.id)
      end
    end

    filter.each do |k,v|
      if v == chosen_word
        find_similar=k.to_i
      end
    end
    
    #if similar not found, try to get the closest sentence
    closest=0
    if find_similar==-1 
      filter.each do |k,v|
        if v>closest
          closest=v 
          find_similar= k.to_i
        end
      end
    end

    # Need Confirmation
    if find_similar!=-1
    sentence = Sentence.create!(content: origin, 
                                watson_language_master_id: wlm.id,
                                user_id: user.id,
                                hospital: hospital_id,
                                vendor: vendor_id,
                                file_manager_id: self.id,
                                wlu: find_similar)
    end
    return find_similar
  end
  
  def deleting
    wlms = WatsonLanguageMaster.where("file_manager_id=? AND anchor = -1",self.id)
    wlms.each do |wlm|

      counter=0
      anchor_id=-1

      answer_denpyos = AnswerDenpyo.where("watson_language_master_id=? AND file_manager_id<>?", wlm.id, self.id)
      if answer_denpyos.count>0
        wlm.update_attributes(file_manager_id: answer_denpyos[0].file_manager_id)
      else
        wlmids = WatsonLanguageMaster.where("anchor = ?", wlm.id)
        wlmids.each do |wlmid|
          wlmid.update_attributes(anchor: anchor_id)
          if counter==0
            anchor_id=wlmid.id
          end
          counter +=1
        end
        
        sentences = Sentence.where("wlu=? AND file_manager_id<>?",wlm.id, self.id)
        sentences.each do |sentence|
          if anchor_id!=-1
            sentence.update_attributes(wlu: anchor_id)
          else
            sentence.destroy
          end
        end

      end
        
      #answer_denpyos.each do |answer_denpyo|
      #  answer_denpyo.update(watson_language_master_id: anchor_id)
      #end
    end
    self.destroy
  end
  
  def col_to_string(colnumber)
    output = ""
    divider=0
    loop do
      if divider!=0 
        colnumber = 26*divider
      end
      output = (colnumber.modulo(26)+65).chr+output
      divider = (colnumber/26).to_i
      break if (colnumber.to_f/26.0)<1
    end
    return output
  end
  #------------------------MPEG-------------------------------------------------
  def mpeg_description
    self.update(status: 1)
  end

  def ycbcr(pixel)
    result={}
    result['Y'] = 0.299*pixel[0].to_f + 0.587*pixel[1].to_f + 0.114*pixel[2].to_f
    result['Cb']=-0.169*pixel[0].to_f - 0.331*pixel[1].to_f + 0.500*pixel[2].to_f
    result['Cr']= 0.500*pixel[0].to_f - 0.419*pixel[1].to_f - 0.081*pixel[2].to_f
    return result
  end
  
  def hsv(pixel)
    result={}
    result['Hue'] = 0.00
    result['Saturation'] = 0.00
    max = pixel.max.to_f
    min = pixel.min.to_f
    result['Value']=(max/255).to_f
    if max!=0 
      result['Saturation']=(max-min)/max
    end
    if max != min
      if max == pixel[0] && pixel[1]>= pixel[2]
        result['Hue']=60*(G-B)/(max-min)
      elsif max == pixel[0] && pixel[1]<pixel[2]
        result['Hue']=360+60*(pixel[1]-pixel[2])/(max-min)
      elsif pixel[1]==max
        result['Hue']=60*(2.0+(pixel[2]-pixel[0])/(max-min))
      else 
        result['Hue']=60*(4.0+(pixel[0]-pixel[1])/(max-min))
      end
    end
    return result
  end
  
  def hsv_linear(pixel)
    result={}
    result['Hue'] = Math.atan2((0.5*pixel[0].to_f-0.419*pixel[1].to_f-0.081*pixel[2].to_f), (-0.169*pixel[0].to_f-0.331*pixel[1].to_f+0.5*pixel[2].to_f))
    result['Saturation'] = Math.sqrt((-0.169*pixel[0].to_f-0.331*pixel[1].to_f+0.5*pixel[2].to_f)**2+(0.5*pixel[0].to_f-0.419*pixel[1].to_f-0.081*pixel[2].to_f)**2)
    result['Value'] = 0.299*pixel[0].to_f + 0.587*pixel[1].to_f + 0.114*pixel[2].to_f
    return result
  end
  
  def hmmd(pixel)
    result={}
    result['Hue']  = self.hsv(pixel)['Hue']
    result['Max']  = pixel.max.to_f / 255.0
    result['Min']  = pixel.min.to_f / 255.0
    result['Diff'] = (result['Max']-result['Min']) 
    result['Sum']  = (result['Max']+result['Min']) / 2.0 
    return result
  end

  #------------------------end of MPEG------------------------------------------
  private
  
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
    
    #----------------------MPEG---------------------------------------------------
    #--------------------end of MPEG----------------------------------------------
    
end
