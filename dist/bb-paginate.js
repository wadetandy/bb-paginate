/*! bb-paginate v1.0.0 2013-11-20 */
(function() {
  var app;

  app = angular.module('bbPaginate', []);

}).call(this);

/*
//@ sourceMappingURL=bb-paginate.js.map
*/
(function() {
  var PaginationController, app,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app = angular.module('bbPaginate');

  app.factory('Page', function() {
    var Page;
    return Page = (function() {
      Page.prototype.disabled = false;

      Page.prototype.active = false;

      Page.prototype.text = '';

      Page.prototype.number = null;

      function Page(attrs) {
        this.reset = __bind(this.reset, this);
        angular.extend(this, attrs);
      }

      Page.prototype.reset = function(currentPage, lastPage) {
        if (this.number) {
          return this.active = currentPage === this.number;
        }
      };

      Page.prototype.listItemClasses = function() {
        var classes;
        classes = [];
        if (this.active) {
          classes.push('active');
        }
        if (this.disabled) {
          classes.push('disabled');
        }
        if (this.cssClass) {
          classes.push(this.cssClass);
        }
        return classes.join(' ');
      };

      return Page;

    })();
  });

  app.factory('PrevPage', [
    'Page', function(Page) {
      var PrevPage, _ref;
      return PrevPage = (function(_super) {
        __extends(PrevPage, _super);

        function PrevPage() {
          this.reset = __bind(this.reset, this);
          _ref = PrevPage.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        PrevPage.prototype.cssClass = 'previous-page';

        PrevPage.prototype.text = '<';

        PrevPage.prototype.reset = function(currentPage, lastPage) {
          this.number = currentPage - 1;
          return this.disabled = currentPage === 1;
        };

        return PrevPage;

      })(Page);
    }
  ]);

  app.factory('EllipsisPage', [
    'Page', function(Page) {
      var EllipsisPage, _ref;
      return EllipsisPage = (function(_super) {
        __extends(EllipsisPage, _super);

        function EllipsisPage() {
          _ref = EllipsisPage.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        EllipsisPage.prototype.cssClass = 'ellipsis';

        EllipsisPage.prototype.disabled = true;

        EllipsisPage.prototype.text = '. . .';

        EllipsisPage.prototype.reset = function() {
          return null;
        };

        return EllipsisPage;

      })(Page);
    }
  ]);

  app.factory('NextPage', [
    'Page', function(Page) {
      var NextPage, _ref;
      return NextPage = (function(_super) {
        __extends(NextPage, _super);

        function NextPage() {
          this.reset = __bind(this.reset, this);
          _ref = NextPage.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        NextPage.prototype.cssClass = 'next-page';

        NextPage.prototype.text = '>';

        NextPage.prototype.reset = function(currentPage, lastPage) {
          this.number = currentPage + 1;
          return this.disabled = currentPage === lastPage;
        };

        return NextPage;

      })(Page);
    }
  ]);

  app.factory('Paginator', function() {
    var Paginator;
    return Paginator = (function() {
      Paginator.prototype.pages = [];

      function Paginator(pagination) {
        this.pagination = pagination;
        this.numPages = __bind(this.numPages, this);
        this.buildPages = __bind(this.buildPages, this);
        this.reset = __bind(this.reset, this);
        this.isValid = __bind(this.isValid, this);
        if (!this.isValid()) {
          throw "Invalid Pagination. Must have attributes current_page, per_page, and total_entries";
        }
      }

      Paginator.prototype.isValid = function() {
        var _this = this;
        return _.all(['current_page', 'per_page', 'total_entries'], function(attr) {
          return _this.pagination[attr] !== void 0;
        });
      };

      Paginator.prototype.reset = function() {
        var _this = this;
        this.pages = [];
        this.buildPages();
        return _.each(this.pages, function(page) {
          return page.reset(parseInt(_this.pagination.current_page), _this.numPages());
        });
      };

      Paginator.prototype.buildPages = function() {
        throw "#buildPages must be implemented in subclass";
      };

      Paginator.prototype.numPages = function() {
        return Math.ceil(this.pagination.total_entries / this.pagination.per_page);
      };

      return Paginator;

    })();
  });

  PaginationController = (function() {
    function PaginationController(scope, attrs) {
      this.scope = scope;
      this.attrs = attrs;
      this.onPageSelect = __bind(this.onPageSelect, this);
      this.selectPage = __bind(this.selectPage, this);
      this.scope.selectPage = this.selectPage;
      this._pageSelectHandlers = [];
    }

    PaginationController.prototype.selectPage = function(page) {
      var _this = this;
      if (page.disabled) {
        return;
      }
      this.scope.pagination.current_page = page.number;
      this.scope.onPageSelect({
        pageNumber: page.number
      });
      return _(this._pageSelectHandlers).each(function(fn) {
        return fn(page.number);
      });
    };

    PaginationController.prototype.onPageSelect = function(fn) {
      return this._pageSelectHandlers.push(fn);
    };

    return PaginationController;

  })();

  app.directive('bbPaginate', [
    '$injector', function($injector) {
      return {
        template: "<ul>\n  <li ng-repeat=\"page in paginator.pages\" ng-class=\"page.listItemClasses()\">\n    <a href=\"\" ng-click=\"selectPage(page)\">{{page.text}}</a>\n  </li>\n</ul>",
        controller: ['$scope', '$attrs', PaginationController],
        scope: {
          onPageSelect: '&',
          pagination: "=bbPaginate"
        },
        link: function($scope, $element, $attrs) {
          var klass, paginator;
          paginator = $attrs.paginator || 'StandardPaginator';
          klass = $injector.get(paginator);
          $scope.paginator = new klass($scope.pagination);
          if (!$element.hasClass('pagination')) {
            $element.addClass('pagination');
          }
          return $scope.$watch('pagination', $scope.paginator.reset, true);
        }
      };
    }
  ]);

  app.directive('bbPaginateScrollTo', function() {
    return {
      require: 'bbPaginate',
      link: function($scope, $element, $attrs, bbPaginateCtrl) {
        return bbPaginateCtrl.onPageSelect(function(page) {
          return $.scrollTo($attrs.bbPaginateScrollTo, 500);
        });
      }
    };
  });

}).call(this);

/*
//@ sourceMappingURL=directive.js.map
*/
(function() {
  var app,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app = angular.module('bbPaginate');

  app.factory('StandardPaginator', [
    'Paginator', 'Page', 'PrevPage', 'NextPage', 'EllipsisPage', function(Paginator, Page, PrevPage, NextPage, EllipsisPage) {
      var StandardPaginator, _ref;
      return StandardPaginator = (function(_super) {
        __extends(StandardPaginator, _super);

        function StandardPaginator() {
          this.rightWindow = __bind(this.rightWindow, this);
          this.centerWindow = __bind(this.centerWindow, this);
          this.leftWindow = __bind(this.leftWindow, this);
          this.addFillerPage = __bind(this.addFillerPage, this);
          this.addNumericalPages = __bind(this.addNumericalPages, this);
          this.addLastPage = __bind(this.addLastPage, this);
          this.buildWindow = __bind(this.buildWindow, this);
          this.buildPages = __bind(this.buildPages, this);
          this.isLeftWindow = __bind(this.isLeftWindow, this);
          this.isCenterWindow = __bind(this.isCenterWindow, this);
          this.showPreviousPage = __bind(this.showPreviousPage, this);
          this.showNextPage = __bind(this.showNextPage, this);
          _ref = StandardPaginator.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        StandardPaginator.prototype.windowSize = {
          right: 5,
          left: 5,
          center: 2
        };

        StandardPaginator.prototype.showNextPage = function() {
          return true;
        };

        StandardPaginator.prototype.showPreviousPage = function() {
          return true;
        };

        StandardPaginator.prototype.isCenterWindow = function() {
          return this.pagination.current_page < (this.numPages() - (this.windowSize['right'] - 2));
        };

        StandardPaginator.prototype.isLeftWindow = function() {
          return this.pagination.current_page <= this.windowSize['left'] - 1 || this.numPages() <= this.windowSize['left'];
        };

        StandardPaginator.prototype.buildPages = function() {
          if (this.showNextPage()) {
            this.pages.push(new PrevPage);
          }
          this.buildWindow();
          if (this.showNextPage()) {
            return this.pages.push(new NextPage);
          }
        };

        StandardPaginator.prototype.buildWindow = function() {
          if (this.isLeftWindow()) {
            return this.leftWindow();
          } else if (this.isCenterWindow()) {
            return this.centerWindow();
          } else {
            return this.rightWindow();
          }
        };

        StandardPaginator.prototype.addLastPage = function() {
          return this.pages.push(new Page({
            text: this.numPages(),
            number: this.numPages()
          }));
        };

        StandardPaginator.prototype.addNumericalPages = function(window) {
          var pageNumber, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = window.length; _i < _len; _i++) {
            pageNumber = window[_i];
            _results.push(this.pages.push(new Page({
              text: pageNumber,
              number: parseInt(pageNumber)
            })));
          }
          return _results;
        };

        StandardPaginator.prototype.addFillerPage = function() {
          return this.pages.push(new EllipsisPage);
        };

        StandardPaginator.prototype.leftWindow = function() {
          var cutoff, _i, _results;
          cutoff = this.numPages() < this.windowSize['left'] ? this.numPages() : this.windowSize['left'];
          this.addNumericalPages((function() {
            _results = [];
            for (var _i = 1; 1 <= cutoff ? _i <= cutoff : _i >= cutoff; 1 <= cutoff ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this));
          if (!(this.numPages() <= this.windowSize['left'])) {
            this.addFillerPage();
          }
          if (!(this.numPages() <= this.windowSize['left'])) {
            return this.addLastPage();
          }
        };

        StandardPaginator.prototype.centerWindow = function() {
          var _i, _ref1, _ref2, _results;
          this.pages.push(new Page({
            text: '1',
            number: 1
          }));
          this.addFillerPage();
          this.addNumericalPages((function() {
            _results = [];
            for (var _i = _ref1 = this.pagination.current_page - this.windowSize['center'], _ref2 = this.pagination.current_page + this.windowSize['center']; _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; _ref1 <= _ref2 ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this));
          this.addFillerPage();
          return this.addLastPage();
        };

        StandardPaginator.prototype.rightWindow = function() {
          var _i, _ref1, _ref2, _results;
          this.pages.push(new Page({
            text: '1',
            number: 1
          }));
          this.addFillerPage();
          return this.addNumericalPages((function() {
            _results = [];
            for (var _i = _ref1 = this.numPages() - (this.windowSize['right'] - 1), _ref2 = this.numPages(); _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; _ref1 <= _ref2 ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this));
        };

        return StandardPaginator;

      })(Paginator);
    }
  ]);

}).call(this);

/*
//@ sourceMappingURL=standard-paginator.js.map
*/
(function() {
  var app,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  app = angular.module('bbPaginate');

  app.factory('TerminalPaginator', [
    'StandardPaginator', 'Page', function(StandardPaginator, Page) {
      var TerminalPaginator, _ref;
      return TerminalPaginator = (function(_super) {
        __extends(TerminalPaginator, _super);

        function TerminalPaginator() {
          this.buildWindow = __bind(this.buildWindow, this);
          _ref = TerminalPaginator.__super__.constructor.apply(this, arguments);
          return _ref;
        }

        TerminalPaginator.prototype.buildWindow = function() {
          var current;
          current = this.pagination.current_page;
          return this.pages.push(new Page({
            text: current,
            number: current
          }));
        };

        return TerminalPaginator;

      })(StandardPaginator);
    }
  ]);

}).call(this);

/*
//@ sourceMappingURL=terminal-paginator.js.map
*/