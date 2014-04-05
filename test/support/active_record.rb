NullDB.configure {|ndb| def ndb.project_root;File.expand_path('../orm/dummy', __FILE__);end}
ActiveRecord::Base.establish_connection :adapter => :nulldb, :schema  => 'schema.rb'
ActiveRecord::Migration.create_table :testable_models do |t|
  t.text :image
  t.timestamps
end
module ActionDispatch
  module Http
    module UploadedFile
    end
  end
end
