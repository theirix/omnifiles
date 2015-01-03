# encoding: utf-8

require 'rubygems'
require 'digest/md5'
require 'sqlite3'

module OmniFiles

  class Storage

    def initialize db_filename, logger
      @logger = logger
      @db = SQLite3::Database.new(db_filename, :results_as_hash => true)
      if (@db.table_info('files') or []) == []
        Storage.create_schema @db
      end
      @shortener = UrlShortener.new(SecureRandom.hex(8))
    end

    # returns shortened url
    def shorten_file path, filename, mime
      counter = 0
      begin
        hashing = [filename, mime, Digest::MD5.hexdigest(IO.binread(path, 0x100)), counter.to_s].join '|'
        @logger.info "Hashing value " + hashing
        shortened = @shortener.shorten hashing
        counter += 1
        unique_id = @db.get_first_row("SELECT COUNT(shortened) FROM files WHERE shortened = ?", [shortened])[0] == 0
      end until unique_id
      shortened
    end

    def put_file shortened, filename, mime
      @db.execute("INSERT INTO files (original_filename, shortened, mime, accessed)"+
        "VALUES ( ?, ?, ?, 0 )",
        [filename, shortened, mime])
    end

    # returns full url
    def get_file shortened
      data = @db.get_first_row("SELECT * FROM files WHERE shortened = ?", [shortened])
      if data
        @db.execute("UPDATE files SET accessed = accessed + 1 WHERE shortened = ?", [shortened])
      end
      data
    end

  private
    def self.create_schema db
      db.execute <<-SQL
      CREATE TABLE files (
        shortened TEXT NOT NULL,
        original_filename TEXT,
        mime TEXT,
        accessed INTEGER);
      CREATE INDEX shortened_INDEX ON files (shortened);
      SQL
    end
  end

end