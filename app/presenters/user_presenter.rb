class UserPresenter < BasePresenter
  # @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end

  # @return [Array<JourneyPresenter>]
  def journeys
    super.map { |journey| JourneyPresenter.new(journey) }
  end
end
