require 'open-uri'
require 'nokogiri'

require_relative 'download'

desc 'Download all the ruby rogues podcasts to the current directory'
namespace :rogues do
  task :download do
    Rogues.episodes.each(&:download)
  end
end

module Rogues
  class << self
    def episodes
      episode_links.map do |el|
        Rogues::Episode.new el['href'], el.text
      end
    end

    def get(url)
      open(url).read
    end

    private
    def episode_links
      episodes_guide_doc.css('.format_text>p>a')
    end

    def episodes_guide_doc
      Nokogiri::HTML Rogues.get('http://rubyrogues.com/episode-guide/')
    end
  end

  Episode = Struct.new(:page_link, :name) do
    def download
      Download.fetch(filename, url) do
        Rogues.get(url)
      end
    end

    private
    def url
      @url ||= episode_doc.css('[title=Download]').first['href']
    end

    def filename
      @filename ||= "#{name.scan(/[a-zA-Z0-9\s]/).join.gsub(/[\s]+/, '-').downcase}.mp3"
    end

    def episode_doc
      Nokogiri::HTML Rogues.get(page_link)
    end
  end
end
