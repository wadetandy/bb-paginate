app = angular.module('bbPaginate')

app.factory 'StandardPaginator', ['Paginator', 'Page', 'PrevPage', 'NextPage', 'EllipsisPage', (Paginator, Page, PrevPage, NextPage, EllipsisPage) ->
  class StandardPaginator extends Paginator
    windowSize:
      right: 5
      left: 5
      center: 2

    showNextPage: => true
    showPreviousPage: => true

    isCenterWindow: =>
      @pagination.current_page < (@numPages() - (@windowSize['right'] - 2))

    isLeftWindow: =>
      @pagination.current_page <= @windowSize['left'] - 1 ||
        @numPages() <= @windowSize['left']

    buildPages: =>
      @pages.push new PrevPage if @showPreviousPage()
      @buildWindow()
      @pages.push new NextPage if @showNextPage()

    buildWindow: =>
      if @isLeftWindow()
        @leftWindow()
      else if @isCenterWindow()
        @centerWindow()
      else
        @rightWindow()

    addLastPage: =>
      @pages.push new Page(text: @numPages(), number: @numPages())

    addNumericalPages: (window) =>
      for pageNumber in window
        @pages.push new Page(text: pageNumber, number: parseInt(pageNumber))

    addFillerPage: =>
      @pages.push new EllipsisPage

    leftWindow: =>
      cutoff = if @numPages() < @windowSize['left'] then @numPages() else @windowSize['left']
      @addNumericalPages([1..cutoff])
      @addFillerPage() unless @numPages() <= @windowSize['left']
      @addLastPage() unless @numPages() <= @windowSize['left']

    centerWindow: =>
      @pages.push new Page(text: '1', number: 1)
      @addFillerPage()
      @addNumericalPages([@pagination.current_page-@windowSize['center']..@pagination.current_page+@windowSize['center']])
      @addFillerPage()
      @addLastPage()

    rightWindow: =>
      @pages.push new Page(text: '1', number: 1)
      @addFillerPage()
      @addNumericalPages([@numPages()-(@windowSize['right'] - 1)..@numPages()])
]
