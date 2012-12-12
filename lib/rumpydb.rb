require "rumpydb/version"
require 'digest/md5'
require 'pry'


class RumpyDB
  RUMPYDB_SEPARATOR="---EOO"

  class << self
    attr_accessor :id, :file_db
  end

  def initialize(opts={})
    opts = {file_db: "rumpy.db"}.merge(opts)
    @file_db = opts[:file_db]
    @id = 0
  end

  def find_all
    objects = IO.readlines(@file_db, RUMPYDB_SEPARATOR)
    objects.map do |row|
      row =~ Regexp.new("\\[\\d+\\]\(.+)#{RUMPYDB_SEPARATOR}", Regexp::MULTILINE)
      deserialize($1)
    end.compact
  end

  alias :all :find_all

  def find(id)
    objects = IO.readlines(@file_db, RUMPYDB_SEPARATOR)
    finded = objects.collect do |row|
      row =~ Regexp.new("\\[#{id}\\]\(.+)#{RUMPYDB_SEPARATOR}", Regexp::MULTILINE)
      $1
    end.compact

    return deserialize(finded.first) if finded.size == 1

    raise "RumpyDB::NotFound" if finded.size == 0
    raise "RumpyDB::DirtyId" if finded.size > 1
  end

  def save(object)
    @id += 1
    open_db('a+') do |file|
      file << serialize(@id, object)
    end
    @id
  end

  private
  def serialize(id,object)
    "[#{id}]#{Marshal.dump(object).dump}---EOO"
  end

  def deserialize(object)
    Marshal.load(eval(object))
  end

  def open_db(opts='r', &block)
    file_open = File.open(@file_db,opts+":UTF-8")
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
