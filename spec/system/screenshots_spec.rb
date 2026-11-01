# frozen_string_literal: true

# README screenshots. Run by the "Screenshots" workflow, which commits the PNGs
# to docs/screenshots/. Skipped in regular CI.
RSpec.describe "Screenshots" do
  GISTS = {
    "Running your own Bitcoin node" =>
      "What a home node needs, what it costs to run and what it verifies for you.",
    "Lightning channels, explained without jargon" =>
      "How channels move payments off-chain, and when opening one is worth the fee.",
    "Self-custody checklist for new members" =>
      "Seed storage, test transactions and the mistakes that cost people the most.",
  }.freeze

  fab!(:author) { Fabricate(:user, username: "satoshi") }
  fab!(:category) { Fabricate(:category, name: "Bitcoin") }

  before do
    skip "set SCREENSHOTS=1 to take screenshots" unless ENV["SCREENSHOTS"]

    SystemThemesManager.sync_theme!("horizon")
    horizon = Theme.horizon_theme
    horizon.update!(enabled: true, user_selectable: true)
    SiteSetting.default_theme_id = horizon.id
    upload_theme_component(parent_theme_id: horizon.id)

    # A sample gist, so the layout can be shown without an LLM behind discourse-ai.
    allow_any_instance_of(TopicListItemSerializer).to receive(:ai_topic_gist) do |serializer|
      GISTS[serializer.object.title]
    end
    allow_any_instance_of(TopicListItemSerializer).to receive(:include_ai_topic_gist?) do |serializer|
      GISTS.key?(serializer.object.title)
    end

    [*GISTS.keys, "What changed in the last soft fork"].each do |title|
      Fabricate(:topic_with_op, title: title, category: category, user: author)
    end
  end

  def save(name)
    path = Rails.root.join("tmp/capybara/screenshots/#{name}.png")
    FileUtils.mkdir_p(path.dirname)
    page.driver.with_playwright_page { |pw| pw.screenshot(path: path.to_s) }
  end

  it "shows gists on desktop" do
    resize_window(width: 1280, height: 900) do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".horizon-ai-gist", count: 3)
      save("gists-desktop")
    end
  end

  it "shows gists on mobile" do
    resize_window(width: 390, height: 844) do
      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css(".horizon-ai-gist", minimum: 1)
      save("gists-mobile")
    end
  end
end
