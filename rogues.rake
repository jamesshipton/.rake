require 'open-uri'
require 'nokogiri'

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

    private
    def episode_links
      episodes_guide_doc.css('.format_text>p>a')
    end

    def episodes_guide_doc
      Nokogiri::HTML open('http://rubyrogues.com/episode-guide/')
    end
  end

  Episode = Struct.new(:page_link, :name) do
    def download
      if downloaded?
        puts "Already downloaded #{mp3_filename}"
      else
        File.open(mp3_filename, 'w:binary') do |f|
          puts "Downloading #{mp3_link} to #{f.path}"
          f << open(mp3_link).read
        end
      end
    end

    private
    def downloaded?
      File.size? mp3_filename
    end

    def mp3_link
      @mp3_link ||= episode_doc.css('[title=Download]').first['href']
    end

    def mp3_filename
      @mp3_filename ||= "#{name.scan(/[a-zA-Z0-9\s]/).join.gsub(/[\s]+/, '-').downcase}.mp3"
    end

    def episode_doc
      Nokogiri::HTML open(page_link)
    end
  end
end
