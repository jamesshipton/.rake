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

    private
    def episode_data
      episodes_feed_doc.xpath('//item[enclosure]')
    end

    def episodes_feed_doc
      Nokogiri::XML open('http://vimcasts.org/feeds/ogg')
    end
  end

  Episode = Struct.new(:title, :ogg_url) do
    def download
      tries = 0

      begin
        tries += 0
          if downloaded?
            puts "Already downloaded #{ogg_filename}"
          else
            File.open(ogg_filename, 'w:binary') do |f|
              puts "Downloading #{ogg_url} to #{f.path}"
              f << open(ogg_url).read
            end
          end
      rescue Timeout::Error
        if tries < 5
          puts "problem downloading #{ogg_url}....retrying"
          retry
        else
          puts "problem downloading #{ogg_url}....giving up"
        end
      end
    end

    private
    def downloaded?
      File.size? ogg_filename
    end

    def number
      ogg_url.scan(%r(/([0-9]+)/)).flatten.first.rjust(3, '0')
    end

    def ogg_filename
      @ogg_filename ||= "#{number}-#{title.scan(/[a-zA-Z0-9\s]/).join.gsub(/[\s]+/, '-').downcase}.ogg"
    end
  end
end
