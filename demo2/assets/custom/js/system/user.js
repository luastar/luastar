layui.use(['form', 'table', 'layer', 'laytpl'], function () {
    var $ = layui.jquery, form = layui.form, table = layui.table, layer = layui.layer, laytpl = layui.laytpl;
    // 用户状态模板
    var tpl_user_status = '<div>'
        + '{{# if(d.isEffective == 1){ }}'
        + '<span class="layui-badge layui-bg-blue">有效</span>'
        + '{{# }else{ }}'
        + '<span class="layui-badge layui-bg-gray">无效</span>'
        + '{{# } }}'
        + '</div>';
    // 操作模板
    var tpl_table_operate = '<div>'
        + '<a class="layui-btn layui-btn-xs" lay-event="edit">修改</a>'
        + '</div>';
    // 表格渲染
    var tableObj = table.render({
        elem: '#table_user',
        url: '/system/user/list',
        height: 'full-230',
        page: true,
        cols: [[
            {field: 'id', title: 'ID', width: "10%"},
            {field: 'loginName', title: '登录名', width: "20%"},
            {field: 'userName', title: '用户名', width: "20%"},
            {field: 'isEffective', title: '状态', width: "20%", align: 'center', templet: tpl_user_status},
            {title: '操作', width: "30%", align: 'center', toolbar: tpl_table_operate}
        ]]
    });
    // 查询
    form.on('submit(btn_query)', function (data) {
        // 当前容器的全部表单字段，名值对形式：{name: value}
        console.log(data.field);
        tableObj.reload({
            where: data.field
        });
        return false; // 阻止表单跳转
    });
    // 新增
    $("#btn_add").on("click", function () {
        var index_loading = layer.load();
        $.ajax({
            url: '/system/user/edit',
            data: {id: 0}
        }).done(function (data, textStatus, jqXHR) {
            layer.open({
                type: 1,
                title: '新增用户',
                area: '600px',
                content: data,
                success: function (layero, index) {
                    form.render();
                    form.on('submit(btn_save)', function (data) {
                        var index_loading_save = layer.load();
                        var roles = [];
                        $('#form_user input[name=roles]:checked').each(function () {
                            roles.push($(this).val());
                        });
                        data.field['roles'] = roles.join(',');
                        console.log(data.field);
                        $.ajax({
                            url: '/system/user/save',
                            method: 'post',
                            dataType : 'json',
                            data: data.field
                        }).done(function (data, textStatus, jqXHR) {
                            if (data.code == '0') {
                                layer.closeAll();
                                layer.msg('保存成功！');
                                tableObj.reload();
                            } else {
                                layer.msg('保存失败：' + data.msg);
                            }
                        }).fail(function (jqXHR, textStatus, errorThrown) {
                            layer.msg('保存失败：' + errorThrown);
                        }).always(function () {
                            layer.close(index_loading_save);
                        });
                        return false;
                    });
                }
            });
        }).fail(function (jqXHR, textStatus, errorThrown) {
            layer.msg('加载失败：' + errorThrown);
        }).always(function () {
            layer.close(index_loading);
        });
    });
    // 监听工具条
    table.on('tool(event_table_user)', function (obj) {
        var layEvent = obj.event;
        if (layEvent === 'edit') {
            var index_loading = layer.load();
            $.ajax({
                url: '/system/user/edit',
                data: {id: obj.data.id}
            }).done(function (data, textStatus, jqXHR) {
                layer.open({
                    type: 1,
                    title: '修改用户',
                    area: '600px',
                    content: data,
                    success: function (layero, index) {
                        form.render();
                        form.on('submit(btn_save)', function (data) {
                            var index_loading_save = layer.load();
                            var roles = [];
                            $('#form_user input[name=roles]:checked').each(function () {
                                roles.push($(this).val());
                            });
                            data.field['roles'] = roles.join(',');
                            console.log(data.field);
                            $.ajax({
                                url: '/system/user/save',
                                method: 'post',
                                dataType : 'json',
                                data: data.field
                            }).done(function (data, textStatus, jqXHR) {
                                if (data.code == '0') {
                                    layer.closeAll();
                                    layer.msg('保存成功！');
                                    tableObj.reload();
                                } else {
                                    layer.msg('保存失败：' + data.msg);
                                }
                            }).fail(function (jqXHR, textStatus, errorThrown) {
                                layer.msg('保存失败：' + errorThrown);
                            }).always(function () {
                                layer.close(index_loading_save);
                            });
                            return false;
                        });
                    }
                });
            }).fail(function (jqXHR, textStatus, errorThrown) {
                layer.msg('加载失败：' + errorThrown);
            }).always(function () {
                layer.close(index_loading);
            });
        }
    });

});