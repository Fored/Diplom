<?php // сохранить в utf-8 !

if (isset($_GET["action"])) { 
    $action = $_GET['action'];
}
if (isset($_GET["user"])) { 
    $user = $_GET['user'];
}
if (isset($_GET["datetime"])) { 
    $datetime = $_GET['datetime'];
}
if (isset($_GET["latitude"])) { 
    $latitude = $_GET['latitude'];
}
if (isset($_GET["longitude"])) { 
    $longitude = $_GET['longitude'];
}
if (isset($_GET["login"])) { 
    $login = $_GET['login'];
}
if (isset($_GET["password"])) { 
    $password = $_GET['password'];
}
if (isset($_GET["min"])) { 
    $min = $_GET['min'];
}
if (isset($_GET["max"])) { 
    $max = $_GET['max'];
}
if (isset($_GET["follower"])) { 
    $follower = $_GET['follower'];
}

if (empty($action)){
print ("ok");
}
/* Подключение к серверу MySQL */ 
$mysqli = new mysqli('localhost','id3374195_u698350292_fored','u698350292_fored','id3374195_u698350292_wharu');
$myArray = array();

if($action == 'signup') {
	$result = $mysqli->query("SELECT signup('$login', '$password')");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}

if($action == 'login') {
	$result = $mysqli->query("SELECT COUNT(*), id FROM Users WHERE login = '$login' AND password = '$password'");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}

//получить токен и секрет (user)
if($action == 'gettoken') {
	$result = $mysqli->query("SELECT access_token, secret FROM Users WHERE id = '$user'");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}

if($action == 'max') {
	$result = $mysqli->query("SELECT MAX(datetime) FROM coordinate WHERE user = '$user'");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}

