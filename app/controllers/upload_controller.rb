include CollageBuilder

class UploadController < ApplicationController
  def process_zip
    if params[:zipfile].nil?
      redirect_to "/", :flash => {
        :no_file_selected => true
      }
      return
    end

    content_type = params[:zipfile].content_type
    if not ["application/zip", "application/octet-stream"].include? content_type
      redirect_to "/", :flash => {
        :invalid_file => true
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
