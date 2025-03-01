RSpec.describe Support::CasePresenter do
  subject(:presenter) { described_class.new(kase) }

  let(:kase) do
    OpenStruct.new(
      state: "open",
      interactions: [OpenStruct.new(created_at: Time.zone.local(2000, 1, 30, 12))],
      agent: OpenStruct.new(first_name: "Ronald", last_name: "McDonald"),
      category: double,
      contact: double,
      enquiry: OpenStruct.new(created_at: Time.zone.local(2000, 1, 30, 12)),
    )
  end

  describe "#state" do
    it "returns an upcase state" do
      expect(presenter.state).to eq("OPEN")
    end
  end

  describe "#agent_name" do
    it "returns the name of the agent that's assigned to the case" do
      expect(presenter.agent_name).to eq("Ronald McDonald")
    end
  end

  describe "#received_at" do
    it "returns the formatted date on which the case was received" do
      expect(presenter.received_at).to eq("30 January 2000")
    end
  end

  describe "#last_updated_at" do
    it "returns the formatted date on which the case was last updated" do
      expect(presenter.last_updated_at).to eq("30 January 2000")
    end
  end

  describe "#interactions" do
    it "returns an array of decorated interactions" do
      expect(presenter.interactions.first).to be_a(Support::InteractionPresenter)
    end
  end

  describe "#contact" do
    it "returns a decorated contact" do
      expect(presenter.contact).to be_a(Support::ContactPresenter)
    end
  end

  describe "#category" do
    it "returns a decorated category" do
      expect(presenter.category).to be_a(Support::CategoryPresenter)
    end
  end
end
