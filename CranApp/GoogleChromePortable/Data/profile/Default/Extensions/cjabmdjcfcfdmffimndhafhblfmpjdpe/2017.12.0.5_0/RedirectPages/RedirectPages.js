/* Symantec Watermark: CB70-4860-5397-06-15-6 */
// frameid
var _fid = 0, // the frame id
	_NavEventSent = false;

function getFrameId() {
	if (_fid === 0) {
		_fid = Math.floor((Math.random() * 2147483646) + 1);
	}
	return _fid;
}

function SendMessageToNativeHost(context) {
    chrome.runtime.sendMessage(context);
}

function init(){
	var fidAttr = getFrameId();
    chrome.extension.sendMessage({ contentscript: "GetTabInfo" }, function (response) {
		// Send the navigational messages to the chrome plugin
		SendMessageToNativeHost({ method: 'ChromeSetId', windowId: response.windowId, tabId: response.tabId, incognitoMode: response.incognitoMode, windowType: response.windowType, topLevel: top === self });
		SendMessageToNativeHost({method: "NavEvent",windowId: response.windowId,tabId: response.tabId,topLevelNav: window === window.top,beginNav : true,documentURL: document.URL.toString(),fid: fidAttr});
        SendMessageToNativeHost({ method: 'DOMContentLoaded', windowId: response.windowId, tabId: response.tabId, topLevel: window === window.top, fid: fidAttr, documentURL: document.URL.toString() });
		SendMessageToNativeHost({method: "NavEvent",windowId: response.windowId,tabId: response.tabId,topLevelNav: window === window.top,beginNav : false,documentURL: document.URL.toString(),fid: fidAttr});
		_NavEventSent = true;
		
        // for PII only, launch url 
        var element = document.getElementById("ReportPIIIssue");
        if (element) {
            var sPIIReportIssueURL = element.getAttribute('url');
            element.onclick = function () {
                window.open(sPIIReportIssueURL);
            };
        }
    });
}   

chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
	if (!request || !request.type || !request.id) {
		// invalid arguments
		return;
	}
	var eventName = request.type;
	var element = document.getElementById(request.id);
	if (!element) {
		// element not found
		return;
	}
	if ("setElementInnerHtml" === eventName) {
		element.innerHTML = request.innerHtml;
		window.setTimeout( function () {
            document.getElementById("block-page-search-icon").addEventListener("click", BlockPageSafeSearch);
            document.getElementById("block-page-search-text").addEventListener("keyup", function(event) {
                                                                                event.preventDefault();
                                                                                if (event.keyCode == 13) {
                                                                                    BlockPageSafeSearch();
                                                                                }
                                                                            });
		}, 1000);        
	} else if ("setElementText" === eventName) {
		element.textContent  = request.text;
	} else if ("setAttributeByName" === eventName){
		if (request.attributeName && request.attributeValue) {
			element.setAttribute(request.attributeName,request.attributeValue);
		}
	}
});    

document.addEventListener("DOMContentLoaded", function () {
    if (!_NavEventSent) {
		init();
	}
}, false);

// check if we have sent the navigational events already after 1 sec, send it if not already sent
window.setTimeout( function() {
	if (!_NavEventSent) {
		init();
	}
}, 1000);

