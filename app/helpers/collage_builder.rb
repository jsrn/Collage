require 'zip'
require 'RMagick'

module CollageBuilder
  def build(filepath)
    @images = Zip::File.open(filepath)

    prepare_params
    prepare_canvas

    x_off, row = 0, 0

    # Handle entries one by one
    @images.sort.each do |entry|
      content = entry.get_input_stream.read

      img = Magick::Image::from_blob(content)[0]

      width  = img.columns
      height = img.rows

      # scale old image to new height
      factor =   @new_image_height.to_f / height
      new_image_width = (width * factor).to_i

      img = img.resize_to_fill!(new_image_width, @new_image_height)

      # add it to canvas
      if x_off + new_image_width + @border_width > @max_width
        row  += 1
        x_off = 0
      end

      required_height = ((row + 1) * @new_image_height + (row + 1) * @border_width + @border_width).ceil.to_i

      if @canvas.rows < required_height
        @canvas = @canvas.extent(@max_width, required_height)
      end

      @canvas.composite!(
        img,
        x_off + @border_width,
        (row*@new_image_height + (row+1)*@border_width).to_i,
        Magick::OverCompositeOp
      )

      x_off += new_image_width + @border_width

      if x_off > @right_most_point
        @right_most_point = x_off
      end

      img.destroy!
      GC.start
    end

    trim_image

    return @canvas.to_blob
  end

  def prepare_params
    @new_image_height  = get_mean_height
    @max_width         = 1200
    @right_most_point  = 0 
    @border_width      = 2
    @background_colour = "blue"
  end

  def prepare_canvas
    @canvas = Magick::Image.new(@max_width, 100)
    @canvas.format = "PNG"
    @canvas.background_color = "Transparent"
  end

  def get_mean_height
    total = 0
    @images.each do |entry|
      content = entry.get_input_stream.read
      image   = Magick::Image::from_blob(content)[0]
      total  += image.rows
    end
    return (total / @images.size).to_i
  end

  def trim_image
    @canvas.resize_to_fill!(
      @right_most_point + @border_width,
      @canvas.rows,
      Magick::NorthWestGravity)
  end
end