# frozen_string_literal: true

# name: discourse-categories-noindex
# about: Añade <meta robots noindex> a los topics y páginas de las categorías seleccionadas
# version: 0.1
# authors: Aldea Pucela
# url: https://github.com/aldeapucela/discourse-categories-noindex
# license: AGPL-3.0-or-later

enabled_site_setting :categories_noindex_enabled

after_initialize do
  builder = lambda do |controller|
    category =
      case controller
      when TopicsController then controller.instance_variable_get(:@topic_view)&.topic&.category
      when ListController   then controller.instance_variable_get(:@category)
      end

    selected = SiteSetting.categories_noindex_category_ids_map

    # ponytail: sube por la cadena de ancestros para cubrir subcategorías a
    # cualquier nivel. Al salir, `category` != nil sólo si hubo coincidencia.
    while category
      break if selected.include?(category.id)
      category = category.parent_category
    end

    category ? '<meta name="robots" content="noindex" data-categories-noindex="1">' : ""
  end

  register_html_builder("server:before-head-close-crawler", &builder)
  register_html_builder("server:before-head-close", &builder)
end
