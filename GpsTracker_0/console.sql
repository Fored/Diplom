CREATE TABLE tab1 (NAME VARCHAR(100), MAIN_CLASS  INTEGER);
CREATE TABLE `chat` (
  `_id` int(11) NOT NULL AUTO_INCREMENT,
  `author` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `client` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `data` bigint(20) NOT NULL,
  `text` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`_id`)
);
CREATE TABLE `coordinate` (
  `user` int(5) NOT NULL,
  `datetime` DATETIME NOT NULL,
  `latitude` FLOAT(6,4) NOT NULL,
  `longitude` FLOAT(7,4) NOT NULL,
  PRIMARY KEY (`user`, `datetime`),
  FOREIGN KEY (`user`) REFERENCES `Users`(id)
);
CREATE TABLE `Users` (
  `id` int(5) AUTO_INCREMENT,
  `login` VARCHAR(20) NOT NULL,
  `password` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`)
);
CREATE TABLE `vk_friend` (
  `id_1` INT,
  `id_2` INT,
  PRIMARY KEY (`id_1`, `id_2`)
);

CREATE TABLE `followers` (
  `id_user` INT(5) NOT NULL,
  `id_follower` INT(5) NOT NULL,
  `sab_date` DATETIME NOT NULL,
  PRIMARY KEY (`id_user`, `id_follower`),
  FOREIGN KEY (`id_user`) REFERENCES `Users`(`id`),
  FOREIGN KEY (`id_follower`) REFERENCES `Users`(`id`)
);

CREATE TABLE `request` (
  `id_user` INT(5) NOT NULL,
  `id_follower` INT(5) NOT NULL,
  `request_date` DATETIME NOT NULL,
  PRIMARY KEY (`id_user`, `id_follower`)
);
ALTER TABLE coordinate ADD FOREIGN KEY(user) REFERENCES Users(id)
DELIMITER //
CREATE FUNCTION func (pid INT) RETURNS VARCHAR(20)
  BEGIN
    DECLARE ppid INT DEFAULT 4;
    IF (ppid > pid) THEN
      RETURN 'Good';
    ELSE
      RETURN 'Bad';
    END IF;
  END;
//
DELIMITER ;
SELECT func(3);
DROP FUNCTION func;

DELIMITER //
CREATE FUNCTION signup (pLog VARCHAR(20), pPass VARCHAR(20)) RETURNS INT
  BEGIN
    DECLARE vYesUser INT;
    SELECT COUNT(*) FROM Users WHERE login = pLog INTO vYesUser;
    IF (vYesUser = 0) THEN
      INSERT INTO Users (login, password) VALUES (pLog, pPass);
      SELECT id FROM Users WHERE login = pLog INTO vYesUser;
      RETURN vYesUser;
    ELSE
      RETURN 0;
    END IF;
  END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION findUser (log_user VARCHAR(20), id_f INT) RETURNS INT
  BEGIN
    DECLARE vYesUser INT;
    DECLARE vYesFollower INT;
    SELECT id FROM Users WHERE login = log_user INTO vYesUser;
    IF (vYesUser IS NULL) THEN
      RETURN 0;
    ELSE
      IF (vYesUser = id_f) THEN
        RETURN -3;
      ELSE
        SELECT COUNT(*) FROM followers WHERE id_user = vYesUser AND id_follower = id_f INTO vYesFollower;
        IF (vYesFollower = 0) THEN
          SELECT COUNT(*) FROM request WHERE id_user = vYesUser AND id_follower = id_f INTO vYesFollower;
          IF (vYesFollower = 0) THEN
            RETURN vYesUser;
          ELSE
            RETURN -2;
          END IF;
        ELSE
          RETURN -1;
        END IF;
      END IF;
    END IF;
  END;
//
DELIMITER ;

(SELECT *, TIMEDIFF(tab1.datetime, tab2.datetime) FROM
  (SELECT datetime , @rownum := @rownum + 1 AS rank
    FROM coordinate, (SELECT @rownum := 0) r
    WHERE user = 2 ORDER BY datetime DESC) AS tab1 RIGHT OUTER JOIN
  (SELECT datetime, @rownum2 := @rownum2 + 1 AS rank
    FROM coordinate, (SELECT @rownum2 := 0) r
    WHERE user = 2 ORDER BY datetime DESC)  AS tab2 ON tab1.rank = tab2.rank-1
WHERE TIMEDIFF(tab1.datetime, tab2.datetime) > '01:00:00' OR TIMEDIFF(tab1.datetime, tab2.datetime) IS NULL)
UNION
(SELECT MIN(datetime), NULL, NULL FROM coordinate WHERE user = 2);



SELECT * FROM coordinate AS A JOIN coordinate AS B ON A.datetime = (SELECT MIN(datetime) FROM B WHERE datetime > A.datetime);
DELIMITER //
CREATE PROCEDURE routes (pUser INT, pLimit INT)
  BEGIN
    DECLARE vN INT DEFAULT pLimit;
    DECLARE vStart DATETIME;
    DECLARE vFinish DATETIME;
    CREATE TEMPORARY TABLE IF NOT EXISTS `temp` (Start DATETIME, Finish DATETIME);
    WHILE vN > 0
    DO
      SET vN = vN - 1;
      SELECT MAX(datetime) FROM coordinate WHERE user = pUser INTO vFinish;
    END WHILE;

    DROP TEMPORARY TABLE temp;
  END;
//
DELIMITER ;


DROP FUNCTION signup;
SELECT signup('fff7', 'fff');
SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES



INSERT INTO Users (login, password) VALUES ('fored', 'fored');
INSERT INTO coordinate (user, datetime, latitude, longitude) VALUES (1, '2016-03-07 01:00:50', 59.9908, 59.9908);
DROP TABLE coordinate;
DELETE FROM coordinate;