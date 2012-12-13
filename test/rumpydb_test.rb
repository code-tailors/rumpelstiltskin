require 'test_helper'
require 'rumpydb'
require 'pry'

class TestObject
  attr_accessor :name

  def ==(other)
    self.name == other.name
  end
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

  describe "#find_all" do
    it "returns all the objects when there are only one object" do
      test1 = TestObject.new
      test1.name = "Gianu"
      @rumpydb.save(test1)

      all = @rumpydb.find_all

      all.size.must_equal 1
      all[0].name.must_equal test1.name
    end

    it "returns all the objects when there are two objects" do
      test1 = TestObject.new
      test1.name = "Gianu"
      @rumpydb.save(test1)

      test2 = TestObject.new
      test2.name = "Tute"
      @rumpydb.save(test2)

      all = @rumpydb.find_all

      all.size.must_equal 2
      all.must_include test1
      all.must_include test2
    end

    it "returns all the objects when there are multiple objects" do
     10.times do |i|
       test = TestObject.new
       test.name = "Gianu#{i}"
       @rumpydb.save(test)
     end

     all = @rumpydb.find_all
     all.size.must_equal 10
    end
  end

  describe "#all" do
    it "returns all the objects when there are multiple objects" do
     10.times do |i|
       test = TestObject.new
       test.name = "Gianu#{i}"
       @rumpydb.save(test)
     end

     all = @rumpydb.all
     all.size.must_equal 10
    end
  end

  describe "#delete" do
    describe "with two objects" do
      before :each do
        @test1 = TestObject.new
        @test1.name = "Gianu"
        @rumpydb.save(@test1)

        @test2 = TestObject.new
        @test2.name = "Tute"
        @rumpydb.save(@test2)
      end

      it "deletes the last object" do
        @rumpydb.all.size.must_equal 2

        result = @rumpydb.delete(2) # delete the second object.

        result.must_equal 2
        @rumpydb.all.size.must_equal 1
        @rumpydb.all.first.name.must_equal @test1.name
      end

      it "deletes the first object" do
        @rumpydb.all.size.must_equal 2

        result = @rumpydb.delete(1) # delete the first objects.

        result.must_equal 1
        @rumpydb.all.size.must_equal 1
        @rumpydb.all.first.name.must_equal @test2.name
      end

      it "returns false with non-existing id and don't delete anything" do
        @rumpydb.all.size.must_equal 2

        result = @rumpydb.delete(1000) # non-existing id

        result.must_be_nil
        @rumpydb.all.size.must_equal 2
      end

      it "returns false with nil as id and don't delete anything" do
        @rumpydb.all.size.must_equal 2

        result = @rumpydb.delete(nil)

        result.must_be_nil
        @rumpydb.all.size.must_equal 2
      end
    end

    describe "with one hundred objects" do
      before :each do
        100.times do |n|
          test = TestObject.new
          test.name = "Gianu - Test #{n}"
          @rumpydb.save(test)
        end
      end

      it "deletes an object from the middle" do
        @rumpydb.all.size.must_equal 100

        result = @rumpydb.delete(42)

        result.must_equal 42
        @rumpydb.all.size.must_equal 99
      end
    end
  end

  describe "#update" do
    describe "with two objects" do
      before :each do
        @test1 = TestObject.new
        @test1.name = "Gianu"
        @rumpydb.save(@test1)

        @test2 = TestObject.new
        @test2.name = "Tute"
        @rumpydb.save(@test2)
      end

      it "updates the first objects" do
        new_test = TestObject.new
        new_test.name = "New Name"

        result_value = @rumpydb.update(1, new_test)
        result_value.must_equal 1

        result_obj = @rumpydb.find(1)
        result_obj.name.must_equal new_test.name
      end

      it "updates the second object" do
        new_test = TestObject.new
        new_test.name = "New Name"

        result_value = @rumpydb.update(2, new_test)
        result_value.must_equal 2

        result_obj = @rumpydb.find(2)
        result_obj.name.must_equal new_test.name
      end

      it "return nil when the id does not exist" do
        result_value = @rumpydb.update(444555, TestObject.new)

        result_value.must_be_nil
      end

      it "return nil when the id is nil" do
        result_value = @rumpydb.update(nil, TestObject.new)

        result_value.must_be_nil
      end
    end

    describe "with one hundred objects" do
      before :each do
        100.times do |n|
          test = TestObject.new
          test.name = "Gianu - Test #{n}"
          @rumpydb.save(test)
        end
      end

      it "updates an object from the middle" do
        new_test = TestObject.new
        new_test.name = "New Name"

        result_value = @rumpydb.update(42, new_test)
        result_value.must_equal 42

        result_obj = @rumpydb.find(42)
        result_obj.name.must_equal new_test.name
      end

    end

  end

end
