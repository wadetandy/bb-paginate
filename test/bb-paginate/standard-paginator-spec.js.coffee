describe 'StandardPaginator', ->
  described_class = null

  beforeEach ->
    module('bbPaginate')
    inject (StandardPaginator) ->
      described_class = StandardPaginator

  describe 'any instance of StandardPaginator', ->
    subject = null

    beforeEach ->
      valid_pagination =
        current_page:  1
        per_page:      20
        total_entries: 100
      subject = new described_class(valid_pagination)

    it 'should be valid', ->
      expect(subject.isValid()).toBeTruthy()

    describe '.showNextPage', ->
      it 'should intend to display the Next Page', ->
        expect(subject.showNextPage()).toBeTruthy()

    describe '.showPreviousPage', ->
      it 'should intend to display the Previous Page', ->
        expect(subject.showPreviousPage()).toBeTruthy()

  describe 'the effects of current page', ->
    subject = null

    beforeEach ->
      valid_pagination =
        current_page:  1
        per_page:      10
        total_entries: 305
      subject = new described_class(valid_pagination)

    it 'should have 31 pages in this configuration', ->
      expect(subject.numPages()).toEqual(31)

    describe '.isCenterWindow', ->
      xit 'should be in the center window if the current page is not in the right window', ->
        # unfortunately we have to know something about the internal
        # implementation of window size to test the center window:
        expect(subject.windowSize.right).toEqual(5)

        subject.pagination.current_page = 28
        expect(subject.isCenterWindow()).toBeTruthy()

      it 'should not be in the center window if the current page is in the right window', ->
        # unfortunately we have to know something about the internal
        # implementation of window size to test the center window:
        expect(subject.windowSize.right).toEqual(5)

        subject.pagination.current_page = 30
        expect(subject.isCenterWindow()).toBeFalsy()

    describe '.isLeftWindow', ->
      it 'should be in the left window if the current page is less than the left window size', ->
        # unfortunately we have to know something about the internal
        # implementation of window size to test the center window:
        expect(subject.windowSize.left).toEqual(5)

        subject.pagination.current_page = 4
        expect(subject.isLeftWindow()).toBeTruthy()

      it 'should be in the left window if the number of pages is LTE the left window', ->
        # unfortunately we have to know something about the internal
        # implementation of window size to test the center window:
        expect(subject.windowSize.left).toEqual(5)
        subject.pagination.total_entries = 50
        expect(subject.numPages()).toEqual(5)

        expect(subject.isLeftWindow()).toBeTruthy()

  describe 'windowed page creation', ->
    subject        = null
    getFirstPage   = null
    getLastPage    = null
    getNthPage     = null

    ## these are implementation details of various Page
    ## classes, not important to the tests:
    isFillerPage = (page) ->
      page.cssClass == 'ellipsis'

    isPreviousPage = (page) ->
      page.cssClass == 'previous-page'

    isNextPage = (page) ->
      page.cssClass == 'next-page'
    ##
    ##

    beforeEach ->
      valid_pagination =
        current_page:  1
        per_page:      10
        total_entries: 305
      subject = new described_class(valid_pagination)

      ## these are helper functions which help
      ## reduce the ceremony of the tests:
      getNthPage = (num) ->
        subject.pages[num-1]

      getFirstPage = ->
        getNthPage(1)

      getLastPage = ->
        subject.pages.slice(-1)[0]
      ##
      ##

    it 'should begin with an empty page array', ->
      expect(subject.pages.length).toEqual(0)

    describe '.addFillerPage', ->
      it 'should add a single filler page', ->
        subject.addFillerPage()
        expect(subject.pages.length).toEqual(1)
        expect(isFillerPage(getFirstPage())).toBeTruthy()

    describe '.addLastPage', ->
      it 'should add a single final page', ->
        subject.addLastPage()
        expect(subject.pages.length).toEqual(1)
        expect(getLastPage().number).toEqual(31)

    describe '.addNumericalPages', ->
      it 'should have a series of pages after the second page which are in numerical order', ->
        subject.addNumericalPages([4..7])

        # we expect pages == [ 4, 5, 6, 7 ]
        expect(subject.pages.length).toEqual(4)
        expect(getNthPage(1).number).toEqual(4)
        expect(getNthPage(2).number).toEqual(5)
        expect(getNthPage(3).number).toEqual(6)
        expect(getNthPage(4).number).toEqual(7)

    describe '.buildPages', ->
      # TODO: break these functions out as a separate utility
      beforeEach ->
        spyOn(subject, 'buildWindow') # mock buildWindow

      it 'should create a first page of type Previous Page if showPreviousPage is true', ->
        expect(subject.showPreviousPage()).toBeTruthy()
        subject.buildPages()
        expect(isPreviousPage(getFirstPage())).toBeTruthy()

      it 'should create a last page of type Next Page if showNextPage is true', ->
        expect(subject.showNextPage()).toBeTruthy()
        subject.buildPages()
        expect(isNextPage(getLastPage())).toBeTruthy()

    describe '.buildWindow', ->
      # NOTE: this is starting to feel like an integration test
      #       for buildWindow against methods of an as-yet not
      #       separate PaginatorWindowing module

      it 'should build a left window', ->
        subject.pagination.current_page = 2
        spyOn(subject, 'leftWindow')
        subject.buildWindow()
        expect(subject.leftWindow).toHaveBeenCalled()

      it 'should build a center window', ->
        subject.pagination.current_page = 20
        spyOn(subject, 'centerWindow')
        subject.buildWindow()
        expect(subject.centerWindow).toHaveBeenCalled()

      it 'should build a right window', ->
        subject.pagination.current_page = 29
        spyOn(subject, 'rightWindow')
        subject.buildWindow()
        expect(subject.rightWindow).toHaveBeenCalled()

    describe '.rightWindow', ->
      # we expect pages == [ 1, '...', 27, 28, 29, 30, 31 ]

      it 'should have a first page with page number 1', ->
        subject.rightWindow()
        expect(getFirstPage().number).toEqual(1)

      it 'should have a second page which is a filler page', ->
        subject.rightWindow()
        expect(isFillerPage(getNthPage(2))).toBeTruthy()

      it 'should have a series of pages after the second page which are in numerical order', ->
        subject.rightWindow()
        expect(getNthPage(3).number).toEqual(27)
        expect(getNthPage(4).number).toEqual(28)
        expect(getNthPage(5).number).toEqual(29)
        expect(getNthPage(6).number).toEqual(30)

      it 'should have a last page with a page number of 31', ->
        subject.rightWindow()
        expect(getLastPage().number).toEqual(31)

    describe '.leftWindow', ->
      # we expect pages == [ 1, 2, 3, 4, 5, '...', 31 ]

      it 'should have a series of pages after the second page which are in numerical order', ->
        subject.leftWindow()
        expect(getNthPage(1).number).toEqual(1)
        expect(getNthPage(2).number).toEqual(2)
        expect(getNthPage(3).number).toEqual(3)
        expect(getNthPage(4).number).toEqual(4)
        expect(getNthPage(5).number).toEqual(5)

      it 'should have a second-to-last page which is a filler page', ->
        subject.leftWindow()
        expect(isFillerPage(getNthPage(6))).toBeTruthy()

      it 'should have a last page with a page number of 31', ->
        subject.leftWindow()
        expect(getLastPage().number).toEqual(31)

    describe '.centerWindow', ->
      beforeEach ->
        subject.pagination.current_page = 20
        # we expect pages == [ 1, '...', 18, 19, 20, 21, 22, '...', 31 ]

      it 'should have a first page with page number 1', ->
        subject.centerWindow()
        expect(getFirstPage().number).toEqual(1)

      it 'should have a second page which is a filler page', ->
        subject.centerWindow()
        expect(isFillerPage(getNthPage(2))).toBeTruthy()


      it 'should have a series of pages after the second page which are in numerical order', ->
        subject.centerWindow()
        expect(getNthPage(3).number).toEqual(18)
        expect(getNthPage(4).number).toEqual(19)
        expect(getNthPage(5).number).toEqual(20)
        expect(getNthPage(6).number).toEqual(21)
        expect(getNthPage(7).number).toEqual(22)

      it 'should have a second-to-last page which is a filler page', ->
        subject.centerWindow()
        expect(isFillerPage(getNthPage(8))).toBeTruthy()

      it 'should have a last page with a page number of 31', ->
        subject.centerWindow()
        expect(getLastPage().number).toEqual(31)
