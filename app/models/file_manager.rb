class FileManager < ApplicationRecord
  belongs_to :user
  has_many :answer_denpyos, dependent: :destroy
  has_many :sentences, dependent: :destroy
  has_many :watson_language_masters, dependent: :destroy
  
  def learning(natural_language_understanding, file_manager, question, answer, user, answer_id, hospital_id, vendor_id)
    threshold = 0.1

    (0..question.count-1).each do |row|
      if question[row]!=nil
        if question[row]!=""
          variant= question[row].gsub(/。|、|\ |\.|,|　|\n/,'')
          # find same Watson
          wlm = WatsonLanguageMaster.where("variant = ? AND user_id= ?",variant, user.id).first
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
            AnswerDenpyo.create(user_id: user.id, 
                                watson_language_master_id: anchor, 
                                content: answer[ans][row],
                                answer_id: answer_id[ans],
                                hospital_id: hospital_id,
                                vendor_id: vendor_id,
                                file_manager_id: file_manager.id
                                )
          end
          
          if find_similar!=-1
            # Need Confirmation
            sentence = Sentence.create!(content: question[row], 
                                        watson_language_master_id: wlm.id,
                                        user_id: user.id,
                                        hospital: hospital_id,
                                        vendor: vendor_id,
                                        file_manager_id: file_manager.id,
                                        wlu: find_similar)
          end
        end
      end
    end
    update_attributes(status: 1)
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

end
