## For Standard Pagination:

```html
<div bb-paginate="paginationData"
on-page-select="myFunctionOnScope(pageNumber)" />
```

Where paginationData MUST have attributes:
* `current_page`
* `total_entries`
* `per_page`

## For Terminal Pagination:

use `TerminalPaginator`:

```html
<div bb-paginate="paginationData"
    on-page-select="myFunctionOnScope(pageNumber)"
    paginator="TerminalPagination"
/>
```

## Customizing:

### Custom Paginator
Supply your own Paginator. This should subclass `Paginator`.

`StandardPaginator`, already a descendent of `Paginator`, can probably
be easily overriden for most use cases.

#### Example:

Say you don't want to show prev/next arrows, and the initial number of
pages
('left' window) should be 10 instead of 5):

```coffeescript
app.factory 'MyCustomPaginator', ['StandardPaginator', (StandardPaginator) ->
  class MyCustomPaginator extends StandardPaginator
    constructor: (args...) ->
      super
      @windowSize.left = 10

    showNextPage: => false
    showPrevPage: => false
]
```

```html
<div bb-paginate="paginationData" paginator="MyCustomPaginator" />
```

See the source of `TerminalPaginator` for another example.

### Controller API

BbPaginate also features a controller that can be leveraged by other components
that wish to extend or hook into the basic functionality.

#### onPageSelect()

```coffeescript
app.directive 'paginateBeacon', ($http) ->
  require: 'bbPaginate'
  link: ($scope, $element, $attrs, bbPaginateCtrl) ->
    bbPaginateCtrl.onPageSelect (pageNum) ->
      $http.get("/page_changed?page=#{pageNum}")
```

```html
<div bb-paginate="paginationData" paginate-beacon />
```
