class TestData
  def self.load(filename)
    File.read("#{Rails.root}/test/fixtures/#{filename}")
  end
end
