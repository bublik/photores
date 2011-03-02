#!/usr/bin/env ruby

require 'rubygems'
require 'mysql'
require 'postgres'


class MysqlReader
  class Field
  end

  class Table
    attr_reader :name

    def initialize(mysql, name)
      @mysql = mysql
      @name = name
    end

    @@types = %w(tiny enum decimal short long float double null timestamp longlong int24 date time datetime year set blob string var_string char).inject({}) do |list, type|
      list[eval("Mysql::Field::TYPE_#{type.upcase}")] = type
      list
    end

    @@types[246] = "decimal"

    def columns
      @columns ||= load_columns
    end

    def load_columns
      result = @mysql.list_fields(name)
      fields = result.fetch_fields.map do |field|
        desc = {
          :name => field.name,
          :table_name => field.table,
          :default => field.def,
          :type => @@types[field.type] || field.type,
          :length => field.length,
          :max_length => field.max_length,
          :flags => field.flags,
          :decimals => field.decimals ? field.decimals > 12 ? 12 : field.decimals : nil,
          :null => !field.is_not_null?,
          :numeric => field.is_num?,
          :primary_key => field.is_pri_key?
        }
        if field.is_pri_key?
          @mysql.query("SELECT max(`#{field.name}`) FROM `#{name}`") do |res|
            desc[:maxval] = res.fetch_row[0].to_i
          end
        end
        desc
      end
      result.free
      fields
    end


    def indexes
      @indexes ||= load_indexes
    end

    def load_indexes
      indexes = []
      @mysql.query("SHOW CREATE TABLE `#{name}`") do |result|
        explain = result.fetch_row[1]
        explain.split(/\n/).each do |line|
          next unless line =~ / KEY /
          index = {}
          if match_data = /KEY `(\w+)` \((.*)\)/.match(line)
            index[:name] = match_data[1]
            index[:columns] = match_data[2].split(",").map {|col| col.strip.gsub(/`/, "")}
            index[:unique] = true if line =~ /UNIQUE/
          elsif match_data = /PRIMARY KEY .*\((.*)\)/.match(line)
            index[:primary] = true
            index[:columns] = match_data[1].split(",").map {|col| col.strip.gsub(/`/, "")}
          end
          indexes << index
        end
      end
      indexes
    end

  end

  def initialize(host = nil, user = nil, passwd = nil, db = nil, sock = nil, flag = nil)
    @mysql = Mysql.connect(host, user, passwd, db, sock, flag)
    @mysql.query "SET NAMES utf8"
  end

  def tables
    @tables ||= @mysql.list_tables.map {|table| Table.new(@mysql, table)}
  end

  def paginated_read(table, page_size)
    count = nil
    @mysql.query("SELECT count(*) FROM #{table.name}") do |res|
      count = res.fetch_row[0].to_i
    end
    return if count < 1
    statement = @mysql.prepare("SELECT #{table.columns.map{|c| "`"+c[:name]+"`"}.join(", ")} FROM `#{table.name}` LIMIT ?,?")
    0.upto((count + page_size)/page_size) do |i|
      statement.execute(i*page_size, page_size)
      while row = statement.fetch
        yield(row)
      end
    end
  end
end

class Writer
end

class PostgresFileWriter < Writer
  def initialize(file)
    @f = File.open(file, "w+")
    @f << <<-EOF
-- MySQL 2 PostgreSQL dump\n
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;

    EOF
  end

  def write_table(table)
    primary_keys = []
    primary_key = nil
    maxval = nil

    columns = table.columns.map do |column|
      if column[:primary_key]
        if column[:name] == "id"
          primary_key = column[:name]
          maxval = column[:maxval] < 1 ? 1 : column[:maxval] + 1
        end
        primary_keys << column[:name]
      end
      "  " + column_description(column)
    end.join(",\n")

    if primary_key

      @f << <<-EOF
--
-- Name: #{table.name}_#{primary_key}_seq; Type: SEQUENCE; Schema: public
--

DROP SEQUENCE IF EXISTS #{table.name}_#{primary_key}_seq CASCADE;

CREATE SEQUENCE #{table.name}_#{primary_key}_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


