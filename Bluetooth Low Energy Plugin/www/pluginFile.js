

var ble = {
    
setup: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "load",
                        [resultType]);
}
};


var search = {
    
callBlePSearch: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "blePSearch",
                        [resultType]);
}
};

var connect = {
    
callBlePConnect: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "blePConnect",
                        [resultType]);
}
};

var disconnect = {
    
callBlePDisconnect: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "blePDisconnect",
                        [resultType]);
}
};

var serviceScan = {
    
callBlePServiceScan: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "blePServiceScan",
                        [resultType]);
}
};


var notify = {
    
callBlePNotify: function (success, fail, resultType) {
    return Cordova.exec( success, fail,
                        "org.test.kristina.blePlugin",
                        "blePNotify",
                        [resultType]);
}
};

