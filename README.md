# discourse-categories-noindex

A [Discourse](https://www.discourse.org/) plugin that adds a
`<meta name="robots" content="noindex">` tag to the pages of the categories you
select from the admin panel, keeping them out of search engines.

It applies to:

- Each **topic** page in those categories.
- The category **listing** page (`/c/slug/id`).
- **Subcategories** (at any nesting depth) are included automatically when you
  select the parent category.

The tag is injected server-side, in the view served to crawlers (the *crawler*
layout), which is the one that gets indexed.

## Installation

Add the plugin to `hooks.after_code` in `/var/discourse/containers/app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/aldeapucela/discourse-categories-noindex.git
```

Then rebuild the container:

```bash
cd /var/discourse && ./launcher rebuild app
```

To update the plugin later, just run `./launcher rebuild app` again (it does a
`git pull`).

## Configuration

In **Admin → Settings** (or Admin → Plugins), filter by `categories_noindex`:

- **`categories_noindex_enabled`** — master switch. Enabled by default; the
  plugin does nothing until you select categories.
- **`categories_noindex_category_ids`** — the categories whose content will get
  the `noindex` tag.

No rebuild is needed when changing settings; only when installing or updating
the code.

## How it works

A server-side HTML builder (`server:before-head-close-crawler` and
`server:before-head-close`) resolves the current page's category — for topics
via `@topic_view.topic.category`, for listing pages via `@category` — walks up
the parent chain so subcategories are honored, and emits the `noindex` meta tag
when the category (or an ancestor) is in the selected list.

## Verification

```bash
curl -s -A "Googlebot" https://your-forum/t/<slug>/<id> | grep -i robots
```

The `<meta name="robots" content="noindex">` tag should appear on topics and
listing pages of the selected categories, and be absent everywhere else.
