/*global chrome */
/*global document */
var coIDSafe = (function () {
    "use strict";
    // update the portal page with the extension id so that the portal can display the extension status
    var updatePortalPage = function () {
        var id = 'extension-is-installed-' + chrome.runtime.id,
            isInstalledNode = document.createElement("div");
        isInstalledNode.setAttribute('style', 'display: none;');
        isInstalledNode.id = id;
        if (document.body) {
            document.body.appendChild(isInstalledNode);
        }
    };

    document.addEventListener("DOMContentLoaded", function (event) {
        updatePortalPage();
    });
}());