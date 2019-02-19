class Mpeg7Controller < ApplicationController
  def index
    @files_png= FileManager.where("content_type='image/png' AND status<2")
    @paramkocok={}
    pixel=[100,80,255]
    @paramkocok=@files_png[0].hsv(pixel)
    @pasticocok=@files_png[0].hsv_linear(pixel)
    @cocok=@files_png[0].ycbcr(pixel)
  end
  
  def image_saving
    if params[:saving]!= nil && saving_params['filename']!=nil 
      file_png= saving_params['filename']
      if file_png.content_type=="image/png"
        file_manager = FileManager.create!(name: file_png.original_filename,
                                           content_type: file_png.content_type.chomp,
                                           data: file_png.read,
                                           user_id: current_user.id,
                                           status: 0,
                                           hospital_id: Hospital.first.id,
                                           vendor_id: Vendor.first.id,
                                           question_id: Question.first.id,
                                           picture: saving_params['filename'])
        file_manager.delay.mpeg_description()
      else
        flash[:warning]="PNGしか登録できない"
      end
    else
      flash[:warning]="ファイルを見つけられない"
    end
    redirect_to mpeg7_path
  end

  private
  
  def saving_params
    params.require(:saving).permit(:filename)
  end
end
