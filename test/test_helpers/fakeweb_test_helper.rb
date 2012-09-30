FakeWeb.allow_net_connect = false

module FakeWeb

  def self.register_githubarchive(datestring, options)
    24.times.each do |hour|
      FakeWeb.register_uri(:get, "http://data.githubarchive.org/#{datestring}-#{hour}.json.gz",
        :content_type => "application/json; charset=UTF-8", :body => TestData.load(options[:file] || 'githubarchive/some_events.json.gz')
      )
    end
  end

end
