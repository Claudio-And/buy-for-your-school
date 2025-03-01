class ContentfulEntryPresenter < SimpleDelegator
  # return [String]
  def contentful_url
    "https://app.contentful.com/spaces/#{space.id}/environments/#{environment.id}/entries/#{id}"
  end

  # return [String]
  def updated_at
    super.strftime("%e %B %Y - %I:%M:%S %P")
  end
end
