/*global chrome */
var coIDSafe = (function () {
    "use strict";
    var listExtensions = [ "nppllibpnmahfaklnpggkibhkapjkeob", // IDSafe 8.x
                    "mkfokfffehpeedafpekjeddnmnjhmcmk", // NIS/N360 21.x
                    "bejnhdlplbjhffionohbdnpcbobfejcc", // NIS/N360 20.x
                    "cjabmdjcfcfdmffimndhafhblfmpjdpe"], // NIS/N360 22.x
        IDSVAULT = 3,
        i = 0;
    chrome.runtime.onMessageExternal.addListener(function (request, sender, sendResponse) {
        if (listExtensions.indexOf(sender.id) !== -1) {
            if (request.getExtensionFeature) {
                sendResponse({feature: IDSVAULT});
            }
        } else {
            // return only if we are not sending the response
            return;
        }
    });

    // If the slave extension is installed after installing the master extension then we need to send the feature details to the master extension
    for (i = 0; i < listExtensions.length; i = i + 1) {
        chrome.runtime.sendMessage(listExtensions[i], {setExtensionFeature: IDSVAULT});
    }
}());