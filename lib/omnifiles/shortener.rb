# encoding: utf-8

require 'rubygems'
require 'digest/md5'

module OmniFiles

  class UrlShortener
    def initialize salt, bytes_used
      @salt = salt
      @bytes_used = bytes_used
      # base62
      @symbols = (0..9).to_a.map(&:to_s) + ('a'..'z').to_a + ('A'..'Z').to_a
    end

    def shorten url
      dig = Digest::MD5.digest(url+@salt.to_s)
      dig_ints = dig.unpack('N*').first(@bytes_used)
      dig_value = (0...dig_ints.length)
        .map { |i| (dig_ints[i] << ((dig_ints.length-i-1)*32)) }
        .reduce(:+)
      encode dig_value
    end

  private
    def encode(decimal)
      result = ''
      while decimal > 0
        decimal, symbol = decimal.divmod(@symbols.size)
        result << @symbols[symbol]
      end
      result.reverse
    end
  end

end
