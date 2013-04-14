module Benji
  class << self
    def episodes(prog_name)
      episode_data(prog_name).map do |ed|
        Episode.new ed.xpath('title').text, ed.xpath('category').text, ed.xpath('enclosure/@url').text
      end
    end

    def get(url)
      open(url, :http_basic_authentication => [ENV['REDUX_USER'], ENV['REDUX_PASS']]).read
    end

    private
    def episode_data(prog_name)
      episodes_feed_doc(prog_name).xpath('//item[enclosure]')
    end

    def episodes_feed_doc(prog_name)
      Nokogiri::XML get("http://devapi.bbcredux.com/search?pname=#{prog_name}&sort=date&limit=500")
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
end
