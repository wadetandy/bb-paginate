app = angular.module('bbPaginate')

app.factory 'Page', ->
  class Page
    disabled: false
    active: false
    text: ''
    number: null

    constructor: (attrs) ->
      angular.extend(@, attrs)

    # Disable the currently selected page
    reset: (currentPage, lastPage) =>
      @active = (currentPage == @number) if @number

    listItemClasses: ->
      classes = []

      classes.push 'active' if @active
      classes.push 'disabled' if @disabled
      classes.push @cssClass if @cssClass

      classes.join ' '


app.factory 'PrevPage', ['Page', (Page) ->
  class PrevPage extends Page
    cssClass: 'previous-page'
    text: '<'

    reset: (currentPage, lastPage) =>
      @number   = currentPage - 1
      @disabled = (currentPage == 1)
]

app.factory 'EllipsisPage', ['Page', (Page) ->
  class EllipsisPage extends Page
    cssClass: 'ellipsis'
    disabled: true
    text: '. . .'

    reset: ->
      null
]

app.factory 'NextPage', ['Page', (Page) ->
  class NextPage extends Page
    cssClass: 'next-page'
    text: '>'

    reset: (currentPage, lastPage) =>
      @number   = currentPage + 1
      @disabled = (currentPage == lastPage)
]

app.factory 'Paginator', ->
  class Paginator
    pages: []

    constructor: (@pagination) ->
      unless @isValid()
        throw "Invalid Pagination. Must have attributes current_page, per_page, and total_entries"

    isValid: =>
      _.all ['current_page', 'per_page', 'total_entries'], (attr) =>
        @pagination[attr] != undefined

    reset: =>
      @pages = []
      @buildPages()
      _.each @pages, (page) => page.reset(parseInt(@pagination.current_page), @numPages())

    buildPages: =>
      throw "#buildPages must be implemented in subclass"

    numPages: =>
      Math.ceil(@pagination.total_entries / @pagination.per_page)

class PaginationController
  constructor: (@scope, @attrs) ->
    @scope.selectPage = @selectPage
    @_pageSelectHandlers = []

  selectPage: (page) =>
    return if page.disabled

    @scope.pagination.current_page = page.number
    @scope.onPageSelect(pageNumber: page.number)

    _(@_pageSelectHandlers).each (fn) =>
      fn(page.number)

  onPageSelect: (fn) =>
    @_pageSelectHandlers.push(fn)

app.directive 'bbPaginate', ['$injector', ($injector) ->
  template: """
    <ul>
      <li ng-repeat="page in paginator.pages" ng-class="page.listItemClasses()">
        <a href="" ng-click="selectPage(page)">{{page.text}}</a>
      </li>
    </ul>
  """
  controller: ['$scope', '$attrs', PaginationController]
  scope:
    onPageSelect: '&'
    pagination: "=bbPaginate"
  link: ($scope, $element, $attrs) ->
    paginator        = $attrs.paginator || 'StandardPaginator'
    klass            = $injector.get(paginator)
    $scope.paginator = new klass($scope.pagination)

    $element.addClass('pagination') unless $element.hasClass('pagination')

    $scope.$watch 'pagination', $scope.paginator.reset, true
]

app.directive 'bbPaginateScrollTo', ->
  require: 'bbPaginate'
  link: ($scope, $element, $attrs, bbPaginateCtrl) ->
    bbPaginateCtrl.onPageSelect (page) ->
      $.scrollTo($attrs.bbPaginateScrollTo, 500)
