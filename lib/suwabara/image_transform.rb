module Suwabara

  class ImageTransform
    def self.parse(input)
      if input.is_a?(ImageTransform)
        input
      else
        input =~ /^(?: (\d+)x(\d+)\+(\d+)\+(\d+) :? )?
                   (?: (\d+)?x(\d+)? )?
                  $/x

        new($5, $6, $3, $4, $1, $2)
      end
    end

    def initialize(width,          height,
                   crop_left=nil,  crop_top=nil,
                   crop_width=nil, crop_height=nil)

      @width, @height, @crop_left,  @crop_top, @crop_width, @crop_height =
        [ width, height, crop_left, crop_top, crop_width, crop_height].
          map { |value| value && value.to_i }

      freeze
    end

    # Crop at two points.
    def crop_points(x1, y1, x2, y2)
      x1, x2 = [x1, x2].sort
      y1, y2 = [y1, y2].sort

      crop_dimensions(x1, y1, x2 - x1, y2 - y1)
    end

    # Crop at a certain width and height.
    def crop_dimensions(left, top, width, height)
      self.class.new(@width, @height, left, top, width, height)
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

          if [@width, @height].all?
            c.extent(resize_geometry)
          end
        end
      end

      image.write(destination)
    end

    def to_s
      [crop_geometry, resize_geometry].compact.join(':')
    end

    private

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
  end

end
