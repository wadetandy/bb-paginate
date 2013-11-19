// Karma configuration
// Generated on Mon Aug 12 2013 09:57:28 GMT-0400 (EDT)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',


    // frameworks to use
    frameworks: ['jasmine'],

    // Configure coffeescript preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    },

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: true
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.js$/, '.coffee');
      }
    },

    // list of files / patterns to load in the browser
    files: [
        'bower_components/jquery/jquery.js',
        'bower_components/angular/angular.js',
        'bower_components/underscore/underscore.js',
        'bower_components/jquery.scrollTo/jquery.scrollTo.js',
        'bower_components/angular-mocks/angular-mocks.js',
        'bower_components/jasmine-master/lib/jasmine-core/jasmine.js',
        'bower_components/jasmine-master/lib/jasmine-core/jasmine-html.js',
        'bower_components/jasmine-jquery/lib/jasmine-jquery.js',
        'src/js/*.js.coffee',
        'test/setup.js.coffee',
        'test/**/*-spec.js*'
    ],


    // list of files to exclude
    exclude: [
      '"**/*.swp"',
      '.DS_Store'
    ],


    // test results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['Chrome', 'Safari', 'Firefox'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
