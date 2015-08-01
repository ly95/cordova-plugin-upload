# cordova-plugin-upload

Cordova 上传多图插件，目前只支持IOS。

参考 https://github.com/apache/cordova-plugin-file-transfer

# 支持

- IOS

# 安装

    cordova plugin add https://github.com/ly95/cordova-plugin-upload.git

# 例子

    var url = 'http://';
    var uploadImages = [
        'file://var/....',
        'http://www....'
    ];
    var params = {
        'token': '....'
    };
    cordova.exec(function (data) {
        var res = JSON.parse(data);
        console.log(res)
    }, function (error) {
        console.log(error);
    }, "FileUpload", "upload", [url, uploadImages, params]);

# Todo

- Javascript
