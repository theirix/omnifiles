# encoding: utf-8

require 'rubygems'
require 'digest/md5'
require 'bson'
require 'mongo'

module OmniFiles

class Storage
    def initialize mongo_host, mongo_port, mongo_name, logger
        @logger = logger
        client = Mongo::MongoClient.new(mongo_host, mongo_port)
        raise 'No mongo found' unless client
        db = client.db(mongo_name)
        raise 'No mongo db found' unless db
        @logger.info "Mongo collections " + db.collection_names.join(',')
        @coll = db.collection('files')
        raise 'Cannot use collection' unless @coll

        @shortener = UrlShortener.new(SecureRandom.hex(8), 1)
    end

    # returns shortened url
    def shorten_file sample, filename, mime
      counter = 0
      begin
        # filename can be null
        hashing = [filename.to_s, mime, sample, counter.to_s].join '|'
        @logger.info "Hashing value " + hashing
        shortened = @shortener.shorten hashing
        counter += 1
        next if shortened.size < 5
        same_shortened = @coll.find_one({shortened: shortened}, :fields => [ "_id" ])
        raise 'Something goes wrong' if counter > 100
      end while same_shortened
      shortened
    end

    def put_file shortened, filename, mime
        doc = { original_filename: filename, shortened: shortened, mime: mime,
                accessed: { count: 0 }, created: { time: Time.now.utc } }
        res = @coll.insert(doc)
        @logger.info "mongo put result: #{res}"
    end

    # returns full url
    def get_file shortened
        @coll.find_one({shortened: shortened})
    end

    # returns full url and update statistics
    def get_file_and_bump shortened
        data = @coll.find_one({shortened: shortened})
        return nil unless data
        @coll.update({ _id: data["_id"]}, {
            "$inc" =>  { "accessed.count" => 1 },
            "$set" => { "accessed.time" => Time.now.utc } })
        @coll.find_one({ _id: data["_id"]})
    end

    def delete_file shortened
        resp = @coll.remove({shortened: shortened})
        resp['ok'] && resp['n'] > 0
    end

    def enumerate_docs
        @coll.find.each { |doc| yield doc }
    end

end

end
