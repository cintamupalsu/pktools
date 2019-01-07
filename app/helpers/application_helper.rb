module ApplicationHelper
  def full_title(page_title='')
    base_title = "PK-Tools"
    if page_title.empty?
      base_title
    else
      page_title+"|"+base_title
    end
  end
  
  def notices
    @sentence_count = Sentence.where("user_id=?",current_user.id).count
    @yok_notices = @sentence_count
  end

end
