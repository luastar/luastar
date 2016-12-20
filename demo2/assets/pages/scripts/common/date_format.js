/**
 * 格式化时间戳
 * @param date
 * @param fmt
 * @returns {*}
 */
define(function (require, exports, module) {

    var DateFormat = function () {
    }

    DateFormat.prototype.format = function (date, fmt) {
        var that = this;
        return fmt.replace(/%([a-zA-Z])/g, function (_, fmtCode) {
            //1927-12-31 00:0:52（-1325664000000）后就没问题
            if (date.getTime() < -1325664000000) {
                date = new Date(date.getTime() + (1325664352000 - 1325664000000));
            }
            switch (fmtCode) {
                case 'Y':
                    return date.getFullYear();
                case 'M':
                    return that.pad(date.getMonth() + 1);
                case 'd':
                    return that.pad(date.getDate());
                case 'H':
                    return that.pad(date.getHours());
                case 'm':
                    return that.pad(date.getMinutes());
                case 's':
                    return that.pad(date.getSeconds());
                default:
                    throw new Error('Unsupported format code: ' + fmtCode);
            }
        });
    }

    DateFormat.prototype.pad = function (value) {
        return (value.toString().length < 2) ? '0' + value : value;
    }

    module.exports = DateFormat;
});
