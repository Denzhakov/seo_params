# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Yahoo

    def initialize(url)
      @url = url
      @response = open("http://search.yahoo.com/search?p=site:#{url}").read
      #7,330 results
    end

    def yahoo_pages
      matches = @response.match /[\d,]+?\sresults/
      if matches.nil?
        0
      else
        matches[1].gsub(',', '').to_i
      end
    end

  end

end
