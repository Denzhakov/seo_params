# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Alexa

    def initialize(url)
      @url = url
      @response = Nokogiri::HTML(open("http://xml.alexa.com/data?cli=10&dat=nsa&ver=quirk-searchstatus&url=#{@url}"))
    end

    def rank
      begin
        rank = @response.css("popularity").attr("text").content().to_i
      rescue
        rank = nil
      end
      rank
    end

    def dmoz
      doc = Nokogiri::HTML(open("http://www.dmoz.org/search?q=#{@url}"))
      index = doc.css('.site').text.length > 0
    end
  end

end
