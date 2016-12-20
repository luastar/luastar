<span data-sign="op_row" data-id="{{=id}}"  data-name="{{=name}}">
    {{ _.each(ops, function(op){ }}
    <a href="javascript:void(0);" class="btn btn-xs {{=op.color}}" data-sign="{{=op.sign}}" data-id="{{=op.id}}" data-name="{{=op.name}}">{{=op.btnName}}</a>
    {{ }); }}
</span>