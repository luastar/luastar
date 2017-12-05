layui.use(['form', 'table', 'layer', 'laytpl'], function () {
    var $ = layui.jquery, form = layui.form, table = layui.table, layer = layui.layer, laytpl = layui.laytpl;

    var tpl_user_status = '<div>'
        + '{{# if(d.isEffective == 1){ }}'
        + '<span class="layui-badge layui-bg-blue">有效</span>'
        + '{{# }else{ }}'
        + '<span class="layui-badge layui-bg-gray">无效</span>'
        + '{{# } }}'
        + '</div>';

    var tpl_table_operate = '<div>'
        + '<a class="layui-btn layui-btn-xs" lay-event="trigger">修改</a>'
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
});