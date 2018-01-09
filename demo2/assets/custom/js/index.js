layui.config({
    base: '/assets/custom/js/',
}).use('element', function () {
    var $ = layui.jquery;
    $(document).ajaxSuccess(function (event, xhr, settings) {
        var session_status = xhr.getResponseHeader("session-status");
        if (session_status == "timeout") {
            window.location.href = "/system/logout";
        }
    });
});
