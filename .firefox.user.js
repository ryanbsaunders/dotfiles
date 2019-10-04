/* firefox preferences */


/* startup */

user_pref("browser.shell.checkDefaultBrowser", false);  // don't check if we are the default browser
user_pref("browser.startup.page", 0); // set the startup page to a blank page
user_pref("browser.startup.homepage", "about:blank");  // set the startup page to blank
user_pref("browser.newtabpage.enabled", false); // Set new windows and tabs to blank page
user_pref("browser.newtabpage.enabled", false);

// disable activity stream page telemetry
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry.ping.endpoint", "");

// disable everything about activity stream
user_pref("browser.aboutHomeSnippets.updateUrl", "");
user_pref("browser.newtabpage.activity-stream.asrouter.providers.snippets", "");
user_pref("browser.newtabpage.activity-stream.disableSnippets", true);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false);

/*************************************************************************/
/* warnings */

user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnCloseOtherTabs", false);
user_pref("browser.tabs.warnOnOpen", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("general.warnOnAboutConfig", false);


/*************************************************************************/
/* downloads */
user_pref("browser.download.useDownloadDir", false); // always ask where to download files
user_pref("browser.download.manager.addToRecentDocs", false); // disable adding downloads to the system's recent documents list
user_pref("browser.download.hide_plugins_without_extensions", false); // disable hiding mime types not associated with a plugin
user_pref("browser.download.forbid_open_with", true); // disabled 'open with' download dialog option

/*************************************************************************/
/* containers */
user_pref("privacy.userContext.ui.enabled", true); // enable container tabs in preferences
user_pref("privacy.userContext.enabled", true); // enable container tabs
user_pref("privacy.userContext.longPressBehavior", 2); // new tab '+' button behavior | 0=no menu (default), 1=show when clicked, 2=show on long press

/*************************************************************************/
/* geolocation */
user_pref("geo.enabled", false); // disable location-aware browsing
user_pref("permissions.default.geo", 2); // default for asking location (0=always ask, 1=allow, 2=block)
user_pref("browser.search.region", "US"); // disable geo-based search results
user_pref("browser.search.geoip.url", ""); // disable geo-based search results

// disable using os geolocation service
user_pref("geo.provider.ms-windows-location", false); // windows
user_pref("geo.provider.use_corelocation", false); // macos
user_pref("geo.provider.use_gpsd", false); // linux

/*************************************************************************/
/* misc */
user_pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false); // disable crash reporting
user_pref("dom.ipc.plugins.reportCrashURL", false); // disable plugin crash url sending
user_pref("extensions.getAddons.showPane", false); // disable about:addons panel (uses google analytics)
user_pref("extensions.webservice.discoverURL", "");

user_pref("datareporting.healthreport.uploadEnabled", false); // disable health reports
user_pref("datareporting.policy.dataSubmissionEnabled", false); // disable new data submission

user_pref("browser.discovery.enabled", false); // disable personalized extension suggestions

user_pref("extensions.pocket.enabled", false); // disable pocket

user_pref("captivedetect.canonicalURL", ""); // disable captive portal detection
user_pref("network.captive-portal-service.enabled", false);

user_pref("network.connectivity-service.enabled", false); // disable network connectivity check

user_pref("network.dnsCacheExpiration", 0);
user_pref("network.dnsCacheExpirationGracePeriod", 0);
user_pref("network.dnsCacheEntries", 0);

/*************************************************************************/
/* safe browsing and blacklists */
user_pref("app.normandy.enabled", false); // disable shield/normandy
user_pref("app.normandy.api_url", ""); // user_pref("app.normandy.enabled", false);

user_pref("browser.ping-centre.telemetry", false);  // disable ping-centre telemetry

user_pref("extensions.screenshots.disabled", true); // disable firefox screenshots
user_pref("extensions.screenshots.upload-disabled", true); // disable firefox screenshots upload

// disable all auto-fill
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.available", "off");
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.heuristics.enabled", false);

user_pref("extensions.webcompat-reporter.enabled", false); // disable web compatibility reporting (report site issue)


/*************************************************************************/
/* passwords */
user_pref("signon.rememberSignons", false); // do not remember passwords

/*************************************************************************/
/* search */
user_pref("keyword.enabled", true); // do not submit invalid URIs to search engines (disable location bar search)
user_pref("browser.fixup.alternate.enabled", false); // do not fixup and mess with queries
