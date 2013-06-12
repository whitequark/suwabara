module Suwabara

  class ImageTransform
    def self.parse(input)
      if input.is_a?(ImageTransform)
        input
      else
        input =~ /^(?:(\d+)x(\d+)\+(\d+)\+(\d+):)?(\d+)?x(\d+)?$/

        new($5, $6, $3, $4, $1, $2)
      end
    end

    def initialize(width,          height,
                   crop_left=nil,  crop_top=nil,
                   crop_width=nil, crop_height=nil)

      @width,      @height      = width,  height

      @crop_left,  @crop_top    = crop_left,  crop_top
      @crop_width, @crop_height = crop_width, crop_height

      freeze
    end

    def crop_geometry
      if [@crop_left, @crop_top, @crop_width, @crop_height].any?
        "#{@crop_width}x#{@crop_height}+#{@crop_left || 0}+#{@crop_top || 0}"
      end
    end

    def resize_geometry
      if [@width, @height].any?
        "#{@width}x#{@height}"
      end
    end

    def present?
      [crop_geometry, resize_geometry].any?
    end

    def process(source, destination)
      destination.parent.mkpath

      image = MiniMagick::Image.open(source)

      image.combine_options do |c|
        if crop_geometry
          c.crop(crop_geometry)
        end

        if resize_geometry
          c.scale(resize_geometry + '^')
          c.gravity('center')
          c.background('white')
          c.extent(resize_geometry)
        end
      end

      image.write(destination)
    end

    def to_s
      [crop_geometry, resize_geometry].compact.join(':')
    end
  end

end
