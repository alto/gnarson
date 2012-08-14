namespace :gnarson do
  namespace :events do

    task :update => :environment do
      Tasks::EventLoader.update_events
    end

    task :reset => :environment do
      Tasks::EventLoader.reset_events
    end

  end
end
