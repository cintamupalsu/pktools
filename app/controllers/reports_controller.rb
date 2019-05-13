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
    checkbox={}
    if userkgi_params['cbchoice']!="" && userkgi_params['cbchoice']!=nil
      checkbox=check_box_bug(userkgi_params['cbchoice'])
    else
      cp=userkgi_params['prev_selected'].split(',')
      (0..cp.count-1).each do |i|
        checkbox[i] =cp[i].to_i
      end
    end
    
    users=User.all.order('email')
    exams=Fukusu.where('',users).first
    
    @nameselected={}
    @checkbox=""

    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        @checkbox+="1"
        username= users[i].email.split('@')
        @nameselected[users[i].id]=username[0]
      else
        @checkbox+="0"
      end
      if i!=checkbox.count-1
        @checkbox+=","
      end
    end
    
    if userkgi_params['year']==nil
      @selected_date_1= Date.strptime(DateTime.now.year.to_s+"/4/1","%Y/%m/%d")
      @selected_date_2= Date.strptime((DateTime.now.year+1).to_s+"/3/30","%Y/%m/%d")
      @year=DateTime.now.year
    else
      year=userkgi_params['year'].to_i
      @selected_date_1= Date.strptime(year.to_s+"/4/1","%Y/%m/%d")
      @selected_date_2= Date.strptime((year+1).to_s+"/3/30","%Y/%m/%d")
      @year=year
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
  
  def user_k_dailyreport
    @users=User.all.order("email")
    @selected_item=3
    @selected_date_1=DateTime.now.to_date
    @selected_date_2=DateTime.now.to_date
    @year=DateTime.now.year
  end 
  
  def kenteidailyreport
    @selected_item=3
    users=User.all.order("email")
    checkbox=check_box_bug(kenteimondai_params['cbchoice'])
    if kenteimondai_params['selected_date_1']==''
      @selected_date_1=DateTime.now.to_date
    else
      @selected_date_1=kenteimondai_params['selected_date_1'].to_date
    end
    if kenteimondai_params['selected_date_2']==''
      @selected_date_2=DateTime.now.to_date
    else
      @selected_date_2=kenteimondai_params['selected_date_2'].to_date
    end
    @users = {}
    @usertableregister = {}
    counter=0
    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        name=users[i].email.split('@')
        @users[counter]=name[0]
        @usertableregister[users[i].id]=counter
        counter+=1
      end
    end
    arrayuserid=Array.new(counter)
    counter=0
    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        arrayuserid[counter]=users[i].id
        counter+=1
      end
    end
    @series=Kenteikaitou.where("user_id IN (?) AND DATE(datetest)>='#{@selected_date_1}' AND DATE(datetest)<='#{@selected_date_2}'",arrayuserid)
  
    render 'kenteidailyreport'
  end
  
  def kentei_m_rpt
    @selected_item=4
    @users=User.all.order('email')
    @selected_date=DateTime.now.to_date
  end
  
  def kentei_m_rpt_post
    @selected_item=4

    users=User.all.order('email')
    checkbox=check_box_bug(kenteimrpt_params['cbchoice'])
    
    @users = {}
    @usertableregister = {}
    counter=0
    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        name=users[i].email.split('@')
        @users[counter]=name[0]
        @usertableregister[users[i].id]=counter
        counter+=1
      end
    end
    arrayuserid=Array.new(counter)
    @matrix=Array.new(counter)
    counter=0
    (0..checkbox.count-1).each do |i|
      if checkbox[i]==1
        arrayuserid[counter]=users[i].id
        counter+=1
      end
    end
    

    
    year = kenteimrpt_params['year'].to_i
    month = kenteimrpt_params['month'].to_i
    @selected_date_1= Date.strptime(year.to_s+"/"+month.to_s+"/1","%Y/%m/%d")
    year2=year
    month2=month+1
    if month2>12
      month2=1 
      year2+=1
    end
    @selected_date_2= Date.strptime(year2.to_s+"/"+month2.to_s+"/1","%Y/%m/%d")
    
    series=Kenteikaitou.where("user_id IN (?) AND DATE(datetest)>='#{@selected_date_1}' AND DATE(datetest)<'#{@selected_date_2}'",arrayuserid).order('datetest')
    @days={}
    @holidays={}
    @mondaiid={}
    @correct={}
    @incorrect={}
    
    (0..@matrix.count-1).each do |i|
      @matrix[i]={}
    end
    series.each do |serie|

      if @days[serie.datetest.day]==nil
        @days[serie.datetest.day]=1
        @mondaiid[serie.datetest.day]=serie.kmondai.id
        @correct[serie.datetest.day]=0
        @incorrect[serie.datetest.day]=0
        
        if serie.datetest.strftime("%A")=="Saturday"|| serie.datetest.strftime("%A")=="Sunday"
          @holidays[serie.datetest.day]=true
        else
          @holidays[serie.datetest.day]=false
        end
      else
        @days[serie.datetest.day]+=1
      end
      @matrix[@usertableregister[serie.user_id]][serie.datetest.day]=serie.correct
      if serie.correct==true 
        @correct[serie.datetest.day]+=1
      else
        @incorrect[serie.datetest.day]+=1
      end
    end
    
    render 'kentei_m_table'
  end 
  
  
  private
  
  def userkgi_params
    params.require(:userkgi).permit(:year, :prev_selected, :cbchoice=>[])
  end
  
  def kenteimondai_params
    params.require(:kenteimondai).permit(:selected_date_1, :selected_date_2, :cbchoice=>[])
  end
  
  def kenteimrpt_params
    params.require(:kenteimrpt).permit(:year, :month, :cbchoice=>[])
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