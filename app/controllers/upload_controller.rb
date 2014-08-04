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

    send_data content, :type => 'image/png',:disposition => 'inline'
    return
  end
end
