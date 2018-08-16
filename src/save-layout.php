<?php
$filename = md5(time().rand(0,9)).'.jpg';
$data = file_get_contents('php://input');

$file = fopen("asset/image/".$filename, "w");//打开文件准备写入

fwrite($file, $data);//写入

fclose($file);//关闭

echo '{"code":1, "message":"上传成功", "data":{"id":1, "photo":"'.$filename.'"}}';
?>