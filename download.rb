module Download
  class << self
    def fetch(filename, url, &block)
      tries = 0

      begin
        tries += 0
          if File.size? filename
            puts "Already downloaded #{filename}"
          else
            File.open(filename, 'w:binary') do |f|
              puts "Downloading #{url} to #{f.path}"
              f << yield
            end
          end
      rescue Timeout::Error
        if tries < 5
          puts "problem downloading #{url}....retrying"
          retry
        else
          puts "problem downloading #{url}....giving up"
        end
      end
    end
  end
end
