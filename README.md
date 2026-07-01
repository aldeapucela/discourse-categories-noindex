# categories-noindex

Plugin de [Discourse](https://www.discourse.org/) que añade la etiqueta
`<meta name="robots" content="noindex">` en las páginas de las categorías que
elijas desde la administración, para mantenerlas fuera de los buscadores.

Afecta a:

- Las páginas de cada **topic** de esas categorías.
- La página de **listado** de la categoría (`/c/slug/id`).
- Las **subcategorías** (a cualquier nivel de anidamiento) se incluyen
  automáticamente si seleccionas la categoría padre.

La etiqueta se inserta en el servidor, en la vista que reciben los buscadores
(layout *crawler*), que es la que se indexa.

## Instalación

Como es un repositorio **privado**, el `git clone` necesita autenticación
(token o deploy key). En `/var/discourse/containers/app.yml`, dentro de
`hooks.after_code`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://<TOKEN>@github.com/aldeapucela/discourse-categories-noindex.git
```

Y reconstruye el contenedor:

```bash
cd /var/discourse && ./launcher rebuild app
```

Para actualizar el plugin más adelante basta con volver a ejecutar
`./launcher rebuild app` (hace `git pull`).

## Configuración

En **Admin → Ajustes** (o Admin → Plugins), filtra por `categories_noindex`:

- **`categories_noindex_enabled`** — interruptor maestro. Activado por defecto;
  el plugin no hace nada hasta que seleccionas categorías.
- **`categories_noindex_category_ids`** — selector de las categorías cuyos
  contenidos llevarán `noindex`.

No hace falta reconstruir al cambiar ajustes; solo al instalar o actualizar código.

## Comprobación

```bash
curl -s -A "Googlebot" https://tu-foro/t/<slug>/<id> | grep -i robots
```

Debe aparecer `<meta name="robots" content="noindex">` en los topics y páginas
de las categorías seleccionadas, y no aparecer en el resto.
