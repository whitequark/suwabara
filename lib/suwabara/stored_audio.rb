module Suwabara

  class StoredAudio < StoredFile
    attr_reader :duration

    def initialize_from_io(io, original_name)
      super

      movie = FFMPEG::Movie.new(full_path)
      @duration = movie.duration
    end

    def initialize_from_hash(hash)
      super

      @duration = hash["duration"]
    end

    def to_hash
      super.merge({
        "duration" => @duration
      })
    end
  end

end
