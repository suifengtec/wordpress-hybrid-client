require 'hammerjs'
require 'angular'
require 'angular-animate'
require 'angular-sanitize'
require 'angular-aria'
require 'angular-material/angular-material'
require 'angular-ui-router'
require 'angular-translate'
require 'ionic/js/ionic'
require 'ionic/js/ionic-angular'

require 'wp-api-angularjs/dist/wp-api-angularjs.bundle'

# Style entry point
require './scss/bootstrap'
require 'angular-material/angular-material.css'

# Create namespace
window.WPHC = {}

module.exports = app = angular.module 'wordpress-hybrid-client', [
  'ionic'
  'ngMaterial'
  'ui.router'
  'wp-api-angularjs'
  'pascalprecht.translate'
  require('./home/home.module').name
  require('./menu/menu.module').name
]

app.config ($stateProvider) ->
    $stateProvider
    .state 'public',
    url: "/public"
    abstract: true
    views:
        '@' :
            template: require "./views/menu"
            controller: "WPHCMainController as main"
        'menu@public':
            template: require "./menu/menu.html"
            controller: "WPHCMenuController as menu"

app.config (WpApiProvider, $WPHCConfig, $translateProvider) ->
    ###
    REST CONF
    ###
    RestangularProvider = WpApiProvider.getRestangularProvider()
    RestangularProvider.setBaseUrl $WPHCConfig.api.baseUrl
    RestangularProvider.setFullResponse true
    RestangularProvider.addResponseInterceptor (data, operation, what, url, response, deferred) ->
        data.wpApiHeaders =
            total: response.headers 'X-WP-Total'
            pages: response.headers 'X-WP-TotalPages'
        data
    RestangularProvider.setRestangularFields
        id: "ID"

    ###
    TRANSLATION CONF
    ###
    languages = []
    languagesMapping = {}
    for language, mapping of $WPHCConfig.translation.available
        languages.push language
        angular.extend languagesMapping, mapping
        $translateProvider.translations language, require './translations/' + language

    $translateProvider
        .preferredLanguage $WPHCConfig.translation.prefered
        .registerAvailableLanguageKeys languages, languagesMapping
        .fallbackLanguage 'en'


app.controller 'WPHCMainController', require "./main.controller"

app.directive 'wphcLoader', require "./directives/loader/loader.coffee"

config = require "../config"

app.constant '$WPHCConfig', angular.extend config, WPHC.config || {}