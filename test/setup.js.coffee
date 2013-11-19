window.rspecHelpers = =>
  @let_ = (name, f) =>
    beforeEach -> this[name] = f()

window.basicTestSetup = (moduleName) ->
  #$scope   = null
  #compile  = null
  #$timeout = null

  #@compile_and_attach = (html) ->
    #element = compile(html)
    #$('body').append(element)
    #element

  # you need to indicate your module in a test
  newScope = (scope) ->
    _scope = null
    inject (_$rootScope_) ->
      _scope = _$rootScope_
    for key, val of scope
      _scope[key] = val
    _scope

  compile = (test, template, scope) ->
    inject((_$compile_, _$rootScope_) ->
      $compile = _$compile_
      $rootScope = _$rootScope_

      compiled = $compile(template)(scope)
      test.compiled = compiled
      $rootScope.$digest()
    )

  s = newScope(@scope)
  compile(@, @template, s)
