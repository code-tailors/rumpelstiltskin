require 'test_helper'
# require 'minitest/benchmark'
require 'benchmark'
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

  it "#save" do
    objects_to_save = []
    10_000.times do |n|
      obj = TestObject.new
      obj.name = "Test#{n}"
      objects_to_save << obj
    end

    bm = Benchmark.measure "10.000 insertions" do
      objects_to_save.each do |obj|
        @rumpydb.save(obj)
      end
    end

    bm.real.must_be_close_to 4, 0.99
  end
end
