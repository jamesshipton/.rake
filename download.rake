require_relative 'lib/download'

namespace :download do
  desc 'Download all the ruby tapas episodes to the current directory'
  task :tapas do
    Tapas.episodes.each(&:download)
  end

  desc 'Download all the ruby rogues podcasts to the current directory'
  task :rogues do
    Rogues.episodes.each(&:download)
  end

  desc 'Download all the vimcasts to the current directory'
  task :vimcasts do
    Vimcasts.episodes.each(&:download)
  end
end
