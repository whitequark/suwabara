require 'pathname'
require 'uri'
require 'mime-types'

require 'mini_magick'
require 'streamio-ffmpeg'

module Suwabara
  require 'suwabara/image_transform'

  require 'suwabara/stored_file'
  require 'suwabara/stored_image'
  require 'suwabara/stored_audio'

  if defined?(ActiveRecord)
    require 'suwabara/orm/activerecord'
  end

  if defined?(Rails)
    require 'suwabara/asset_handler'
    require 'suwabara/railtie'
  end

  def self.default_root
    if defined?(Rails)
      Rails.root.join('public')
    else
      Pathname.new('tmp')
    end
  end
end
