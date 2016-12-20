define(function (require, exports, module) {

    var UserEdit = function () {
        this.el_content_edit = "#content_user_edit";
        this.el_div_edit = "#div_user_edit";
        this.el_form = "#form_user";
        this.el_btn_save = "#btn_user_save";
        this.el_btn_back = "#btn_user_back";
    }

    UserEdit.prototype.init = function () {
        this.show();
        this.loadContent();
    }

    UserEdit.prototype.setOptions = function (options) {
        this.options = $.extend(this.options, options);
    }

    UserEdit.prototype.show = function () {
        $('div[data-sign="content"]').hide();
        $(this.el_content_edit).show();
    }

    UserEdit.prototype.loadContent = function () {
        var that = this;
        var url = "/system/user/edit " + this.el_form;
        var params = {id: this.options.id};
        $(this.el_div_edit).empty();
        App.blockUI({target: ".page-content"});
        $(this.el_div_edit).load(url, params, function (responseText, textStatus, XMLHttpRequest) {
            App.unblockUI(".page-content");
            that.loadContentFinish();
        });
    }

    UserEdit.prototype.loadContentFinish = function () {
        // 初始化事件
        this.initEvents();
        // 初始化校验组件
        this.initValidate();
        // 初始化表单
        App.initComponents();
    }

    UserEdit.prototype.initEvents = function () {
        var that = this;
        $(this.el_btn_save).off("click").on("click", function () {
            that.btnSave();
        });
        $(this.el_btn_back).off("click").on("click", function () {
            that.options.callback_btnBack();
        });
    }

    UserEdit.prototype.initValidate = function () {
        this.validate = $(this.el_form).validate({
            errorElement: 'span',
            errorClass: 'help-block help-block-error',
            rules: {
                userName: {required: true},
                loginName: {required: true},
                roles: {required: true, minlength: 1}
            },
            messages: {
                userName: {required: "用户名必填！"},
                loginName: {required: "登录名必填！"},
                roles: {required: "请至少选择一个角色！"}
            },
            highlight: function (element) {
                $(element).closest('.form-group').addClass('has-error');
            },
            unhighlight: function (element) {
                $(element).closest('.form-group').removeClass('has-error');
            },
            success: function (label) {
                label.closest('.form-group').removeClass('has-error');
            },
            errorPlacement: function (error, element) { // render error placement for each input type
                if (element.parent(".input-group").size() > 0) {
                    error.insertAfter(element.parent(".input-group"));
                } else if (element.attr("data-error-container")) {
                    error.appendTo(element.attr("data-error-container"));
                } else if (element.parents('.mt-radio-list').size() > 0) {
                    error.appendTo(element.parents('.mt-radio-list').attr("data-error-container"));
                } else if (element.parents('.mt-radio-inline').size() > 0) {
                    error.appendTo(element.parents('.mt-radio-inline').attr("data-error-container"));
                } else if (element.parents('.mt-checkbox-list').size() > 0) {
                    error.appendTo(element.parents('.mt-checkbox-list').attr("data-error-container"));
                } else if (element.parents('.mt-checkbox-inline').size() > 0) {
                    error.appendTo(element.parents('.mt-checkbox-inline').attr("data-error-container"));
                } else {
                    error.insertAfter(element);
                }
            }
        });
    }

    UserEdit.prototype.getFormData = function () {
        var data = {};
        $(this.el_form).find('input[type="hidden"],input[type="text"],input[type="password"],textarea,select').each(function () {
            data[this.name] = $(this).val();
        });
        $(this.el_form).find('input[type="radio"]:checked').each(function () {
            data[this.name] = $(this).val();
        });
        var roles = [];
        $(this.el_form + " input[name=roles]:checked").each(function () {
            roles.push($(this).val());
        });
        data["roles"] = roles.join(",");
        return data;
    }

    UserEdit.prototype.btnSave = function () {
        if (!this.validate.form()) {
            this.validate.focusInvalid();
            return;
        }
        var that = this;
        App.blockUI({message: "正在保存...", target: ".page-content"});
        // 保存请求
        $.ajax({
            url: "/system/user/save",
            type: "post",
            data: that.getFormData(),
            dataType : "json",
            success: function (rsObj, textStatus, jqXHR) {
                App.unblockUI(".page-content");
                if (rsObj.rsCode == "1") {
                    toastr["success"]("保存成功！", "提示信息");
                    if (_.isFunction(that.options.callback_btnSave)) {
                        that.options.callback_btnSave();
                    }
                } else {
                    toastr["error"](rsObj.rsMsg || "保存失败！", "提示信息");
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                App.unblockUI(".page-content");
                toastr["error"](errorThrown, "提示信息");
            }
        });
    }

    module.exports = UserEdit;

});