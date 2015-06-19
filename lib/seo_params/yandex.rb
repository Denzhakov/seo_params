# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Yandex

    def initialize(url)
      url.match(/^(https?:\/\/)/) ? @url = url : @url = 'http://' + url
      @host = URI(@url).host
    end


    def tic
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      tic = query.xpath('//@value')
      tic.to_s.to_i
    end

    def yaca
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      query.xpath('//topic').any?
    end

    def news
      doc   = Nokogiri::HTML(open("https://news.yandex.ru/yandsearch?rptval=on&rpt=smisearch&grhow=clutop&text=#{@url}"))
      index = 0
      if doc.css('.total').length > 0
        index = doc.css('.total dd').text()[/\d+/].to_i
      end

      index > 0
    end

    def yandex_pages
      pages = ask_yandex(@url)
      (pages.is_a? String) ? (@url = pages; pages = ask_yandex(pages); ) : pages
      pages
    end

    def yandex_position(user, key, lr, keywords, num)

      uri = URI.parse "http://xmlsearch.yandex.ru/xmlsearch?user=#{user}&key=#{key}&lr=#{lr}"

      h = Hash.new

      EventMachine.synchrony do
        EM::Synchrony::FiberIterator.new(keywords, keywords.size).each do |keyword|
          request = EventMachine::HttpRequest.new(uri)
          response = request.post(:body => xml_request(keyword, num))

          result = parse_results(response)

          (result.is_a? Hash) ? (h.merge! result) : (h[keyword] = result)

        end

        EventMachine.stop
      end

      h

    end


    private
      def ask_yandex(url)

        doc = Nokogiri::HTML(open("http://webmaster.yandex.ua/check.xml?hostname=#{url}"))

        if doc.css('div.error-message').length > 0

          index = doc.css('div.error-message').children().children()[1].text()[0..-3].lstrip

        else

          index = doc.css('div.header div').text()[/\d+/].to_i

        end

        index
      end

      def xml_request keyword, num
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
          <request>
            <query>#{keyword}</query>
            <groupings>
              <groupby attr=\"d\" mode=\"deep\" groups-on-page=\"#{num}\"  docs-in-group=\"1\" />
            </groupings>
          </request>"
      end

      def parse_results response
        h_err = Hash.new
        pos = 0
        i = 1
        doc = Nokogiri::XML(response.response)

        if doc.xpath('//error')
          doc.xpath("//error").map do |err|
            h_err["error_code"] = err['code']
            h_err["error_message"] = err.text()
          end
        end


        doc.xpath('//url').each do |link|
          if link.to_s[/#{Regexp.escape(@host)}/]
            pos = i
            break
          else
            i = i + 1
          end
        end


        (h_err.length != 0) ? h_err : pos

      end
  end

end
