# frozen_string_literal: true

require 'kconv'
require 'nokogiri'
require 'open-uri'

module CommonService
  # HTMLをスクレイピングするサービス
  class HtmlScrapingService
    include PostInfo
    def self.get_ogp_info_from_url(url)
      doc = get_html_document(url)
      unless doc.nil?
        site_name = if doc.css('//meta[property="og:site_name"]/@content').empty?
                      nil
                    else
                      site_name_s = doc.css('//meta[property="og:site_name"]/@content').to_s
                      site_name_s.empty? ? nil : site_name_s
                    end
        description = if doc.css('//meta[property="og:description"]/@content').empty?
                        nil
                      else
                        description_s = doc.css('//meta[property="og:description"]/@content').to_s
                        description_s.empty? ? nil : description_s
                      end
        image_url = if doc.css('//meta[property="og:image"]/@content').empty?
                      nil
                    else
                      image_url_s = doc.css('//meta[property="og:image"]/@content').to_s
                      image_url_s.empty? ? nil : image_url_s
                    end
        if !description.nil? || !image_url.nil? || !site_name.nil?
          Ogp.new(
            site_name: site_name,
            description: description,
            image_url: image_url
          )
        end
      end
    end

    def self.get_html_document(url)
      html = open(url, 'r:binary').read
      Nokogiri::HTML.parse(html.toutf8, nil, 'utf-8')
    rescue
      nil
    end
  end
end
