class KpiController < ApplicationController
  def index
    @selected_item=0
    @performances=Performance.all
  end
  
  def assessement
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
    
    perform_detail = PerformDetail.new(description: perform_detail_params['description'],
                         performance_id: perform_detail_params['performance_id'],
                         minminutestime: minutes,
                         points: perform_detail_params['points'],
                         minvalue: perform_detail_params['minvalue'],
                         valuename: perform_detail_params['valuename']
                         )
    if perform_detail.save
      flash[:info] = "タスクを登録しました。"
      redirect_to performance_task_path(:id => perform_detail_params['performance_id'])
    else
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
                         valuename: perform_detail_params['valuename']
                         )
       flash[:success] = "タスク項目を編集した"
       redirect_to performance_task_path(:id => perform_detail_params['performance_id'])
    else
       render 'performance_edit'
    end
    
  end
  
  def perform_detail_delete
    perform_detail = PerformDetail.find(params[:id])
    performance_id = perform_detail.performance_id
    perform_detail.destroy
    flash[:success] = "タスク項目を削除しました"
    redirect_to performance_task_path(:id => performance_id)
  end

  private
  def performance_params
    params.require(:performance).permit(:name, :k_pic, :user, :u_user, :description, :point, :shurui, :schedule, :id)    
  end

  def perform_detail_params
    params.require(:perform_detail).permit(:description, :points, :hours, :minutes, :performance_id, :valuename, :minvalue, :id)    
  end

end
