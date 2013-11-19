describe 'pagination directive', ->
  beforeEach(module('bbPaginate'))
  # rspecHelpers()

  beforeEach ->
    @template = """
      <div bb-paginate="pagination">
      </div>
    """

    @scope =
      pagination:
        current_page: 3
        total_entries: 200
        per_page: 5

  compile = ->
    basicTestSetup.apply @, ['bgPaginate']

  pageAt = (index) =>
    test.compiled.find("ul li:nth-child(#{index})")

  linkAt = (index) =>
    test.compiled.find("ul li:nth-child(#{index}) a")

  test = null
  beforeEach ->
    test = @

  describe "Basic Functionality", ->
    beforeEach ->
      compile.apply @

    it "adds the .pagination class to the base element", ->
      expect(@compiled).toHaveClass('pagination')

  describe "StandardPagination", ->
    describe "when given invalid pagination data", ->
      beforeEach ->
        @scope =
          pagination:
            foo: 'bar'

      it "should throw a validation error", ->
        compilation = => compile.apply @
        expect(compilation).toThrow()

    describe "when the number of pages is > 5", ->
      describe "and the selected page is < 5", ->

        it "creates the correct number of pages", ->
          compile.apply @
          expect(@compiled.find('ul li a').length).toEqual(9)

        describe "and the selected page is 1", ->
          beforeEach ->
            @scope.pagination.current_page = 1
            compile.apply @

          it "disables the 'prev' button", ->
            expect(@compiled.find('ul li:first-child')).toHaveClass('disabled')

          it "sets the first button to active", ->
            expect(@compiled.find('ul li:nth-child(2)')).toHaveClass('active')

          it "doesn't affect remaining buttons", ->
            expect(@compiled.find('ul li:gt(1)')).not.toHaveClass('active')

      describe "and the page is 4", ->
        beforeEach ->
          @scope.pagination.current_page = 4

        it "should not increase the number of pages", ->
          compile.apply @
          expect(@compiled.find('ul li a').length).toEqual(9)

      describe "and the page is 5", ->
        beforeEach ->
          @scope.pagination.current_page = 5

        it "should use the center window", ->
          compile.apply @
          expect(@compiled.find('ul li a').length).toEqual(11)
          pageExpectations = [1, '. . .', 3, 4, 5, 6, 7, '. . .']

          for expectation, pageNum in pageExpectations
            expect(pageAt(pageNum + 2)).toHaveText(expectation)

        it "should not disable the 'next' page", ->
          compile.apply @
          expect(pageAt(11)).not.toHaveClass('disabled')

        it "should activate page 5", ->
          compile.apply @
          expect(pageAt(6)).toHaveClass('active')

      describe "and the selected page is > 5 and < (total pages-5)", ->

        beforeEach ->
          @scope.pagination.current_page = 6

        it "creates the correct number of pages", ->
          compile.apply @
          expect(@compiled.find('ul li a').length).toEqual(11)

        it "starts with a 'prev' page", ->
          compile.apply @
          expect(@compiled.find('ul li:first-child')).toHaveClass('previous-page')

        it "shows the first page", ->
          compile.apply @
          expect(linkAt(2)).toHaveText('1')

        it "has an ellipsis after the first page", ->
          compile.apply @
          expect(pageAt(3)).toHaveClass('ellipsis')
          expect(linkAt(3)).toHaveText('. . .')

        it "contains the 2 pages before the current page", ->
          compile.apply @
          expect(linkAt(4)).toHaveText('4')
          expect(linkAt(5)).toHaveText('5')

        it "shows the current page, activated", ->
          compile.apply @
          expect(pageAt(6)).toHaveClass('active')
          expect(linkAt(6)).toHaveText('6')

        it "contains the 2 pages after the current page", ->
          compile.apply @
          expect(linkAt(7)).toHaveText('7')
          expect(linkAt(8)).toHaveText('8')

        it "has an ellipsis after the center page window", ->
          compile.apply @
          expect(pageAt(9)).toHaveClass('ellipsis')
          expect(linkAt(9)).toHaveText('. . .')

        it "shows the last page", ->
          compile.apply @
          expect(linkAt(10)).toHaveText('40')

        it "shows the 'next' page", ->
          compile.apply @
          expect(pageAt(11)).toHaveClass('next-page')

    describe "when the current page is totalPages-5 or greater", ->
      beforeEach ->
        @scope.pagination.current_page = 38

      it "shows the 'prev' page", ->
        compile.apply @
        expect(pageAt(1)).toHaveClass('previous-page')

      it "shows the first page", ->
        compile.apply @
        expect(linkAt(2)).toHaveText('1')

      it "shows an ellipsis after the first page", ->
        compile.apply @
        expect(pageAt(3)).toHaveClass('ellipsis')
        expect(linkAt(3)).toHaveText('. . .')

      it "shows the last 5 pages", ->
        compile.apply @
        expect(linkAt(3)).toHaveText('. . .')
        expect(linkAt(4)).toHaveText('36')
        expect(linkAt(5)).toHaveText('37')
        expect(linkAt(6)).toHaveText('38')
        expect(linkAt(7)).toHaveText('39')
        expect(linkAt(8)).toHaveText('40')

      it "activates the current page", ->
        compile.apply @
        expect(pageAt(6)).toHaveClass('active')

      describe "the last page", ->
        beforeEach ->
          @scope.pagination.current_page = 40

        it "disables the 'next' page", ->
          compile.apply @
          expect(pageAt(9)).toHaveClass('disabled')

    describe 'when the number of pages is exactly 5', ->
      # Selecting page 5 here is two birds with 1 stone, as initially
      # there were problems with selecting exactly page 5
      # (because usually 5 means go to centered view)
      beforeEach ->
        @scope.pagination.total_entries = 25
        @scope.pagination.current_page = 5

      it "creates the correct number of pages", ->
        compile.apply @
        expect(@compiled.find('ul li a').length).toEqual(7)

      it "does not create an ellipsis", ->
        compile.apply @
        ellipsis = _.any @compiled.find('ul li a'), (el) -> $(el).text() == '. . .'
        expect(ellipsis).toBeFalsy()

  describe "TerminalPagination", ->
    beforeEach ->
      @template = """
        <div bb-paginate="pagination" paginator="TerminalPaginator">
        </div>
      """

    it "should create the correct number of pages", ->
      compile.apply @
      expect(@compiled.find('ul li a').length).toEqual(3)

    it "should show the correct, active current page", ->
      compile.apply @
      expect(pageAt(2)).toHaveClass('active')
      expect(linkAt(2)).toHaveText('3')


    describe "when there is only one page", ->
      beforeEach ->
        @scope.pagination.total_entries = 25
        @scope.pagination.per_page = 30
        @scope.pagination.current_page = 1

      it "should create the correct number of pages", ->
        compile.apply @
        expect(@compiled.find('ul li a').length).toEqual(3)

      it "should disable both prevous and next page buttons", ->
        compile.apply @
        expect(pageAt(1)).toHaveClass('disabled')
        expect(pageAt(3)).toHaveClass('disabled')

      it "should set the current page to active", ->
        compile.apply @
        expect(pageAt(2)).toHaveClass('active')

  describe 'Controller API', ->
    describe 'onPageSelect()', ->
      beforeEach ->
        @callback = jasmine.createSpy('afterSelect')
        @scope.pagination.current_page = 3
        compile.apply @
        @compiled.controller('bbPaginate').onPageSelect(@callback)

      it 'should call page select handlers', ->
        @compiled.find('ul li a:last-child').click()
        expect(@callback).toHaveBeenCalledWith(4)


  describe 'bgPaginateScrollTo', ->
    describe "when given bb-paginate-scroll-to", ->
      beforeEach ->
        @template = """
          <div bb-paginate="pagination" bb-paginate-scroll-to="#foo">
          </div>
        """

      it "should scroll after page select", ->
        spyOn($, 'scrollTo')
        compile.apply @
        @compiled.find('ul li a:last-child').click()
        expect($.scrollTo).toHaveBeenCalled()

    describe "when not given bb-paginate-scroll-to", ->
      it "should not scroll after page select", ->
        spyOn($, 'scrollTo')
        compile.apply @
        @compiled.find('ul li a:last-child').click()
        expect($.scrollTo).not.toHaveBeenCalled()
