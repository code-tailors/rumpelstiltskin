require 'test_helper'
require 'rumpydb'
require 'pry'

class TestObject
  attr_accessor :name
end

describe RumpyDB do
  before do
    FileUtils.rm("rumpy.db", force: true)
    @rumpydb = RumpyDB.new
  end

  it "save an object" do
    test_object = TestObject.new
    test_object.name = "rumpelstiltskin"
    @rumpydb.save(test_object)
    File.read("rumpy.db").wont_be_empty
  end

  it "returns an id" do
    test_object = TestObject.new
    test_object.name = "rumpelstiltskin"
    @rumpydb.save(test_object).must_be_instance_of(Fixnum)
  end

  it "returns differents ids when different objects" do
    test1 = TestObject.new
    test1.name = "Gianu"
    id1 = @rumpydb.save(test1)

    test2 = TestObject.new
    test2.name = "Tute"
    id2 = @rumpydb.save(test2)

    id1.wont_equal id2
  end


  it "returns differents ids when objects with equal attributes" do
    test1 = TestObject.new
    test1.name = "Gianu"
    id1 = @rumpydb.save(test1)

    test2 = TestObject.new
    test2.name = "Gianu"
    id2 = @rumpydb.save(test2)

    id1.wont_equal id2
  end

  it "find objects by id" do
    test = TestObject.new
    test.name = "Gianux"
    id = @rumpydb.save(test)
    puts id
    returned = @rumpydb.find(id)
    returned.name.must_equal test.name
  end

  it "saves multiple objects and find one" do
    test1 = TestObject.new
    test1.name = "Gianu1"
    id1 = @rumpydb.save(test1)

    test2 = TestObject.new
    test2.name = "Gianu2"
    id2 = @rumpydb.save(test2)
    object1 = @rumpydb.find(id1)
    object2 = @rumpydb.find(id2)
    object1.name.must_equal test1.name
    object2.name.must_equal test2.name
  end

end
