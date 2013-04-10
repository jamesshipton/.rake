require 'net/http'
require 'uri'
require 'nokogiri'

desc 'Download all the ruby tapas episodes to the current directory'
namespace :tapas do
  task :download do
    Tapas.episodes.each(&:download)
  end
end

module Tapas
  class << self
    def episodes
      episode_data.map do |ed|
        Episode.new ed.xpath('title').text, ed.xpath('enclosure/@url').text
      end
    end

    def get(url)
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      http.start do |h|
        request = Net::HTTP::Get.new uri.request_uri
        request.basic_auth(ENV['TAPAS_USER'], ENV['TAPAS_PASS'])

        h.request(request).body
      end
    end

    private
    def episode_data
      episodes_feed_doc.xpath('//item[enclosure]')
    end

    def episodes_feed_doc
      Nokogiri::XML Tapas.get('https://rubytapas.dpdcart.com/feed')
    end
  end

  Episode = Struct.new(:title, :url) do
    def download
      Download.fetch(filename, url) do
        Tapas.get(url)
      end
    end

    private
    def filename
      @filename ||= "#{title.scan(/[a-zA-Z0-9\s]/).join.gsub(/[\s]+/, '-').downcase}.mp4"
    end
  end
end
