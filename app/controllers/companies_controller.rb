# -----------------------------------------------------------
# 01.01 2019/01/10 by Arief Maulana as Ota-san requrested
# -----------------------------------------------------------
# 01.01 2019/01/10 Yokyu sentence input is valid for all user
# -----------------------------------------------------------
class CompaniesController < ApplicationController
    
  def index
    #company_sql = "SELECT * FROM companies WHERE user_id = '#{current_user.id}'"
    #hospital_ids = Hospital.where("user_id = ?",current_user.id).pluck(:company_id)
    #vendor_ids = Vendor.where("user_id = ?",current_user.id).pluck(:company_id)
    company_sql = "SELECT * FROM companies"
    hospital_ids = Hospital.all.pluck(:company_id)
    vendor_ids = Vendor.all.pluck(:company_id)
    @companies = Company.paginate_by_sql(company_sql, page: params[:company_page], :per_page => 10)
    @hospitals = Company.where("id IN (?)",hospital_ids).paginate(:page => params[:hospital_page], :per_page => 10)
    @vendors = Company.where("id IN (?)",vendor_ids).paginate(:page => params[:vendor_page], :per_page => 10)
    @selected_item=0
    @tab = params[:tab].to_i
    #@paramkocok = params #pasticocok = pascok
    
  end
  
  def new
    @selected_item=1
    #@company = Company.new
  end
  
  def create
  
    company= Company.create(name: company_params['name'], address: company_params['address'], user_id: current_user.id)
    
    if company_params['hospital']
      Hospital.create(company_id: company.id, user_id: current_user.id)   
    end
    if company_params['vendor']
      Vendor.create(company_id: company.id, user_id: current_user.id)    
    end
    #@paramkocok= params
    redirect_to companies_path
  end
  
  def edit
    @get_company= Company.find(params[:id])
  end
  
  def show
    @company= Company.find(params[:id])
  end
  
  def update
    @company = Company.find(company_params['id'].to_i)
    if @company.update_attributes(name: company_params['name'], address: company_params['address'])
      if company_params['hospital']

        if Hospital.where("company_id = ?", @company.id).count==0
            Hospital.create(company_id: @company.id, user_id: current_user.id)      
        end
      else
        Hospital.where("company_id = ?", @company.id).destroy_all
      end
      if company_params['vendor']
        if Vendor.where("company_id = ?", @company.id).count==0
            Vendor.create(company_id: @company.id, user_id: current_user.id)      
        end
      else
        Vendor.where("company_id = ?", @company.id).destroy_all
      end
      flash[:success] = "Company updated"
      redirect_to @company
    else
      render 'edit'
    end
  end
  def destroy
    Company.find(params[:id]).destroy
    flash[:success] = "顧客を削除しました"
    redirect_to companies_url
  end

  
  private
  
  def company_params
    params.require(:company).permit(:name, :address, :hospital, :vendor, :id)
  end


end
