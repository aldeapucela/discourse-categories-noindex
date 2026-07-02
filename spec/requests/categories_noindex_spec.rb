# frozen_string_literal: true

RSpec.describe "categories-noindex" do
  fab!(:parent_cat) { Fabricate(:category) }
  fab!(:sub_cat) { Fabricate(:category, parent_category: parent_cat) }
  fab!(:other_cat) { Fabricate(:category) }
  fab!(:noindex_post) { Fabricate(:post, topic: Fabricate(:topic, category: parent_cat)) }
  fab!(:sub_post) { Fabricate(:post, topic: Fabricate(:topic, category: sub_cat)) }
  fab!(:other_post) { Fabricate(:post, topic: Fabricate(:topic, category: other_cat)) }

  let(:tag) { 'content="noindex" data-categories-noindex="1"' }

  before do
    SiteSetting.categories_noindex_enabled = true
    SiteSetting.categories_noindex_category_ids = parent_cat.id.to_s
  end

  def crawl(path)
    get path, headers: { "HTTP_USER_AGENT" => "Googlebot/2.1 (+http://www.google.com/bot.html)" }
  end

  it "marca los topics de la categoría seleccionada" do
    crawl(noindex_post.topic.relative_url)
    expect(response.body).to include(tag)
  end

  it "hereda a los topics de una subcategoría" do
    crawl(sub_post.topic.relative_url)
    expect(response.body).to include(tag)
  end

  it "marca la página de listado de la categoría" do
    crawl("/c/#{parent_cat.slug}/#{parent_cat.id}")
    expect(response.body).to include(tag)
  end

  it "NO marca los topics de otras categorías" do
    crawl(other_post.topic.relative_url)
    expect(response.body).not_to include('content="noindex"')
  end
end
