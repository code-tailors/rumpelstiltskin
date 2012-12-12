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

  # Public: Retrieve all the object from the rumpy database.
  #
  # Examples
  #   rumpy_db.find_all
  #         or
  #   rumpy_db.all
  #   #=> [<#Object:0x007ff4aa83fb20>, <#Object:0x007fa4ba76ac19>]
  #
  # Returns all the objects from the rumpy database
  def find_all
    objects = IO.readlines(@file_db, RUMPYDB_SEPARATOR)
    objects.map do |row|
      row =~ Regexp.new("\\[\\d+\\]\(.+)#{RUMPYDB_SEPARATOR}", Regexp::MULTILINE)
      deserialize($1)
    end.compact
  end

  alias :all :find_all

  # Public: Find the object with the given id.
  #
  # id - An Integer representing the id of the object
  #
  # Examples
  #   rumpy_db.find(1)
  #   # => <#Object:0x007ff4aa83fb20>
  #
  # Returns the object stored with the given id
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

  # Public: Save the register to rumpy db.
  #  This method save the object every, so if you save an object twice, you'll
  #  end with 2 objects in rumpy db.
  #
  # object - An Object to be saved in rumpy db.
  #
  # Examples
  #   rumpy_db.save(Object.new)
  #   # => 1
  #
  # Returns the id assigned to the object in the db.
  def save(object)
    @id += 1
    open_db('a+') do |file|
      file << serialize(@id, object)
    end
    @id
  end

  # Public: Delete the register with the Given ID.
  #
  # rumpy_id - An Integer representing the stored id of the object.
  #
  # Examples
  #   rumpy_db.delete(1)
  #   # => true
  #
  # Returns true if the given object was deleted, false otherwise.
  def delete(rumpy_id)
    objects = IO.readlines(@file_db, RUMPYDB_SEPARATOR)
    removed_objects = objects.collect do |row|
      row =~ Regexp.new("(\\[#{rumpy_id}\\]\.+#{RUMPYDB_SEPARATOR})", Regexp::MULTILINE)
      $1
    end.compact

    unless removed_objects.empty?
      new_db = objects - removed_objects
      save_db_dump(new_db)
      return true
    else
      return false
    end
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

  def save_db_dump(objects)
    file_open = File.open(@file_db, "w:UTF-8")
    objects.each do |object|
      file_open << object
    end
    file_open.close
  end
end
