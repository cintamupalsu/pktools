class KpiController < ApplicationController
  def index
    @selected_item=0
    @performances=Performance.all
    pdenpyo=PerformDenpyo.where("user_id=?", current_user.id)
    @total_points=0
    
    pdenpyo.each do |pden|
      pdet=PerformDetail.find(pden.perform_detail_id)
      if pdet.points!=nil && pdet.points>0
        if pden.completed!=nil && pden.completed>0 
          @total_points+=((pden.completed/100)*pdet.points).to_i
        end
      end
    end
  end
  
  def assessement
    @selected_item=0
    @performance=Performance.find(params[:id])
  end
  
  def performance_index
    @selected_item=1
    @performances=Performance.all
  end
  
  def performance_new
    @selected_item=1
  end
  
  def performance_create
    @selected_item=1
    @performance = Performance.new(performance_params)
    @performance.user_id = current_user.id
    @performance.u_user = current_user.id
    if @performance.save
      flash[:info] = "タスクを登録しました。"
      redirect_to performance_index_path
    else
      render 'performance_new'
    end
  end
  
  def performance_show
  end
  
  def performance_delete
    performance = Performance.find(params[:id])
    performance.destroy
    flash[:success] = "タスクを削除しました"
    redirect_to performance_index_path
  end
  
  def performance_edit
    @selected_item=1
    @performance = Performance.find(params[:id])
  end
  
  def performance_update
    performance = Performance.find(performance_params['id'].to_i)
    if performance_params['k_pic']==nil
      if performance.update_attributes(name: performance_params['name'],
                                       u_user: current_user.id,
                                       description: performance_params['description'],
                                       shurui: performance_params['shurui'],
                                       schedule: performance_params['schedule'])
         flash[:success] = "タスクを編集した"
         redirect_to performance_index_path
      else
         render 'performance_edit'
      end
    else
      if performance.update_attributes(performance_params)
         flash[:success] = "タスクを編集した"
         redirect_to performance_index_path
      else
         render 'performance_edit'
      end
    end
  end
  
  def performance_task
    @selected_item=1
    @performance = Performance.find(params[:id])
    @tasks = PerformDetail.where("performance_id=?", @performance.id)
  end
  
  def perform_detail_new
    @selected_item=1
    @performance = Performance.find(params[:id])

  end

  def perform_detail_create
    
    hours = perform_detail_params['hours'].to_i
    minutes = perform_detail_params['minutes'].to_i
    minutes += (hours*60)
    if  perform_detail_params['points']==nil
      points=0
    else
      points=perform_detail_params['points'].to_i
    end
    perform_detail = PerformDetail.new(description: perform_detail_params['description'],
                         performance_id: perform_detail_params['performance_id'],
                         minminutestime: minutes,
                         points: points,
                         minvalue: perform_detail_params['minvalue'],
                         valuename: perform_detail_params['valuename'],
                         flinks: perform_detail_params['flinks']
                         )
    if perform_detail.save
      performance=Performance.find(perform_detail.performance_id)
      update_performance_point(performance)
      flash[:info] = "タスクを登録しました。"
      redirect_to performance_task_path(:id => perform_detail_params['performance_id'])
    else
      @performance = Performance.find(perform_detail_params['performance_id'])
      render 'perform_detail_new'
    end
  end
  
  def perform_detail_edit
    @selected_item=1
    @task=PerformDetail.find(params[:id])
  end
  
  def perform_detail_update
    perform_detail= PerformDetail.find(perform_detail_params['id'])

    hours = perform_detail_params['hours'].to_i
    minutes = perform_detail_params['minutes'].to_i
    minutes += (hours*60)
    if perform_detail.update_attributes(description: perform_detail_params['description'],
                         minminutestime: minutes,
                         points: perform_detail_params['points'],
                         minvalue: perform_detail_params['minvalue'],
                         valuename: perform_detail_params['valuename'],
                         flinks: perform_detail_params['flinks']
                         )
       performance=Performance.find(perform_detail.performance_id)
       update_performance_point(performance)
       flash[:success] = "タスク項目を編集した"
       redirect_to performance_task_path(:id => perform_detail_params['performance_id'])
    else
       @performance = Performance.find(perform_detail_params['performance_id'])
       render 'performance_edit'
    end
    
  end
  
  def perform_detail_delete
    perform_detail = PerformDetail.find(params[:id])
    performance = Performance.find(perform_detail.performance_id)
    perform_detail.destroy
    update_performance_point(performance)
    flash[:success] = "タスク項目を削除しました"
    redirect_to performance_task_path(:id => performance.id)
  end
  
  def assessement_record
    checkbox = check_box_bug(perform_denpyo_multiple_params['yaru'])
    (0..checkbox.count-1).each do |counter|
      if checkbox[counter]==1
        pdetail = PerformDetail.find(perform_denpyo_multiple_params['perform_detail_id'][counter])
        
        max_achieve=0.0
        v_achieve=0.0
        if pdetail.minvalue!= nil && pdetail.minvalue>0
          v_achieve=perform_denpyo_multiple_params['achieve_value'][counter].to_i/pdetail.minvalue
          if v_achieve>1
            v_achieve=1
          end
          max_achieve+=1
        end
  
        t_achieve=0.0
        minutes=0
        if pdetail.minminutestime >0
          minutes=perform_denpyo_multiple_params['hours'][counter].to_i*60
          minutes+=perform_denpyo_multiple_params['minutes'][counter].to_i
          t_achieve=minutes.to_f/pdetail.minminutestime.to_f
      
          if t_achieve>1
            t_achieve=1
          end
          max_achieve+=1
        end
        
        if t_achieve==0 && v_achieve==0 && (pdetail.minminutestime==0||pdetail.minminutestime==nil) && (pdetail.minvalue==0||pdetail.minvalue==nil)
          achievement = 100
        else
          achievement = ((v_achieve+t_achieve)/max_achieve)*100
        end
        
        perform_denpyo=PerformDenpyo.where("user_id=? AND perform_detail_id=?", current_user.id, pdetail.id).first
        if perform_denpyo
          perform_denpyo.update_attributes(completed: achievement, value: perform_denpyo_multiple_params['achieve_value'][counter].to_i, minutes: minutes)
        else
          PerformDenpyo.create(user_id: current_user.id, 
                               performance_id: pdetail.performance_id, 
                               perform_detail_id: pdetail.id, 
                               completed: achievement, 
                               value: perform_denpyo_multiple_params['achieve_value'][counter].to_i, 
                               minutes: minutes, 
                               created_at_utc: Time.zone.now
                               )
        end
      else
        pdetail = PerformDetail.find(perform_denpyo_multiple_params['perform_detail_id'][counter])
        perform_denpyo=PerformDenpyo.where("user_id=? AND perform_detail_id=?", current_user.id, pdetail.id).first
        if perform_denpyo
          perform_denpyo.destroy
        end
      end
    end
    redirect_to kpi_path
    #@param_kocok= perform_denpyo_multiple_params
    #render 'parcok'
  end
  
  def reports
    @selected_item=2
    if params[:selected_date]==nil 
      @selected_date = Time.zone.now.to_date
    else
      @selected_date = Date.parse(params[:selected_date])
    end
    
    @scores={}
    @users=User.all
    @performances = Performance.all
    @users.each do |user|
      @scores[user.id]={}
      @performances.each do |performance|
        @scores[user.id][performance.id]=0
      end
    end
    pdetailpoint={}
    pdetails=PerformDetail.all
    pdetails.each do |pdetail|
      pdetailpoint[pdetail.id]=pdetail.points
    end
    
    
    pdenpyos = PerformDenpyo.where("DATE(created_at_utc)>= '#{@selected_date.beginning_of_month}' AND DATE(created_at_utc)< '#{@selected_date.end_of_month + 1.day}' ")
    pdenpyos.each do |pdenpyo|
      @scores[pdenpyo.user_id][pdenpyo.performance_id]+=((pdenpyo.completed/100)*pdetailpoint[pdenpyo.perform_detail_id])
    end
    
    #@pdenpos=PerformDenpyo.where("user_id=? AND DATE(created_at_utc) >= { ")
  end
  
  def reports_henkou
    @selected_item=2
    if reports_params['selected_date']!=""
      #begin
      #  @selected_date = Date.parse(reports_params['selected_date'])
      #rescue => e
        date_string =reports_params['selected_date'].split('/')
        getdate=date_string[2]+"/"+date_string[0]+"/"+date_string[1]
        @selected_date=Date.parse(getdate)
      #end
    else
      @selected_date = Time.zone.now.to_date
    end
    redirect_to kpi_reports_path(:selected_date => @selected_date)
  end

  private
  def performance_params
    params.require(:performance).permit(:name, :k_pic, :user, :u_user, :description, :point, :shurui, :schedule, :id)    
  end

  def perform_detail_params
    params.require(:perform_detail).permit(:description, :points, :hours, :minutes, :performance_id, :valuename, :minvalue, :id, :flinks)    
  end
  
  def perform_denpyo_multiple_params
    params.require(:perform_denpyos).permit(:id, :yaru=>[], :perform_detail_id=>[], :achieve_value=>[], :hours=>[], :minutes=>[] )
  end
  
  def reports_params
    params.require(:reports).permit(:selected_date)
  end
  
  def update_performance_point(performance)
      perform_details = PerformDetail.where("performance_id=?", performance.id)
      total_points=0
      perform_details.each do |pd|
        if pd.points!=nil
          total_points+=pd.points
        end
      end
      performance.update_attributes(points: total_points)
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
  
  def userid(user)
      userstring= user.email.split('@')
      return userstring[0]
  end
end
