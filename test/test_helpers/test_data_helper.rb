class TestData
  def self.load(filename)
    File.read("#{Rails.root}/test/fixtures/#{filename}")
  end

  def self.load_event(type)
    MultiJson.decode(load("events/#{type}.json"))
  end
end
