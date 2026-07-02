import { apiInitializer } from "discourse/lib/api";

// La etiqueta noindex la inyecta el servidor en la carga inicial (es lo que ven
// los crawlers). Pero Discourse es una SPA: al navegar por clics no se vuelve a
// renderizar el <head>, así que la etiqueta del servidor se queda "pegada" y
// arrastra el noindex a páginas que no lo deberían tener. Aquí la sincronizamos
// en cada cambio de página, replicando la lógica del servidor.
export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");
  const siteSettings = api.container.lookup("service:site-settings");
  const router = api.container.lookup("service:router");

  const selected = (siteSettings.categories_noindex_category_ids || "")
    .toString()
    .split("|")
    .filter(Boolean)
    .map((id) => parseInt(id, 10));

  // ¿La categoría o alguno de sus ancestros está en la lista? (cubre subcategorías)
  function matches(categoryId) {
    if (!siteSettings.categories_noindex_enabled || !categoryId) {
      return false;
    }
    let cat = site.categories?.find((c) => c.id === categoryId);
    while (cat) {
      if (selected.includes(cat.id)) {
        return true;
      }
      cat = cat.parent_category_id
        ? site.categories.find((c) => c.id === cat.parent_category_id)
        : null;
    }
    return false;
  }

  function currentCategoryId() {
    const name = router.currentRouteName || "";
    if (name.startsWith("topic")) {
      return api.container.lookup("controller:topic")?.model?.category_id;
    }
    if (name.startsWith("discovery.")) {
      // páginas de listado /c/...
      return api.container.lookup("service:discovery")?.category?.id;
    }
    return null;
  }

  api.onPageChange(() => {
    const tag = document.head.querySelector(
      'meta[name="robots"][data-categories-noindex]'
    );
    if (matches(currentCategoryId())) {
      if (!tag) {
        const meta = document.createElement("meta");
        meta.name = "robots";
        meta.content = "noindex";
        meta.setAttribute("data-categories-noindex", "1");
        document.head.appendChild(meta);
      }
    } else if (tag) {
      tag.remove();
    }
  });
});
