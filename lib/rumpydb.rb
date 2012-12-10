require "rumpydb/version"
require 'digest/md5'


class RumpyDB
  class << self
    attr_accessor :id, :file_db
  end

  def initialize(opts={})
    opts = {file_db: "rumpy.db"}.merge(opts)
    @file_db = opts[:file_db]
  end
  
  def find(id)
    objects = File.open(@file_db,'r').readlines
    objects[objects.size - id]
  end

  def save(object)
    @id ||= 0 
    #Digest::MD5.digest(object.inspect)
    File.open(@file_db,"a+") do |file|
      file.puts(object.inspect)
      @id += 1
    end
    @id
  end
end
