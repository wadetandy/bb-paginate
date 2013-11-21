describe 'Page', ->
  beforeEach(module('bbPaginate'))

  describe "#new", ->
    describe "default behavior", ->
      it "should be possible to create a disabled instance", inject (Page) ->
        page = new Page
          disabled: true
        expect(page.disabled).toBeTruthy()

      it "should be possible to create an active instance", inject (Page) ->
        page = new Page
          active: true
        expect(page.active).toBeTruthy()

      it "should be possible to set the page number initially", inject (Page) ->
        page = new Page
          number: 5
        expect(page.number).toEqual(5)

      it "should be possible to set the display text initially", inject (Page) ->
        page = new Page
          text: '10'
        expect(page.text).toEqual('10')

      it "should be set instance variables for any attribute passed to the constructor", inject (Page) ->
        page = new Page
          foo: 'bar'
        expect(page.foo).toEqual('bar')


  describe '#reset', ->
    it "should be active if number matches the current page number", inject (Page) ->
      currentPageNumber = 2
      page = new Page
        number: 2
      page.reset(currentPageNumber, 100)
      expect(page.active).toBeTruthy()

    it "should not be active unless number matches the current page number", inject (Page) ->
      currentPageNumber = 10
      page = new Page
        number: 2
      page.reset(currentPageNumber, 100)
      expect(page.active).toBeFalsy()


  describe '#listItemClasses', ->
    it "should not have any item classes be default", inject (Page) ->
      page = new Page
      expect(page.listItemClasses()).toEqual('')

    it "should have an item class of 'active' if it is active", inject (Page) ->
      page = new Page
        active: true
      expect(page.listItemClasses()).toMatch(/\bactive\b/)

    it "should not have an item class of 'active' unless it is active", inject (Page) ->
      page = new Page
        active: false
      expect(page.listItemClasses()).not.toMatch(/\bactive\b/)

    it "should have an item class of 'disabled' if it is disabled", inject (Page) ->
      page = new Page
        disabled: true
      expect(page.listItemClasses()).toMatch(/\bdisabled\b/)

    it "should not have an item class of 'disabled' unless it is disabled", inject (Page) ->
      page = new Page
        disabled: false
      expect(page.listItemClasses()).not.toMatch(/\bdisabled\b/)

    it "should have an item class with of it's cssClass if defined", inject (Page) ->
      page = new Page
        cssClass: 'foo-bar'
      expect(page.listItemClasses()).toMatch(/\bfoo-bar\b/)
