<div id="pic_div_{{=id}}" class="col-sm-6 col-md-4">
    <div class="thumbnail" data-id="{{=id}}">
        <input type="hidden" id="pic_path_{{=id}}" name="pic_path_{{=id}}" value="{{=pic_path}}">
        <input type="hidden" id="pic_name_{{=id}}" name="pic_name_{{=id}}" value="{{=pic_name}}">
        <img id="pic_img_{{=id}}" src="{{=pic_url}}" style="width: 100%; height: 150px; display: block;">
        <div class="caption">
            <a id="pic_edit_{{=id}}" href="javascript:;" class="btn btn-xs blue" data-sign="edit" data-id="{{=id}}"> 修改 </a>
            <a href="javascript:;" class="btn btn-xs red" data-sign="del" data-id="{{=id}}"> 删除 </a>
        </div>
    </div>
</div>