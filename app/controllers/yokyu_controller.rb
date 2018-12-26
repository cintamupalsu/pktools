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

  def answer
  end
  
  private
  
  def learning_params
    params.require(:learning).permit(:filename)    
  end
  
  def company_params
    params.require(:company).permit(:name, :address, :co_type)
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
