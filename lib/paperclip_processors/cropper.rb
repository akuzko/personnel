#module Paperclip
#  class Cropper < Thumbnail
#
#    def initialize(file, options = {}, attachment = nil)
#      super
#      @current_geometry.width  = target.crop_w
#      @current_geometry.height = target.crop_h
#    end
#
#    def target
#      @attachment.instance
#    end
#
#    def transformation_command
#      crop_command = [
#          "-crop",
#          "#{target.crop_w}x" \
#          "#{target.crop_h}+" \
#          "#{target.crop_x}+" \
#          "#{target.crop_y}",
#          "+repage"
#      ]
#      crop_command + super
#    end
#
#  end
#end

module Paperclip
  class Cropper < Thumbnail
    #def initialize *args
    #  super
    #  @crop = false
    #end

    def transformation_command
      super.tap{ |command| command.unshift(crop_command).push('+repage') if crop_command }
    end

    def crop_command
      target = @attachment.instance
      #["-crop", "200x200+100+100"] if target.cropping?
      ["-crop", "#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}"] if target.cropping?
    end
  end
end