require 'test_helper'
require 'rumpydb'

class TestObject
  attr_accessor :name
end

describe RumpyDB do
  it "save an object" do
    test_object = TestObject.new
    test_object.name = "rumpelstiltskin"
    RumpyDB.save(test_object)
  end

end
