class ReportsController < ApplicationController
  def index
    @selected_item=0
    @users=User.all.order('email')
  end
  
  def userkpi
    @selected_item=0
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
end
