module Suwabara::ORM

  module ActiveRecord
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :_mounted_storages

      def mount_storage(name, klass, options={})
        name = name.to_sym

        if (unknown_opts = options.keys - [:text]).any?
          raise ArgumentError, "unknown options for mount_storage: #{unknown_opts.join(', ')}"
        end

        @_mounted_storages ||= {}
        @_mounted_storages[name] = klass

        define_method(name) do
          if read_attribute(name)
            hash = JSON.load(read_attribute(name))
            self.class._mounted_storages[name].new(self, name, hash)
          end
        end

        define_method(:"#{name}=") do |value|
          if value.is_a?(ActionDispatch::Http::UploadedFile)
            stored_file = self.class._mounted_storages[name].new(self, name,
                                  value.tempfile, value.original_filename)
          elsif value.is_a?(Suwabara::StoredFile)
            stored_file = value
          elsif value.respond_to?(:to_hash) || value.respond_to?(:to_io)
            stored_file = self.class._mounted_storages[name].new(self, name,
                                  value)
          else
            raise ArgumentError, "Writer #{name}= accepts " +
                    "ActionDispatch::Http::UploadedFile, Suwabara::StoredFile, IO or " +
                    "Hash"
          end

          write_attribute(name, JSON.dump(stored_file.to_hash))
        end

        if options[:text]
          define_method(:"#{name}_text") do
            send(name).read
          end

          define_method(:"#{name}_text=") do |text|
            send(:"#{name}=", send(name).rewrite(text))
          end
        end
      end
    end
  end

end

ActiveRecord::Base.send :include, Suwabara::ORM::ActiveRecord
