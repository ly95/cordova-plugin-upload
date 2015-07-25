var exec = require('cordova/exec');
var platform = require('cordova/platform');

module.exports = {
    FileUpload: function () {
        cordova.exec(function(msg) {
        	alert(msg);
        }, null, "FileUpload", "upload", []);
    }
};
