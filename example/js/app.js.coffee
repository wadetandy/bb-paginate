#= require jquery/jquery
#= require jquery.scrollTo/jquery.scrollTo
#= require angular
#= require underscore/underscore
#= require bb-paginate

app = angular.module('app', ['bbPaginate'])

class MyController
  constructor: (@scope) ->
    @scope.selectPage = @selectPage
    @scope.selectFivePage = @selectFivePage
    @scope.selectThreePage = @selectThreePage

    @scope.search =
      meta:
        pagination:
          total_entries: 200
          current_page: 3
          per_page: 5

    @scope.fivepage =
      total_entries: 25
      current_page: 3
      per_page: 5

    @scope.threepage =
      total_entries: 14
      current_page: 2
      per_page: 5

  selectPage: (pageNumber) =>
    @scope.search.meta.pagination.current_page = pageNumber

  selectFivePage: (pageNumber) =>
    @scope.fivepage.current_page = pageNumber

  selectThreePage: (pageNumber) =>
    @scope.threepage.current_page = pageNumber

app.controller 'myCtrl', ['$scope', MyController]

app.directive 'paginateBeacon', ($http) ->
  require: 'bbPaginate'
  link: ($scope, $element, $attrs, bbPaginateCtrl) ->
    bbPaginateCtrl.onPageSelect (pageNum) ->
      $http.get("/page_changed?page=#{pageNum}")



