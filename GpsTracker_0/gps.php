<?php // сохранить в utf-8 !
// ---------------------------------------------------------- эти значения задавались при создании БД на сервере
$mysql_host = "foredev.heliohost.org"; // sql сервер
$mysql_user = "foredev_fored"; // пользователь
$mysql_password = "marita"; // пароль
$mysql_database = "foredev_gps"; // имя базы данных chat

// ---------------------------------------------------------- проверяем переданные в строке запроса параметры
// например ...chat.php?action=select
//-----------------------------------------------------------
// переменная action может быть:
// select - формируем содержимое таблицы chat в JSON и отправляем назад
// insert - встваляем новую строку в таблицу chat, так же нужны 4 параметра : автор/получатель/время создания/сообщение
// ВАЖНО время создания мы не передаем в параметрах, его берем текущее на сервере
// delete - удаляет ВСЕ записи из таблицы chat - пусть будет для быстрой очистки

// ------------------------------------------- получим переданный action
if (isset($_GET["action"])) { 
    $action = $_GET['action'];
}
// ------------------------------------------- если action=insert тогда получим еще author|client|text
if (isset($_GET["user"])) { 
    $user = $_GET['user'];
}
if (isset($_GET["datetime"])) { 
    $datetime = $_GET['datetime'];
}
if (isset($_GET["latitude"])) { 
    $latitude = $_GET['latitude'];
}
// ------------------------------------------- если action=select тогда получим еще data - от после какого времени передавать ответ
if (isset($_GET["longitude"])) { 
    $longitude = $_GET['longitude'];
}



mysql_connect($mysql_host, $mysql_user, $mysql_password); // коннект к серверу SQL
mysql_select_db($mysql_database); // коннект к БД на сервере
mysql_set_charset('utf8'); // кодировка
// ------------------------------------------------------------ обрабатываем запрос если он был
if($action == select){ // если действие SELECT

if($data == null){
// выберем из таблицы chat ВСЕ данные что есть и вернем их в JSON
$q=mysql_query("SELECT * FROM coordinate");


}else{
	
// выберем из таблицы chat ВСЕ данные ПОЗНЕЕ ОПРЕДЕЛЕННОГО ВРЕМЕНИ и вернем их в JSON
$q=mysql_query("SELECT * FROM chat WHERE data > $data");	
	
}
while($e=mysql_fetch_assoc($q))
        $output[]=$e;
print(json_encode($output));

}


if($action == insert && $user != null && $datetime != null && $latitude != null && $longitude != null){ // если действие INSERT и есть все что нужно

// время = время сервера а не клиента !
//$current_time = round(microtime(1) * 1000);
// пример передачи скрипту данных:
// http://andreidanilevich.comoj.com/chat.php?action=insert&author=author&client=client&text=text
// вставим строку с переданными параметрами
mysql_query("INSERT INTO `coordinate`(`user`,`datetime`,`latitude`,`longitude`) VALUES ('$user','$datetime','$latitude','$longitude')");
print ("ok");
}


if($action == delete){ // если действие DELETE
// полностью обнулим таблицу записей
mysql_query("TRUNCATE TABLE `chat`");	
}

mysql_close();
?>