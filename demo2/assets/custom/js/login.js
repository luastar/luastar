layui.use(['form', 'layer'], function () {
    var $ = layui.jquery, form = layui.form;
    // 显示错误信息
    var message = $('body').data('message');
    if (message.length > 0) {
        layer.msg('登录失败：' + message, {icon: 5, anim: 6});
    }
    // 提交
    form.on('submit(login)', function (data) {
        // 当前容器的全部表单字段，名值对形式：{name: value}
        console.log(data.field);
        return true;
    });
});
