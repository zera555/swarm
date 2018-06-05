'use strict'

###*
 # @ngdoc overview
 # @name swarmApp
 # @description
 # # swarmApp
 #
 # Main module of the application.
###
angular.module 'swarmApp', [
    'ngAnimate'
    'ngCookies'
    'ngResource'
    'ngRoute'
    'ngSanitize'
    'ngTouch'
    # autogenerated files specific to this project
    'swarmEnv', 'swarmSpreadsheetPreload'
    # http://luisfarzati.github.io/angulartics/
    'angulartics', 'angulartics.google.analytics'
    'googlechart'
    # https://github.com/chieffancypants/angular-hotkeys/
    'cfp.hotkeys'
  ]

# Angular 1.6 makes urls start with '#!' instead of '#', but swarmsim predates that and has lots of non-#! urls out there already.
# https://docs.angularjs.org/guide/migration#migrating-from-1-4-to-1-5
angular.module('swarmApp').config ($locationProvider) ->
  $locationProvider.hashPrefix ''

angular.module('swarmApp').config ($routeProvider, env) ->
  if env.isOffline
    return $routeProvider
      .when '/debug',
        templateUrl: 'views/debug.html'
        controller: 'DebugCtrl'
      .when '/changelog',
        templateUrl: 'views/changelog.html'
        controller: 'ChangelogCtrl'
      .when '/contact',
        templateUrl: 'views/contact.html'
        controller: 'ContactCtrl'
      .when '/cleartheme',
        templateUrl: 'views/cleartheme.html'
        controller: 'ClearthemeCtrl'
      .when '/importsplash',
        templateUrl: 'views/importsplash.html'
        controller: 'ImportsplashCtrl'
      .when '/export',
        templateUrl: 'views/export.html'
        controller: 'ExportCtrl'
      .otherwise
        redirectTo: '/'

  $routeProvider
    .when '/debug',
      templateUrl: 'views/debug.html'
      controller: 'DebugCtrl'
    .when '/options',
      templateUrl: 'views/options.html'
      controller: 'OptionsCtrl'
    .when '/changelog',
      templateUrl: 'views/changelog.html'
      controller: 'ChangelogCtrl'
    .when '/statistics',
      templateUrl: 'views/statistics.html'
      controller: 'StatisticsCtrl'
    .when '/achievements',
      templateUrl: 'views/achievements.html'
      controller: 'AchievementsCtrl'
    .when '/',
      templateUrl: 'views/main.html'
      controller: 'MainCtrl'
    .when '/tab/:tab/unit/:unit',
      templateUrl: 'views/unit.html'
      controller: 'MainCtrl'
    .when '/unit/:unit',
      templateUrl: 'views/unit.html'
      controller: 'MainCtrl'
    .when '/tab/:tab',
      templateUrl: 'views/main.html'
      controller: 'MainCtrl'
    .when '/contact',
      templateUrl: 'views/contact.html'
      controller: 'ContactCtrl'
    .when '/cleartheme',
      templateUrl: 'views/cleartheme.html'
      controller: 'ClearthemeCtrl'
    .when '/export',
      templateUrl: 'views/export.html'
      controller: 'ExportCtrl'
    .when '/login',
      if not env.isServerFrontendEnabled
        redirectTo: '/'
      else
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
    .when '/debug/api',
      if not env.isServerBackendEnabled
        redirectTo: '/'
      else
        templateUrl: 'views/debugapi.html'
        controller: 'DebugApiCtrl'
    .when '/decimallegend',
      templateUrl: 'views/decimallegend.html'
      controller: 'DecimallegendCtrl'
    #.when '/news-archive',
    #  templateUrl: 'views/news-archive.html'
    #  controller: 'NewsArchiveCtrl'
    .otherwise
      redirectTo: '/'


angular.module('swarmApp').config (env, $logProvider) ->
  $logProvider.debugEnabled env.isDebugLogged

# http and https use different localstorage, which might confuse folks.
# angular $location doesn't make protocol mutable, so use window.location.
# allow an out for testing, though.
angular.module('swarmApp').run (env, $location, $log) ->
  # ?allowinsecure=0 is false, for example
  falsemap = {0:false,'':false,'false':false}
  allowinsecure = $location.search().allowinsecure ? env.httpsAllowInsecure
  allowinsecure = falsemap[allowinsecure] ? true
  $log.debug 'protocol check', allowinsecure, $location.protocol()
  # $location.protocol() == 'http', but window.location.protocol == 'http:' and you can't assign $location.protocol()
  # NOPE, in firefox there's no ':', https://bugzilla.mozilla.org/show_bug.cgi?id=726779 https://github.com/erosson/swarm/issues/68
  # chrome and IE don't mind the missing ':' though. I'm amazed - IE is supposed to be the obnoxious browser
  if $location.protocol() == 'http' and not allowinsecure
    window.location.protocol = 'https'
    $log.debug "window.location.protocol = 'https:'"

# originally, [www.]swarmsim.com redirected to swarmsim.github.io, like so:
#  if (window.location.host == 'swarmsim.com' || window.location.host == 'www.swarmsim.com')
#    window.location.host = 'swarmsim.github.io'
# It started there, and I didn't want to move cookies after buying the domain.
# Then, MS bought github and I got spooked. Time to move everyone to the dot-com.
#
# Kongregate uses swarmsim.com - it was implemented later and has no legacy
# savestates to worry about.
#
# I don't want people playing in two standalone locations, juggling savestates.
# There's "Kongregate" and there's "standalone"; no more urls. Redirect all
# standalone users to the canonical standalone url.
# One exception: ?noredirect=1, for debugging/power-users.
#
# Github automatically redirects swarmsim-dotcom.github.io - the backend for
# swarmsim.com - to swarmsim.com itself.
#
# Github automatically redirects the naked-domain to www.
angular.module('swarmApp').factory 'domain', ($location) ->
  return $location.search().mockdomain || window.location.host

