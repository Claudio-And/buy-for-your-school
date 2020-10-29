require "rails_helper"

RSpec.describe GetContentfulQuestion do
  let(:contentful_space) { "abc" }
  let(:contentful_access_token) { "123" }

  around do |example|
    ClimateControl.modify CONTENTFUL_SPACE: contentful_space, CONTENTFUL_ACCESS_TOKEN: contentful_access_token do
      example.run
    end
  end

  describe "#call" do
    it "returns the contents of Contentful fixture (for now)" do
      raw_response = File.read("#{Rails.root}/spec/fixtures/contentful/radio-question-example.json")
      fake_contentful_question_response = JSON.parse(raw_response)

      contentful_client = instance_double(Contentful::Client)
      expect(Contentful::Client).to receive(:new)
        .with(space: contentful_space, access_token: contentful_access_token)
        .and_return(contentful_client)

      contentful_response = double(Contentful::Entry, id: "1UjQurSOi5MWkcRuGxdXZS")
      expect(contentful_client).to receive(:entry)
        .with("1UjQurSOi5MWkcRuGxdXZS")
        .and_return(contentful_response)

      expect(contentful_response).to receive(:raw)
        .and_return(fake_contentful_question_response)

      result = described_class.new.call

      expect(result).to eq(fake_contentful_question_response)
    end
  end
end
