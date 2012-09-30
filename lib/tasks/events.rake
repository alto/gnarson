namespace :gnarson do
  namespace :events do

    desc "load events from GitHub for the last couple of days"
    task :update => :environment do
      Tasks::EventLoader.update_events
    end

    desc "reset all loaded events for the last couple of days"
    task :reset => :environment do
      Tasks::EventLoader.reset_events
    end

  end
end
