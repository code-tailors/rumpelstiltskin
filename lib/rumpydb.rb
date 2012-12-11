require "rumpydb/version"
require 'digest/md5'
require 'pry'


class RumpyDB
  class << self
    attr_accessor :id, :file_db
  end

  def initialize(opts={})
    opts = {file_db: "rumpy.db"}.merge(opts)
    @file_db = opts[:file_db]
  end
  
  def find(id)
    objects = open_db('r').readlines
    objects[objects.size - id]
  end

  def save(object)
    @id ||= 0 
    open_db('a+') do |file|
      file << object.inspect
      @id += 1
    end
    @id
  end
  
  def open_db(opts='r', &block)
    file_open = File.open(@file_db,opts)
    if block_given?
      block.call(file_open) 
      file_open.close
    end
    file_open
  end

  def close_db(flush=true)
    File.open(@file_db,'r').close
  end
end
