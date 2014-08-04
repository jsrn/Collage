include CollageBuilder

class UploadController < ApplicationController
  def process_zip
    if params[:zipfile].content_type != "application/zip"
      redirect_to "/", :flash => {
        :upload_failed => true
      }
      return
    end

    content = CollageBuilder::build(params[:zipfile].path)

    send_data content, :type => 'image/jpeg', :disposition => 'attachment', filename: "collage-#{Time.now.to_i}.jpg"
    return
  end
end
