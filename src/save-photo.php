<?php
$hash = md5(time().rand(0,9).$_FILES["Filedata"]["name"]);
$ext = pathinfo($_FILES["Filedata"]["name"],PATHINFO_EXTENSION);
$filename = $hash.'.'.$ext;
$fullpath = "asset/image/".$filename;
if(move_uploaded_file($_FILES["Filedata"]["tmp_name"],  $fullpath)){
    echo "{\"code\":1, \"message\":\"上传成功\", \"data\":{\"id\":\"".$hash."\", \"photo\":\"".$fullpath."\", \"type\":\"".$_FILES["Filedata"]["type"]."\"}}";
}else{
    echo "{\"code\":1001, \"message\":\"上传失败\", \"type\":\"".$_FILES["Filedata"]["type"]."\"}";
}