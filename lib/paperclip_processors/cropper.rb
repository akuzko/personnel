#module Paperclip
#  class Cropper < Thumbnail
#    def transformation_command
#      if crop_command
#        crop_command + super.sub(/ -crop \S+/, '')
#      else
#        super
#      end
#    end
#
#    def crop_command
#      target = @attachment.instance
#      debugger
#      if target.cropping?
#        " -crop '#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}'"
#      end
#    end
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