if($action == 'insert' && $user != null && $datetime != null && $latitude != null && $longitude != null){ // если действие INSERT и есть все что нужно
$mysqli->query("INSERT INTO `coordinate`(`user`,`datetime`,`latitude`,`longitude`) VALUES ('$user','$datetime','$latitude','$longitude')");
print ("ok");
}
// user; min; max;
if ($action == 'select') {
	$result = $mysqli->query("SELECT latitude, longitude, datetime FROM coordinate WHERE datetime >= '$min' AND user = $user AND datetime <= '$max' ORDER BY datetime");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//получить последнии точки друзей(user)
if ($action == 'enddots') {
	$result = $mysqli->query("SELECT user, MAX(datetime) as max, latitude, longitude FROM coordinate WHERE user IN (SELECT id_user FROM followers where id_follower = $user) GROUP BY (user) ");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//получить список пользователей за которыми можем наблюдать (user)
if ($action == 'getfriend') {
	$result = $mysqli->query("SELECT id, login, id_vk FROM Users WHERE id = $user");
	$row = $result->fetch_array(MYSQL_ASSOC);
	$myArray[] = $row;
	$result = $mysqli->query("SELECT id, login, id_vk FROM Users WHERE id IN (SELECT id_user FROM followers where id_follower = $user)");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//ищем пользователей (login)
if ($action == 'finduser') {
	$result = $mysqli->query("SELECT findUser('$login', $follower)");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
// Делаем запрос на подписку (user, follower, datetime)
if ($action == 'request') {
	$mysqli->query("INSERT INTO `request` (`id_user`, `id_follower`, `request_date`) VALUES ($user, $follower, '$datetime')");
}
//Получаем список запросов на подписку
if ($action == 'getrequest') {
	$result = $mysqli->query("SELECT id, login FROM Users WHERE id IN (SELECT id_follower FROM request where id_user = $user)");
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//Предоставляем доcтуп(user, follower, datetime)
if ($action == 'giveaccessyes') {
	$mysqli->query("INSERT INTO `followers` (`id_user`, `id_follower`, `sab_date`) VALUES ($user, $follower, '$datetime')");
	$mysqli->query("DELETE FROM `request` WHERE `id_user` = $user AND `id_follower` = $follower");
}
if ($action == 'giveaccessno') {
	$mysqli->query("DELETE FROM `request` WHERE `id_user` = $user AND `id_follower` = $follower");
}
//Список маршрутов (user)
if ($action == 'routes') {
	$sql = "(SELECT tab1.datetime s, tab2.datetime f, TIMEDIFF(tab1.datetime, tab2.datetime) dif FROM\n"
    . " (SELECT datetime , @rownum := @rownum + 1 AS rank\n"
    . " FROM coordinate, (SELECT @rownum := 0) r\n"
    . " WHERE user = 2 ORDER BY datetime DESC) AS tab1 RIGHT OUTER JOIN\n"
    . " (SELECT datetime, @rownum2 := @rownum2 + 1 AS rank\n"
    . " FROM coordinate, (SELECT @rownum2 := 0) r\n"
    . " WHERE user = 2 ORDER BY datetime DESC) AS tab2 ON tab1.rank = tab2.rank-1\n"
    . "WHERE TIMEDIFF(tab1.datetime, tab2.datetime) > '01:00:00' OR TIMEDIFF(tab1.datetime, tab2.datetime) IS NULL)\n"
    . "UNION\n"
    . "(SELECT MIN(datetime), NULL, NULL FROM coordinate WHERE user = 2)\n"
    . "";
	$result = $mysqli->query($sql);
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//записать токен (user, access_token, id_vk, secret)
if ($action == 'settoken') {
	$access_token = $_GET['access_token'];
	$id_vk = $_GET['id_vk'];
	$secret = $_GET['secret'];
	$mysqli->query("UPDATE Users SET access_token = '$access_token', id_vk = $id_vk, secret = '$secret' WHERE id = $user");
}

//получаем совпадения по id_vk (user)
if ($action == 'friendhere') {
	$query = "SELECT login, id_vk FROM Users WHERE id NOT IN (SELECT id_user FROM followers where id_follower = $user) AND id_vk IN (" . $_GET['vk_friend'] . ")";
	$result = $mysqli->query($query);
	while($row = $result->fetch_array(MYSQL_ASSOC)) {
            $myArray[] = $row;
    }
    echo json_encode($myArray);
	$result->close();
}
//записать ФИ и фото (user, first_name, last_name, photo)
/*if ($action == setnamephoto) {
	$first_name = $_GET['first_name'];
	$last_name = $_GET['last_name'];
	$photo = $_GET['photo'];
	$mysqli->query("UPDATE Users SET first_name = '$first_name', last_name = '$last_name', photo = '$photo' WHERE id = $user");
}
/*if (isset($_GET['code'])) {
	$params1 = array(
	'user' => $user
	);
    $params = array(
        'client_id' => '5399798',
        'client_secret' => '9LQOSsVojR0MQvg6Zvq7',
        'code' => $_GET['code'],
        'redirect_uri' => 'http://fored.esy.es/gps.php' . '?' . urldecode(http_build_query($params1))
    );	
	$test = 'https://oauth.vk.com/access_token' . '?' . urldecode(http_build_query($params));
	$token1 = file_get_contents($test);
	$token = json_decode($token1, true);
	$ac = $token['access_token'];
	$us = $token['user_id'];
	$mysqli->query("UPDATE Users SET access_token = '$ac', id_vk = $us WHERE id = $user");
}*/


/* Закрываем соединение */ 
$mysqli->close(); 
/*$mysql_host = "mysql.hostinger.ru"; // sql сервер
$mysql_user = "u698350292_fored"; // пользователь
$mysql_password = "marita"; // пароль
$mysql_database = "u698350292_wharu"; // имя базы данных chat

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
if (isset($_GET["longitude"])) { 
    $longitude = $_GET['longitude'];
}
if (isset($_GET["login"])) { 
    $login = $_GET['login'];
}
if (isset($_GET["password"])) { 
    $password = $_GET['password'];
}



//mysqli_connect($mysql_host, $mysql_user, $mysql_password); // коннект к серверу SQL
//mysqli_select_db($mysql_database); // коннект к БД на сервере
$mysqli = new mysqli('localhost', 'my_user', 'my_password', 'my_db');
if ($mysqli->connect_error) {
    die('Connect Error (' . $mysqli->connect_errno . ') ' . $mysqli->connect_error);
}
mysqli_set_charset('utf8'); // кодировка
// ------------------------------------------------------------ обрабатываем запрос если он был
if($action == select){ // если действие SELECT

	if($data == null){
	// выберем из таблицы chat ВСЕ данные что есть и вернем их в JSON
	$q=mysqli_query("SELECT * FROM coordinate");


	}else{
		
	// выберем из таблицы chat ВСЕ данные ПОЗНЕЕ ОПРЕДЕЛЕННОГО ВРЕМЕНИ и вернем их в JSON
	$q=mysqli_query("SELECT * FROM chat WHERE data > $data");	
		
	}
	while($e=mysqli_fetch_assoc($q))
			$output[]=$e;
	print(json_encode($output));

}


if($action == insert && $user != null && $datetime != null && $latitude != null && $longitude != null){ // если действие INSERT и есть все что нужно

// время = время сервера а не клиента !
//$current_time = round(microtime(1) * 1000);
// пример передачи скрипту данных:
// http://andreidanilevich.comoj.com/chat.php?action=insert&author=author&client=client&text=text
// вставим строку с переданными параметрами
mysqli_query("INSERT INTO `coordinate`(`user`,`datetime`,`latitude`,`longitude`) VALUES ('$user','$datetime','$latitude','$longitude')");
print ("ok");
}

if (empty($action)){
print ("ok");
}

if($action == delete){ // если действие DELETE
// полностью обнулим таблицу записей
mysqli_query("TRUNCATE TABLE `chat`");	
}

if($action == max) {
	$q=mysqli_query("SELECT MAX(datetime) FROM coordinate WHERE user = '$user'");
	while($e=mysqli_fetch_assoc($q))
			$output[]=$e;
	print(json_encode($output));
}

if($action == login) {
	$q=mysqli_query("SELECT COUNT(*), id FROM Users WHERE login = '$login' AND password = '$password'");
	while($e=mysqli_fetch_assoc($q))
			$output[]=$e;
	print(json_encode($output));
}

if($action == signup) {
	$q=mysqli_query("SELECT signup('$login', '$password')");
	while($e=mysqli_fetch_assoc($q))
			$output[]=$e;
	print(json_encode($output));
}

mysqli_close();*/
?>