SELECT pg_catalog.setval('#{table.name}_#{primary_key}_seq', #{maxval}, true);

      EOF
    end

    @f << <<-EOF
-- Table: #{table.name}

-- DROP TABLE #{table.name};
DROP TABLE IF EXISTS #{PGconn.quote_ident(table.name)} CASCADE;

CREATE TABLE #{PGconn.quote_ident(table.name)} (
    EOF

    @f << columns

    if primary_index = table.indexes.find {|index| index[:primary]}
      @f << ",\n  CONSTRAINT #{table.name}_pkey PRIMARY KEY(#{primary_index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")})"
    end

    @f << <<-EOF
\n)
WITH (OIDS=FALSE);

    EOF

    table.indexes.each do |index|
      next if index[:primary]
      unique = index[:unique] ? "UNIQUE " : nil
      @f << <<-EOF
DROP INDEX IF EXISTS #{PGconn.quote_ident(index[:name])} CASCADE;
CREATE #{unique}INDEX #{PGconn.quote_ident(index[:name])} ON #{PGconn.quote_ident(table.name)} (#{index[:columns].map {|col| PGconn.quote_ident(col)}.join(", ")});
      EOF
    end

  end

  def column_description(column)
    "#{PGconn.quote_ident(column[:name])} #{column_type(column)}"
  end

  def column_type(column)
    case
    when column[:primary_key] && column[:name] == "id"
      "integer DEFAULT nextval('#{column[:table_name]}_#{column[:name]}_seq'::regclass) NOT NULL"
    else
      default = column[:default] ? " DEFAULT #{column[:default] == nil ? 'NULL' : "'"+column[:default]+"'"}" : nil
      null = column[:null] ? "" : " NOT NULL"
      type =
        case column[:type]
      when "var_string"
        default = default + "::character varying" if default
        "character varying(#{column[:length]})"
      when "long"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "bigint"
      when "longlong"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "bigint"
      when "datetime"
        default = nil
        "timestamp without time zone"
      when "date"
        default = nil
        "date"
      when "char"
        if default
          default = " DEFAULT #{column[:default].to_i == 1 ? 'true' : 'false'}"
        end
        "boolean"
      when "blob"
        "text"
      when "float"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "numeric(#{column[:length] + column[:decimals]}, #{column[:decimals]})"
      when "decimal"
        default = " DEFAULT #{column[:default].nil? ? 'NULL' : column[:default]}" if default
        "numeric(#{column[:length] + column[:decimals]}, #{column[:decimals]})"
      else
        puts column.inspect
        column[:type].inspect
      end
      "#{type}#{default}#{null}"
    end
  end

  def write_contents(table, reader)
    @f << <<-EOF
--
-- Data for Name: #{table.name}; Type: TABLE DATA; Schema: public
--

COPY #{table.name} (#{table.columns.map {|column| PGconn.quote_ident(column[:name])}.join(", ")}) FROM stdin;
    EOF

    reader.paginated_read(table, 1000) do |row|
      line = []
      table.columns.each_with_index do |column, index|
        row[index] = row[index].to_s if row[index].is_a?(Mysql::Time)
        if column[:type] == "char"
          row[index] = row[index] == 1 ? 't' : row[index] == 0 ? 'f' : row[index]
        end
        row[index] = row[index].gsub(/\\/, '\\\\\\').gsub(/\n/,'\n').gsub(/\t/,'\t').gsub(/\r/,'\r') if row[index].is_a?(String)
        row[index] = '\N' if !row[index]
        row[index]
      end
      @f << row.join("\t") + "\n"
    end
    @f << "\\.\n\n\n"
  end

  def close
    @f.close
  end
end

class Converter
  attr_reader :reader, :writer

  def initialize(reader, writer)
    @reader = reader
    @writer = writer
  end

  def convert
    reader.tables.each do |table|
      writer.write_table(table)
    end

    reader.tables.each do |table|
      writer.write_contents(table, reader)
    end
    writer.close
  end
end

if ARGV.eql?([])
  puts 'mysql2postgre.rb mysql_dbname password '
  return
else
  #  puts 'pas'+ARGV[1]
  #  puts 'user'+ARGV[2]
  #  puts 'db'+ARGV[0]
  #  puts 'out_file'+ARGV[3]
end
reader = MysqlReader.new('localhost', ARGV[2], ARGV[1], ARGV[0])
writer = PostgresFileWriter.new(ARGV[3] || "output.sql")
converter = Converter.new(reader, writer)
converter.convert