angular.module('swarmApp').factory 'enableAfter', ($log) ->
  return (enableDate, loggedName) -> () ->
    diff = Date.now() - enableDate.getTime()
    enabled = diff >= 0
    if (loggedName?)
      $log.info('enableAfter', loggedName, enabled, diff)
    return enabled

angular.module('swarmApp').value 'wwwNagDate', new Date('2018-06-07T00:00:00.000Z')
angular.module('swarmApp').factory 'wwwNagTimer', (enableAfter, wwwNagDate) -> enableAfter(wwwNagDate, 'wwwNag')
angular.module('swarmApp').value 'wwwRedirectDate', new Date('2018-07-15T00:00:00.000Z')
angular.module('swarmApp').factory 'wwwRedirectTimer', (enableAfter, wwwRedirectDate) -> enableAfter(wwwRedirectDate, 'wwwRedirect')

angular.module('swarmApp').factory 'domainType', ($location, isKongregate, domain, wwwNagTimer) ->
  if (isKongregate())
    return 'kongregate'
  if ($location.search().noredirect)
    return 'other'
  if (domain == 'www.swarmsim.com' || domain == 'swarmsim.com')
    return 'www'
  # Disable the migration alerts in prod for a few days, until users' browser
  # caches clear and www.swarmsim.com stops redirecting. Mocks still work.
  #if (domain == 'swarmsim.github.io')
  if ((if wwwNagTimer() then domain else $location.search().mockdomain) == 'swarmsim.github.io')
    return 'oldwww'
  return 'other'

angular.module('swarmApp').factory 'isRedirectingOldDomain', ($location, domainType, wwwRedirectTimer) ->
  # Phase 1: allow players on both: No redirect, yet!
  # Phase 2: github redirects to www.
  if ($location.search().wwwredirect)
    # more readable than one line with all the conditions
    return true
  return (domainType == 'oldwww') and wwwRedirectTimer()

angular.module('swarmApp').run ($location, isRedirectingOldDomain) ->
  if (isRedirectingOldDomain and $location.path() != '/export')
    # $location.path('/export')
    window.location = 'https://www.swarmsim.com/#/referrer=github'


# Google analytics setup. Run this only after redirects are done.
angular.module('swarmApp').config (env, version) ->
  if env.gaTrackingID and window.ga? and not env.isOffline
    #console.log 'analytics', gaTrackingID
    window.ga 'create', env.gaTrackingID, 'auto'
    # appVersion breaks analytics, presumably because it's mobile-only.
    #window.ga 'set', 'appVersion', version
    # set Kongregate referrer manually when using kongregate_shell.html
    window.ga 'set', 'anonymizeIp', true
    try
      if window.parent != window and (ref=window?.parent?.document?.referrer)?
        window.ga 'set', 'referrer', ref
    catch e
      # No parent, no worries. Use the original referrer.

angular.module('swarmApp').run ($rootScope) ->
  $rootScope.floor = (val) -> Math.floor val

# decimal.js does not play nice with tests. hacky workaround.
angular.module('swarmApp').run ($rootScope) ->
  # are we running tests with decimal.js imported?
  if window.module and window.module.exports and not window.Decimal and window.module.exports.random
    window.Decimal = window.module.exports
    delete window.module.exports

angular.module('swarmApp').value 'UNIT_LIMIT', '1e100000'

# global keyboard shortcuts
angular.module('swarmApp').run (hotkeys, $location) ->
  locationKeys = [
    ['m', '/tab/meat', 'Open the meat tab']
    ['l', '/tab/larva', 'Open the larva tab']
    ['t', '/tab/territory', 'Open the territory tab']
    ['e', '/tab/energy', 'Open the energy tab']
    ['u', '/tab/mutagen', 'Open the mutagen tab']
    ['a', '/tab/all', 'Open the all-units tab']
    ['o', '/options', 'Open the options screen']
    ['y', '/achievements', 'Open the achievements screen']
    ['shift+y', '/statistics', 'Open the statistics screen']
    ['n', '/changelog', 'Open the patch notes screen']
  ]
  for [combo, path, desc] in locationKeys then do (combo, path, desc) ->
    hotkeys.add
      combo: combo
      description: desc
      callback: () -> $location.path path
angular.module('swarmApp').run (hotkeys, $rootScope) ->
  # obfuscate a little, just to make things interesting
  reverse = (str) ->
    str = str.split ''
    str.reverse()
    return str.join ''
  hotkeys.add
    combo: reverse 'l e u q e s'
    callback: () -> $rootScope.$emit reverse 'noitseuqthgireht'

#angular.module('swarmApp').run (isKongregate, env) ->
#  # https://github.com/xsolla/paystation-embed
#  console.log 'xsolla?'
#  if !isKongregate()
#    console.log 'xsolla loading'
#    # lazy load the non-kongregate payment processor
#    $.getScript 'https://static.xsolla.com/embed/paystation/1.0.7/widget.min.js', (data, status, xhr) ->
#      console.log 'xsolla loaded'
#      XPayStationWidget.init
#        access_token: env.xsollaAccessToken
#  else
#    console.log 'xsolla ignored'

# not sure why dropdowns don't work on their own anymore, but this fixes it
angular.module('swarmApp').run () ->
  $(document).on 'mousedown', '.dropdown-toggle', () ->
    $(this).dropdown()
