<?php // ��������� � utf-8 !
// ---------------------------------------------------------- ��� �������� ���������� ��� �������� �� �� �������
$mysql_host = "foredev.heliohost.org"; // sql ������
$mysql_user = "foredev_fored"; // ������������
$mysql_password = "marita"; // ������
$mysql_database = "foredev_gps"; // ��� ���� ������ chat

// ---------------------------------------------------------- ��������� ���������� � ������ ������� ���������
// �������� ...chat.php?action=select
//-----------------------------------------------------------
// ���������� action ����� ����:
// select - ��������� ���������� ������� chat � JSON � ���������� �����
// insert - ��������� ����� ������ � ������� chat, ��� �� ����� 4 ��������� : �����/����������/����� ��������/���������
// ����� ����� �������� �� �� �������� � ����������, ��� ����� ������� �� �������
// delete - ������� ��� ������ �� ������� chat - ����� ����� ��� ������� �������

// ------------------------------------------- ������� ���������� action
if (isset($_GET["action"])) { 
    $action = $_GET['action'];
}
// ------------------------------------------- ���� action=insert ����� ������� ��� author|client|text
if (isset($_GET["user"])) { 
    $user = $_GET['user'];
}
if (isset($_GET["datetime"])) { 
    $datetime = $_GET['datetime'];
}
if (isset($_GET["latitude"])) { 
    $latitude = $_GET['latitude'];
}
// ------------------------------------------- ���� action=select ����� ������� ��� data - �� ����� ������ ������� ���������� �����
if (isset($_GET["longitude"])) { 
    $longitude = $_GET['longitude'];
}



mysql_connect($mysql_host, $mysql_user, $mysql_password); // ������� � ������� SQL
mysql_select_db($mysql_database); // ������� � �� �� �������
mysql_set_charset('utf8'); // ���������
// ------------------------------------------------------------ ������������ ������ ���� �� ���
if($action == select){ // ���� �������� SELECT

if($data == null){
// ������� �� ������� chat ��� ������ ��� ���� � ������ �� � JSON
$q=mysql_query("SELECT * FROM coordinate");


}else{
	
// ������� �� ������� chat ��� ������ ������ ������������� ������� � ������ �� � JSON
$q=mysql_query("SELECT * FROM chat WHERE data > $data");	
	
}
while($e=mysql_fetch_assoc($q))
        $output[]=$e;
print(json_encode($output));

}


if($action == insert && $author != null && $client != null && $text != null){ // ���� �������� INSERT � ���� ��� ��� �����

// ����� = ����� ������� � �� ������� !
$current_time = round(microtime(1) * 1000);
// ������ �������� ������� ������:
// http://andreidanilevich.comoj.com/chat.php?action=insert&author=author&client=client&text=text
// ������� ������ � ����������� �����������
mysql_query("INSERT INTO `chat`(`author`,`client`,`data`,`text`) VALUES ('$author','$client','$current_time','$text')");

}


if($action == delete){ // ���� �������� DELETE
// ��������� ������� ������� �������
mysql_query("TRUNCATE TABLE `chat`");	
}

mysql_close();
?>