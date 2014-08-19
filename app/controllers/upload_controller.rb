include CollageBuilder

class UploadController < ApplicationController
  def process_zip
    if params[:zipfile].nil?
      redirect_to "/", :flash => {
        :no_file_selected => true
      }
      return
    end
    
    content = CollageBuilder::build(params[:zipfile].path)

    unless content
      redirect_to "/", :flash => {
        :upload_failed => true
      }
      return
    end

    send_data content, :type => 'image/jpeg', :disposition => 'attachment', filename: "collage-#{Time.now.to_i}.jpg"
    return
  end
end
