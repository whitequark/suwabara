ActiveRecord::Schema.define(version: 20140402154806) do

  create_table "testable_model", force: true do |t|
    t.text   "image"
    t.text   "image2"
  end

end