function BlockPageSafeSearch() {

    if (!String.prototype.trim) {
      String.prototype.trim = function () {
        return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
      };
    }
	var param = document.getElementById("param-text").value;
    var e = document.getElementById("block-page-search-text").value;
    if (e.trim().length > 0) {
        var g = "https://nortonsafe.search.ask.com/web?o=15528&q="
        setTimeout(function() {
					
					var redirectUrl=g + encodeURIComponent(e)+param;
					
					var telemetryConstants = {};
					telemetryConstants.BROWSER =
					{
						CHROME: 'Chrome',
						IE: 'IE'
					};

					telemetryConstants.ACTION_TYPE =
					{
						SEARCH_CLICKED: 'search_query'				
					};
					telemetryConstants.PAGE_TYPE =
					{
						BLOCK_PAGE: 'blockpage'			
					};	
					telemetryConstants.parameters = {
						EVENT: "t",
						CATEGORY: "ec",
						ACTION: "ea",
						LABEL: "el",
						CAMPAIGNMEDIUM: "cm",
						CAMPAIGNSOURCE: "cs",
						APPVERSION: "av",
						APPNAME:"an"
						
					};

					telemetryConstants.HIT_TYPE = {
						PAGE_VIEW: 'pageview',
						SCREEN_VIEW: 'screenview',
						EVENT: 'event',
						EXCEPTION: 'exception'
					};

					telemetryConstants.GA_INIT = {
						TRACKING_ID: 'UA-12436054-58',
						VERSION: '1',                                       // The protocol version. This value should be 1.
						HOST: 'https://www.google-analytics.com/collect',
						POST: 'POST'
					};


					telemetryConstants.defaultParameters = {
						VERSION: 'v',
						TRACKING_ID: 'tid',
						CLIENT_ID: 'cid'
					};

					var telemetry = {};
					telemetry.defaultParameters = null;
					telemetry.initialised = false;

					var telemetryWrapper = {};
					
					telemetryWrapper.initGAParameters = function (tracking_id,guid) {

						if (!tracking_id)
							return false;

						if (!guid)
							return false;


						var defaultParameterList = {};

						defaultParameterList[telemetryConstants.defaultParameters.VERSION] = telemetryConstants.GA_INIT.VERSION;
						defaultParameterList[telemetryConstants.defaultParameters.TRACKING_ID] = tracking_id;
						defaultParameterList[telemetryConstants.defaultParameters.CLIENT_ID] = guid;
						

						var defaultParameterMsgBody = telemetryWrapper.constructMessageBody(defaultParameterList);
						if (null === defaultParameterMsgBody)
							return false;

						telemetry.defaultParameters = defaultParameterMsgBody;
						telemetry.initialised = true;

						return true;

					}

					
					// parase the parameter and create json object list
					var parseQueryString = function( queryString ) {
						var params = {}, queries, keyVal,tempUrl,i, l;

						tempUrl =  queryString.split("?");
						if(tempUrl.length<2)
							return 'Default';
						queryString= tempUrl[1];
						
						// Split into key/value pairs
						queries = queryString.split("&");

						// Convert the array of strings into an object
						for ( i = 0, l = queries.length; i < l; i++ ) {
							keyVal = queries[i].split('=');
							params[keyVal[0].toLowerCase()] = keyVal[1];
						}
						return params;
					};

					telemetryWrapper.send = function (category, action, label,campaingMeduim,campaingSource,appversion,appname) {

						if (!category)
							return false;

						if (!action)
							return false;

						if (!label)
							return false;

						if(!campaingMeduim)
							return false;

						if(!campaingSource)
								return false;
							
						if(!appversion)
								return false;	

					  if(!appname)
						 return false;	
					
						
						if (!telemetry.defaultParameters)
							return false;

						var parameterList = {};

						parameterList[telemetryConstants.parameters.EVENT] = telemetryConstants.HIT_TYPE.EVENT;
						parameterList[telemetryConstants.parameters.CATEGORY] = category;
						parameterList[telemetryConstants.parameters.ACTION] = action;
						parameterList[telemetryConstants.parameters.LABEL] = label;
						parameterList[telemetryConstants.parameters.CAMPAIGNMEDIUM] = campaingMeduim;
						parameterList[telemetryConstants.parameters.CAMPAIGNSOURCE] = campaingSource;
						parameterList[telemetryConstants.parameters.APPVERSION] = appversion;
						parameterList[telemetryConstants.parameters.APPNAME] = appname;

						var request = new XMLHttpRequest();
						if (null === request)
							return false;
						request.open(telemetryConstants.GA_INIT.POST,
									 telemetryConstants.GA_INIT.HOST, true);

						var msgBody = telemetryWrapper.constructMessageBody(parameterList);
						if (null === msgBody)
							return false;

						msgBody += "&" + telemetry.defaultParameters;
						request.send(msgBody);

						return true;

					}

					telemetryWrapper.constructMessageBody = function (parameters) {

						if (!parameters) {
							return null;
						}

						if (Object.keys(parameters).length === 0) {
							return null;
						}

						var messageBody = "";
						for (var prop in parameters) {
							messageBody += prop + "=" + parameters[prop] + "&";
						}

						if (messageBody.length < 0)
							return null;

						messageBody = messageBody.substring(0, messageBody.length - 1);

						return messageBody;
					};


					
					
					function sendTelemetryForChrome() {
					var paramObj = parseQueryString(redirectUrl);
					//sample data "https://nortonsafe.search.ask.com/web?o=15528&q=sdsfd&prt=NSBU&chn=1000&geo=US&ver=22.10.1.8&locale=en_US&tpr=111&guid=samegui"
						if (!telemetry.initialised) {
								  if (!telemetryWrapper.initGAParameters(telemetryConstants.GA_INIT.TRACKING_ID,paramObj.guid)){
									return; }
						}
						telemetryWrapper.send(telemetryConstants.PAGE_TYPE.BLOCK_PAGE,
											  telemetryConstants.ACTION_TYPE.SEARCH_CLICKED,
																		paramObj.doi, paramObj.chn, paramObj.prt,paramObj.ver,telemetryConstants.BROWSER.CHROME)
																		
					}


					sendTelemetryForChrome();
				
				
					window.location.href = redirectUrl;
        }, 500);
    }
};
