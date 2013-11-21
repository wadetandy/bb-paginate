describe 'Paginator', ->
  described_class = null

  beforeEach ->
    module('bbPaginate')
    inject (Paginator) ->
      described_class = Paginator

  describe '#new', ->
    it 'should create a paginator instance if required attributes are provided', ->
      subject = new described_class
        current_page:  1
        per_page:      20
        total_entries: 100
      expect(subject.isValid()).toBeTruthy()

    it 'should raise an error unless all required attributes are provided', ->
      lambda = ->
        new described_class
          # current_page:  undefined
          per_page:      20
          total_entries: 100
      expect(lambda).toThrow()

  describe 'an instance of Paginator', ->
    subject = null

    beforeEach ->
      valid_pagination =
        current_page:  1
        per_page:      20
        total_entries: 100
      subject = new described_class(valid_pagination)

    describe '.isValid', ->

      it 'should be valid if all required attributes are defined', ->
        expect(subject.isValid()).toBeTruthy()

      it 'should not be valid unless if any required attribute is undefined', ->
        subject.pagination.current_page = undefined
        expect(subject.isValid()).toBeFalsy()

    describe '.reset', ->
      beforeEach inject (Page) ->
        spyOn(subject, 'buildPages')

        page1 = new Page { number: 1 }
        page2 = new Page { number: 2 }
        page3 = new Page { number: 3 }

        subject.pages = [ page1, page2, page3 ]

      it 'should reset pages to an empty', ->
        expect(subject.pages.length).toEqual(3)
        subject.reset()
        expect(subject.pages.length).toEqual(0)

      it 'should reset to an initial state', ->
        subject.reset()
        expect(subject.buildPages).toHaveBeenCalled()

    describe '.numPages', ->
      it 'should compute the number of pages from the total pages and the items per page', ->
        subject.pagination.total_entries = 100
        subject.pagination.per_page      = 20
        expect(subject.numPages()).toEqual(5)

      it 'should round the number of pages up to the nearest integer', ->
        subject.pagination.total_entries = 101
        subject.pagination.per_page      = 20
        expect(subject.numPages()).toEqual(6)

    describe '.buildPages', ->
      it 'should expect a subclass to implement buildPages', ->
        lambda = ->
          subject.buildPages()
        expect(lambda).toThrow()
