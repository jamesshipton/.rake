require 'open-uri'
require 'nokogiri'

desc 'Download all the vimcasts to the current directory'
namespace :vimcasts do
  task :download do
    Vimcasts.episodes.each(&:download)
  end
end

module Vimcasts
  class << self
    def episodes
      episode_data.map do |ed|
        Vimcasts::Episode.new ed.xpath('title').text, ed.xpath('enclosure/@url').text
      end
    end

    def get(url)
      open(url).read
    end

    private
    def episode_data
      episodes_feed_doc.xpath('//item[enclosure]')
    end

    def episodes_feed_doc
      Nokogiri::XML Vimcasts.get('http://vimcasts.org/feeds/ogg')
    end
  end

  Episode = Struct.new(:title, :url) do
    def download
      Download.fetch(filename, url) do
        Vimcasts.get(url)
      end
    end

    private
    def number
      url.scan(%r(/([0-9]+)/)).flatten.first.rjust(3, '0')
    end

    def filename
      @filename ||= "#{number}-#{title.scan(/[a-zA-Z0-9\s]/).join.gsub(/[\s]+/, '-').downcase}.ogg"
    end
  end
end
