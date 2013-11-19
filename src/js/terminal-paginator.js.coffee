app = angular.module('bbPaginate')

app.factory 'TerminalPaginator', ['StandardPaginator', 'Page', (StandardPaginator, Page) ->
  class TerminalPaginator extends StandardPaginator
    buildWindow: =>
      current = @pagination.current_page
      @pages.push new Page(text: current, number: current)
]
