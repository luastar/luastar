define(function (require, exports, module) {

    var tpl_modal = '<!-- tabindex is required for focus -->' +
        '<div id="{{=id}}" class="modal fade" tabindex="-1">' +
        '<div class="modal-header">' +
        '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>' +
        '<h4 class="modal-title">{{=title}}</h4>' +
        '</div>' +
        '<div class="modal-body">{{=body}}</div>' +
        '<div class="modal-footer">' +
        '<a href="#" data-dismiss="modal" class="btn btn-default">关闭</a>' +
        '{{ _.each(btnAry, function(btn){ }}' +
        '<a href="javascript:;" id="{{=btn.id}}" class="btn {{=btn.color}}">{{=btn.name}}</a>' +
        '{{ }); }}' +
        '</div>' +
        '</div>';

    $.fn.modal.defaults.spinner = $.fn.modalmanager.defaults.spinner =
        '<div class="loading-spinner" style="width: 200px; margin-left: -100px;">' +
        '<div class="progress progress-striped active">' +
        '<div class="progress-bar" style="width: 100%;"></div>' +
        '</div>' +
        '</div>';
    $.fn.modalmanager.defaults.resize = true;

    module.exports = {

        /**
         {
             id: "modal_rule_con",
             title: "",
             body: "",
             btnAry: [{
                 id: "",
                 color: "blue",
                 name: "保存",
                 handler: function () {

                 }
             }]
         }
         */
        createModal: function (data) {
            data = $.extend({
                id: "modal_001",
                title: "",
                body: "",
                btnAry: []
            }, data);
            var $modal = $("#" + data.id);
            if ($modal.length > 0) {
                return $modal;
            }
            $("body").append(_.template(tpl_modal)(data));
            return $("#" + data.id);
        }

    };

});