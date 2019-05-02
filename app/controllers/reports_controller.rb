class ReportsController < ApplicationController
  def index
    @selected_item=0
    @users=User.all.order('email')
  end
  
  def userkpi
    @selected_item=1
    kmondais=Kmondai.all
    @kmondaitypes={}
    kmondais.each do |kmondai|
      if @kmondaitypes[kmondai.system]==nil
        @kmondaitypes[kmondai.system]=0
      end
    end
    
    # count daily test kpi
    kenteikaitos=Kenteikaito.all
    
    kenteikaitos.each do |kenteikaito|
      
    end
  end
  
  def userkgi
    @selected_item=2
    @users=User.all.order('email')
  end
  
  def postuserkgi
    @selected_item=2
    checkbox=check_box_bug(userkgi_params['cbchoice'])
    users=User.all.order('email')
    exams=Fukusu.where('',users).first
    
    @nameselected={}
    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        username= users[i].email.split('@')
        @nameselected[users[i].id]=username[0]
      end
    end
    
    if userkgi_params['year']==nil
      @selected_date_1= Date.strptime(DateTime.now.year.to_s+"/4/1","%Y/%m/%d")
      @selected_date_2= Date.strptime((DateTime.now.year+1).to_s+"/3/30","%Y/%m/%d")
    else
    end
    
    
    @exams=Fukusu.where("DATE(created_at)>='#{@selected_date_1}' AND DATE(created_at)<='#{@selected_date_2}'")
    
    @series=Array.new(@exams.count)
    @heikin=Array.new(@exams.count)
    (0..@exams.count-1).each do |i|
      @heikin[i]=0
    end
    (0..@exams.count-1).each do |i|
      data=Array.new(@nameselected.count)
      c_data=0
      @nameselected.each do |k,v|
        fuser= Fuser.where("user_id=? AND fukusu_id =?", k, @exams[i].id).first
        if fuser!=nil && fuser.resultfloat!=nil
          data[c_data]=fuser.resultfloat*100
          @heikin[i]+=fuser.resultfloat
        else
          data[c_data]=0
        end 
        c_data+=1
      end
      @series[i]=data
    end
    (0..@exams.count-1).each do |i|
      @heikin[i]=@heikin[i]/@nameselected.count*100
    end
    
    render "postuserkgi"
  end
  
  private
  
  def userkgi_params
    params.require(:userkgi).permit(:cbchoice=>[])
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
