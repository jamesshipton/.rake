require 'open-uri'
require 'nokogiri'

desc 'Download all the vimcasts to the current directory'
namespace :benji do
  task :download do
    Benji.episodes.each(&:download)
  end
end

module Benji
  class << self
    def episodes
      episode_data.map do |ed|
        Benji::Episode.new ed.xpath('title').text, ed.xpath('category').text, ed.xpath('enclosure/@url').text
      end
    end

    def get(url)
      open(url, :http_basic_authentication => [ENV['REDUX_USER'], ENV['REDUX_PASS']]).read
    end

    private
    def episode_data
      episodes_feed_doc.xpath('//item[enclosure]')
    end

    def episodes_feed_doc
      Nokogiri::XML get('http://devapi.bbcredux.com/search?pname=Benji+B&sort=date&limit=500&channel=bbcr1')
    end
  end

  Episode = Struct.new(:title, :channel, :url) do
    def download
      Download.fetch(filename, url) do
        Benji.get(url)
      end
    end

    private
    def date
      title.scan(%r([0-9]{4}-[0-9]{2}-[0-9]{2})).first
    end

    def filename
      @filename ||= "#{date}-#{channel}-benji-b.mp3"
    end
  end
end
