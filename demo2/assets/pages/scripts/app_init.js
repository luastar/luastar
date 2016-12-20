var AppInit = function () {

    var handleSeajs = function () {
        seajs.config({
            // Sea.js 的基础路径
            base: "/assets/",
            // 文件编码
            charset: 'utf-8'
        });
    }

    var handleTemplate = function () {
        // 将模板匹配字符改为{{}}
        _.templateSettings = {
            evaluate: /\{\{([\s\S]+?)\}\}/g,
            interpolate: /\{\{=([\s\S]+?)\}\}/g,
            escape: /\{\{-([\s\S]+?)\}\}/g
        };
    }

    var handleToastr = function () {
        // 提示消息插件
        toastr.options = {
            "closeButton": true,
            "debug": false,
            "positionClass": "toast-top-right",
            "onclick": null,
            "showDuration": "1000",
            "hideDuration": "1000",
            "timeOut": "2000",
            "extendedTimeOut": "1000",
            "showEasing": "swing",
            "hideEasing": "linear",
            "showMethod": "fadeIn",
            "hideMethod": "fadeOut"
        }
    }

    return {
        init: function () {
            handleSeajs();
            handleTemplate();
            handleToastr();
        }
    }

}();