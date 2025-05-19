-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: auctiondb2
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_emailaddress`
--

DROP TABLE IF EXISTS `account_emailaddress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_emailaddress` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `verified` tinyint(1) NOT NULL,
  `primary` tinyint(1) NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_emailaddress_user_id_email_987c8728_uniq` (`user_id`,`email`),
  KEY `account_emailaddress_email_03be32b2` (`email`),
  CONSTRAINT `account_emailaddress_user_id_2c513194_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_emailaddress`
--

LOCK TABLES `account_emailaddress` WRITE;
/*!40000 ALTER TABLE `account_emailaddress` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_emailaddress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account_emailconfirmation`
--

DROP TABLE IF EXISTS `account_emailconfirmation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_emailconfirmation` (
  `id` int NOT NULL AUTO_INCREMENT,
  `created` datetime(6) NOT NULL,
  `sent` datetime(6) DEFAULT NULL,
  `key` varchar(64) NOT NULL,
  `email_address_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`),
  KEY `account_emailconfirm_email_address_id_5b7f8c58_fk_account_e` (`email_address_id`),
  CONSTRAINT `account_emailconfirm_email_address_id_5b7f8c58_fk_account_e` FOREIGN KEY (`email_address_id`) REFERENCES `account_emailaddress` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_emailconfirmation`
--

LOCK TABLES `account_emailconfirmation` WRITE;
/*!40000 ALTER TABLE `account_emailconfirmation` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_emailconfirmation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_case`
--

DROP TABLE IF EXISTS `auction_case`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_case` (
  `case_number` varchar(100) NOT NULL,
  `case_name` varchar(255) DEFAULT NULL,
  `court_name` varchar(255) DEFAULT NULL,
  `filing_date` date DEFAULT NULL,
  `responsible_dept` varchar(255) DEFAULT NULL,
  `claim_amount` varchar(255) DEFAULT NULL,
  `appeal_status` tinyint(1) DEFAULT NULL,
  `minimum_bid_price` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`case_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_case`
--

LOCK TABLES `auction_case` WRITE;
/*!40000 ALTER TABLE `auction_case` DISABLE KEYS */;
INSERT INTO `auction_case` VALUES ('2022타경1828','부동산강제경매','서울동부지방법원','2022-09-14','경매2계','250,000,000',0,'367,360,000'),('2022타경53920','부동산강제경매','서울서부지방법원','2022-07-15','경매1계','23,225,903',0,'5,494,000'),('2023타경3460','부동산강제경매','서울중앙지방법원','2023-07-12','경매1계','280,000,000',0,'27,659,000'),('2023타경5107','부동산강제경매','서울중앙지방법원','2023-10-19','경매2계','14,452,188',0,'8,406,000');
/*!40000 ALTER TABLE `auction_case` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_item`
--

DROP TABLE IF EXISTS `auction_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_item` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_number` int NOT NULL,
  `item_spec_url` varchar(1000) DEFAULT NULL,
  `item_purpose` varchar(255) DEFAULT NULL,
  `valuation_amount` varchar(255) DEFAULT NULL,
  `item_note` varchar(255) DEFAULT NULL,
  `item_status` varchar(255) DEFAULT NULL,
  `auction_date` datetime(6) DEFAULT NULL,
  `auction_failures` int DEFAULT NULL,
  `item_image_url` varchar(200) DEFAULT NULL,
  `auction_date_1` datetime(6) DEFAULT NULL,
  `decision_date_1` datetime(6) DEFAULT NULL,
  `auction_date_2` datetime(6) DEFAULT NULL,
  `decision_date_2` datetime(6) DEFAULT NULL,
  `auction_date_3` datetime(6) DEFAULT NULL,
  `decision_date_3` datetime(6) DEFAULT NULL,
  `auction_date_4` datetime(6) DEFAULT NULL,
  `decision_date_4` datetime(6) DEFAULT NULL,
  `case_number` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auction_item_item_number_case_number_1c64f79c_uniq` (`item_number`,`case_number`),
  KEY `auction_item_case_number_045353d6_fk_auction_case_case_number` (`case_number`),
  CONSTRAINT `auction_item_case_number_045353d6_fk_auction_case_case_number` FOREIGN KEY (`case_number`) REFERENCES `auction_case` (`case_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_item`
--

LOCK TABLES `auction_item` WRITE;
/*!40000 ALTER TABLE `auction_item` DISABLE KEYS */;
INSERT INTO `auction_item` VALUES (1,1,'142B1FB0AC19061F1831EEE2585761F5','다세대주택','322,000,000','공부상 사무소이나, 현황상 다세대주택으로 이용중임(이와 관련, 위반건축물로 표시됨)','매각공고','2025-05-20 10:00:00.000000',11,NULL,'2024-03-12 10:00:00.000000',NULL,'2024-04-16 10:00:00.000000',NULL,'2024-05-21 10:00:00.000000',NULL,'2024-06-18 10:00:00.000000',NULL,'2023타경3460'),(2,1,'56F60B05AC19061F6E9D60F23CCB04BC','다세대주택','50,100,000',NULL,'매각공고','2025-05-22 10:00:00.000000',8,NULL,'2024-06-27 10:00:00.000000',NULL,'2024-08-01 10:00:00.000000',NULL,'2024-09-05 10:00:00.000000',NULL,'2024-10-17 10:00:00.000000',NULL,'2023타경5107'),(3,1,'C2DBE7A0AC1906DA70AF48CAE71C46F2','16','574,000,000',NULL,'매각공고','2025-06-02 10:00:00.000000',2,NULL,'2025-03-17 10:00:00.000000',NULL,'2025-04-21 10:00:00.000000',NULL,'2025-06-02 10:00:00.000000','2025-06-09 14:00:00.000000',NULL,NULL,'2022타경1828'),(4,1,'21072683AC1906E670436AF7BC9C9302','13','305,000,000','을구 순위 3번 전세권설정등기(2021. 6. 28. 등기)는 말소되지않고 매수인에게 인수됨.','매각공고','2025-05-27 10:00:00.000000',18,NULL,'2023-08-08 10:00:00.000000',NULL,'2023-09-12 10:00:00.000000',NULL,'2023-10-17 10:00:00.000000',NULL,'2023-11-21 10:00:00.000000',NULL,'2022타경53920');
/*!40000 ALTER TABLE `auction_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auction_party`
--

DROP TABLE IF EXISTS `auction_party`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auction_party` (
  `id` int NOT NULL AUTO_INCREMENT,
  `party_type` varchar(100) DEFAULT NULL,
  `party_name` varchar(255) DEFAULT NULL,
  `remarks` varchar(255) DEFAULT NULL,
  `case_number` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `auction_party_case_number_e99bc032_fk_auction_case_case_number` (`case_number`),
  CONSTRAINT `auction_party_case_number_e99bc032_fk_auction_case_case_number` FOREIGN KEY (`case_number`) REFERENCES `auction_case` (`case_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auction_party`
--

LOCK TABLES `auction_party` WRITE;
/*!40000 ALTER TABLE `auction_party` DISABLE KEYS */;
/*!40000 ALTER TABLE `auction_party` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_api_autobidreservation`
--

DROP TABLE IF EXISTS `auth_api_autobidreservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_api_autobidreservation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `case_number` varchar(50) NOT NULL,
  `bid_amount` int unsigned NOT NULL,
  `reserve_time` time(6) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `auth_api_autobidreservation_chk_1` CHECK ((`bid_amount` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_api_autobidreservation`
--

LOCK TABLES `auth_api_autobidreservation` WRITE;
/*!40000 ALTER TABLE `auth_api_autobidreservation` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_api_autobidreservation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_api_favoriteproperty`
--

DROP TABLE IF EXISTS `auth_api_favoriteproperty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_api_favoriteproperty` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `case_number` varchar(50) NOT NULL,
  `usage` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_api_favoriteproperty`
--

LOCK TABLES `auth_api_favoriteproperty` WRITE;
/*!40000 ALTER TABLE `auth_api_favoriteproperty` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_api_favoriteproperty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_api_property`
--

DROP TABLE IF EXISTS `auth_api_property`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_api_property` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `case_number` varchar(100) NOT NULL,
  `usage` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `case_number` (`case_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_api_property`
--

LOCK TABLES `auth_api_property` WRITE;
/*!40000 ALTER TABLE `auth_api_property` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_api_property` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add content type',4,'add_contenttype'),(14,'Can change content type',4,'change_contenttype'),(15,'Can delete content type',4,'delete_contenttype'),(16,'Can view content type',4,'view_contenttype'),(17,'Can add session',5,'add_session'),(18,'Can change session',5,'change_session'),(19,'Can delete session',5,'delete_session'),(20,'Can view session',5,'view_session'),(21,'Can add auth group',6,'add_authgroup'),(22,'Can change auth group',6,'change_authgroup'),(23,'Can delete auth group',6,'delete_authgroup'),(24,'Can view auth group',6,'view_authgroup'),(25,'Can add auth group permissions',7,'add_authgrouppermissions'),(26,'Can change auth group permissions',7,'change_authgrouppermissions'),(27,'Can delete auth group permissions',7,'delete_authgrouppermissions'),(28,'Can view auth group permissions',7,'view_authgrouppermissions'),(29,'Can add auth permission',8,'add_authpermission'),(30,'Can change auth permission',8,'change_authpermission'),(31,'Can delete auth permission',8,'delete_authpermission'),(32,'Can view auth permission',8,'view_authpermission'),(33,'Can add auth user',9,'add_authuser'),(34,'Can change auth user',9,'change_authuser'),(35,'Can delete auth user',9,'delete_authuser'),(36,'Can view auth user',9,'view_authuser'),(37,'Can add auth user groups',10,'add_authusergroups'),(38,'Can change auth user groups',10,'change_authusergroups'),(39,'Can delete auth user groups',10,'delete_authusergroups'),(40,'Can view auth user groups',10,'view_authusergroups'),(41,'Can add auth user user permissions',11,'add_authuseruserpermissions'),(42,'Can change auth user user permissions',11,'change_authuseruserpermissions'),(43,'Can delete auth user user permissions',11,'delete_authuseruserpermissions'),(44,'Can view auth user user permissions',11,'view_authuseruserpermissions'),(45,'Can add casedetails',12,'add_casedetails'),(46,'Can change casedetails',12,'change_casedetails'),(47,'Can delete casedetails',12,'delete_casedetails'),(48,'Can view casedetails',12,'view_casedetails'),(49,'Can add claimdetails',13,'add_claimdetails'),(50,'Can change claimdetails',13,'change_claimdetails'),(51,'Can delete claimdetails',13,'delete_claimdetails'),(52,'Can view claimdetails',13,'view_claimdetails'),(53,'Can add django admin log',14,'add_djangoadminlog'),(54,'Can change django admin log',14,'change_djangoadminlog'),(55,'Can delete django admin log',14,'delete_djangoadminlog'),(56,'Can view django admin log',14,'view_djangoadminlog'),(57,'Can add django content type',15,'add_djangocontenttype'),(58,'Can change django content type',15,'change_djangocontenttype'),(59,'Can delete django content type',15,'delete_djangocontenttype'),(60,'Can view django content type',15,'view_djangocontenttype'),(61,'Can add django migrations',16,'add_djangomigrations'),(62,'Can change django migrations',16,'change_djangomigrations'),(63,'Can delete django migrations',16,'delete_djangomigrations'),(64,'Can view django migrations',16,'view_djangomigrations'),(65,'Can add django session',17,'add_djangosession'),(66,'Can change django session',17,'change_djangosession'),(67,'Can delete django session',17,'delete_djangosession'),(68,'Can view django session',17,'view_djangosession'),(69,'Can add itemdetails',18,'add_itemdetails'),(70,'Can change itemdetails',18,'change_itemdetails'),(71,'Can delete itemdetails',18,'delete_itemdetails'),(72,'Can view itemdetails',18,'view_itemdetails'),(73,'Can add listingdetails',19,'add_listingdetails'),(74,'Can change listingdetails',19,'change_listingdetails'),(75,'Can delete listingdetails',19,'delete_listingdetails'),(76,'Can view listingdetails',19,'view_listingdetails'),(77,'Can add partydetails',20,'add_partydetails'),(78,'Can change partydetails',20,'change_partydetails'),(79,'Can delete partydetails',20,'delete_partydetails'),(80,'Can view partydetails',20,'view_partydetails'),(81,'Can add user',21,'add_user'),(82,'Can change user',21,'change_user'),(83,'Can delete user',21,'delete_user'),(84,'Can view user',21,'view_user'),(85,'Can add auto bid reservation',22,'add_autobidreservation'),(86,'Can change auto bid reservation',22,'change_autobidreservation'),(87,'Can delete auto bid reservation',22,'delete_autobidreservation'),(88,'Can view auto bid reservation',22,'view_autobidreservation'),(89,'Can add favorite property',23,'add_favoriteproperty'),(90,'Can change favorite property',23,'change_favoriteproperty'),(91,'Can delete favorite property',23,'delete_favoriteproperty'),(92,'Can view favorite property',23,'view_favoriteproperty'),(93,'Can add property',24,'add_property'),(94,'Can change property',24,'change_property'),(95,'Can delete property',24,'delete_property'),(96,'Can view property',24,'view_property'),(97,'Can add profile',25,'add_profile'),(98,'Can change profile',25,'change_profile'),(99,'Can delete profile',25,'delete_profile'),(100,'Can view profile',25,'view_profile'),(101,'Can add site',26,'add_site'),(102,'Can change site',26,'change_site'),(103,'Can delete site',26,'delete_site'),(104,'Can view site',26,'view_site'),(105,'Can add email address',27,'add_emailaddress'),(106,'Can change email address',27,'change_emailaddress'),(107,'Can delete email address',27,'delete_emailaddress'),(108,'Can view email address',27,'view_emailaddress'),(109,'Can add email confirmation',28,'add_emailconfirmation'),(110,'Can change email confirmation',28,'change_emailconfirmation'),(111,'Can delete email confirmation',28,'delete_emailconfirmation'),(112,'Can view email confirmation',28,'view_emailconfirmation'),(113,'Can add social account',29,'add_socialaccount'),(114,'Can change social account',29,'change_socialaccount'),(115,'Can delete social account',29,'delete_socialaccount'),(116,'Can view social account',29,'view_socialaccount'),(117,'Can add social application',30,'add_socialapp'),(118,'Can change social application',30,'change_socialapp'),(119,'Can delete social application',30,'delete_socialapp'),(120,'Can view social application',30,'view_socialapp'),(121,'Can add social application token',31,'add_socialtoken'),(122,'Can change social application token',31,'change_socialtoken'),(123,'Can delete social application token',31,'delete_socialtoken'),(124,'Can view social application token',31,'view_socialtoken'),(125,'Can add claim distribution',32,'add_claimdistribution'),(126,'Can change claim distribution',32,'change_claimdistribution'),(127,'Can delete claim distribution',32,'delete_claimdistribution'),(128,'Can view claim distribution',32,'view_claimdistribution'),(129,'Can add auction party',33,'add_auctionparty'),(130,'Can change auction party',33,'change_auctionparty'),(131,'Can delete auction party',33,'delete_auctionparty'),(132,'Can view auction party',33,'view_auctionparty'),(133,'Can add auction case',34,'add_auctioncase'),(134,'Can change auction case',34,'change_auctioncase'),(135,'Can delete auction case',34,'delete_auctioncase'),(136,'Can view auction case',34,'view_auctioncase'),(137,'Can add auction item',35,'add_auctionitem'),(138,'Can change auction item',35,'change_auctionitem'),(139,'Can delete auction item',35,'delete_auctionitem'),(140,'Can view auction item',35,'view_auctionitem'),(141,'Can add property listing',36,'add_propertylisting'),(142,'Can change property listing',36,'change_propertylisting'),(143,'Can delete property listing',36,'delete_propertylisting'),(144,'Can view property listing',36,'view_propertylisting'),(145,'Can add favorite property',37,'add_favoriteproperty'),(146,'Can change favorite property',37,'change_favoriteproperty'),(147,'Can delete favorite property',37,'delete_favoriteproperty'),(148,'Can view favorite property',37,'view_favoriteproperty');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claim_distribution`
--

DROP TABLE IF EXISTS `claim_distribution`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claim_distribution` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location` longtext,
  `claim_deadline` date DEFAULT NULL,
  `case_number` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `claim_distribution_case_number_460467a2_fk_auction_c` (`case_number`),
  CONSTRAINT `claim_distribution_case_number_460467a2_fk_auction_c` FOREIGN KEY (`case_number`) REFERENCES `auction_case` (`case_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claim_distribution`
--

LOCK TABLES `claim_distribution` WRITE;
/*!40000 ALTER TABLE `claim_distribution` DISABLE KEYS */;
INSERT INTO `claim_distribution` VALUES (1,'서울특별시 서초구 서초동 1487-110 (서초동,에비앙하우스)','2023-11-06','2023타경3460'),(2,'서울특별시 중구 신당동 200-5 (신당동,누죤빌딩)','2024-01-18','2023타경5107'),(3,'서울특별시 송파구 문정동 618 (문정동,파크하비오)','2022-12-12','2022타경1828'),(4,'서울특별시 서대문구 홍은동 325-7 (홍은동,트라움하임홍은)','2022-09-28','2022타경53920');
/*!40000 ALTER TABLE `claim_distribution` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_user`
--

DROP TABLE IF EXISTS `custom_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `gender` varchar(1) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `bio` longtext NOT NULL,
  `region` varchar(100) NOT NULL,
  `address` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `mobile` varchar(20) NOT NULL,
  `terms_conditions` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_user`
--

LOCK TABLES `custom_user` WRITE;
/*!40000 ALTER TABLE `custom_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_user_groups`
--

DROP TABLE IF EXISTS `custom_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `custom_user_groups_user_id_group_id_747bb497_uniq` (`user_id`,`group_id`),
  KEY `custom_user_groups_group_id_02874f21_fk_auth_group_id` (`group_id`),
  CONSTRAINT `custom_user_groups_group_id_02874f21_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `custom_user_groups_user_id_fc78735a_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_user_groups`
--

LOCK TABLES `custom_user_groups` WRITE;
/*!40000 ALTER TABLE `custom_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_user_user_permissions`
--

DROP TABLE IF EXISTS `custom_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `custom_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `custom_user_user_permissions_user_id_permission_id_31f85e8f_uniq` (`user_id`,`permission_id`),
  KEY `custom_user_user_per_permission_id_f82b5e3f_fk_auth_perm` (`permission_id`),
  CONSTRAINT `custom_user_user_per_permission_id_f82b5e3f_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `custom_user_user_permissions_user_id_0634b1dc_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_user_user_permissions`
--

LOCK TABLES `custom_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `custom_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_custom_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (27,'account','emailaddress'),(28,'account','emailconfirmation'),(21,'accounts','user'),(1,'admin','logentry'),(34,'app','auctioncase'),(35,'app','auctionitem'),(33,'app','auctionparty'),(6,'app','authgroup'),(7,'app','authgrouppermissions'),(8,'app','authpermission'),(9,'app','authuser'),(10,'app','authusergroups'),(11,'app','authuseruserpermissions'),(12,'app','casedetails'),(13,'app','claimdetails'),(32,'app','claimdistribution'),(14,'app','djangoadminlog'),(15,'app','djangocontenttype'),(16,'app','djangomigrations'),(17,'app','djangosession'),(18,'app','itemdetails'),(19,'app','listingdetails'),(20,'app','partydetails'),(36,'app','propertylisting'),(3,'auth','group'),(2,'auth','permission'),(22,'auth_api','autobidreservation'),(23,'auth_api','favoriteproperty'),(24,'auth_api','property'),(4,'contenttypes','contenttype'),(37,'main','favoriteproperty'),(25,'main','profile'),(5,'sessions','session'),(26,'sites','site'),(29,'socialaccount','socialaccount'),(30,'socialaccount','socialapp'),(31,'socialaccount','socialtoken');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2025-05-13 11:54:26.458171'),(2,'contenttypes','0002_remove_content_type_name','2025-05-13 11:54:26.492214'),(3,'auth','0001_initial','2025-05-13 11:54:26.621475'),(4,'auth','0002_alter_permission_name_max_length','2025-05-13 11:54:26.651783'),(5,'auth','0003_alter_user_email_max_length','2025-05-13 11:54:26.655201'),(6,'auth','0004_alter_user_username_opts','2025-05-13 11:54:26.658102'),(7,'auth','0005_alter_user_last_login_null','2025-05-13 11:54:26.660906'),(8,'auth','0006_require_contenttypes_0002','2025-05-13 11:54:26.662110'),(9,'auth','0007_alter_validators_add_error_messages','2025-05-13 11:54:26.664946'),(10,'auth','0008_alter_user_username_max_length','2025-05-13 11:54:26.667728'),(11,'auth','0009_alter_user_last_name_max_length','2025-05-13 11:54:26.670685'),(12,'auth','0010_alter_group_name_max_length','2025-05-13 11:54:26.678119'),(13,'auth','0011_update_proxy_permissions','2025-05-13 11:54:26.681790'),(14,'auth','0012_alter_user_first_name_max_length','2025-05-13 11:54:26.684666'),(15,'accounts','0001_initial','2025-05-13 11:54:26.847647'),(16,'account','0001_initial','2025-05-13 11:54:26.949584'),(17,'account','0002_email_max_length','2025-05-13 11:54:26.959063'),(18,'account','0003_alter_emailaddress_create_unique_verified_email','2025-05-13 11:54:26.975255'),(19,'account','0004_alter_emailaddress_drop_unique_email','2025-05-13 11:54:27.000950'),(20,'account','0005_emailaddress_idx_upper_email','2025-05-13 11:54:27.020406'),(21,'account','0006_emailaddress_lower','2025-05-13 11:54:27.027799'),(22,'account','0007_emailaddress_idx_email','2025-05-13 11:54:27.051276'),(23,'account','0008_emailaddress_unique_primary_email_fixup','2025-05-13 11:54:27.058791'),(24,'account','0009_emailaddress_unique_primary_email','2025-05-13 11:54:27.062646'),(25,'admin','0001_initial','2025-05-13 11:54:27.146661'),(26,'admin','0002_logentry_remove_auto_add','2025-05-13 11:54:27.151439'),(27,'admin','0003_logentry_add_action_flag_choices','2025-05-13 11:54:27.157152'),(28,'app','0001_initial','2025-05-13 11:54:27.164715'),(29,'auth_api','0001_initial','2025-05-13 11:54:27.199066'),(30,'main','0001_initial','2025-05-13 11:54:27.211107'),(31,'main','0002_autobidreservation','2025-05-13 11:54:27.220866'),(32,'main','0003_favoriteproperty','2025-05-13 11:54:27.230089'),(33,'main','0004_profile_delete_autobidreservation_and_more','2025-05-13 11:54:27.291772'),(34,'sessions','0001_initial','2025-05-13 11:54:27.310009'),(35,'sites','0001_initial','2025-05-13 11:54:27.320383'),(36,'sites','0002_alter_domain_unique','2025-05-13 11:54:27.329126'),(37,'socialaccount','0001_initial','2025-05-13 11:54:27.534605'),(38,'socialaccount','0002_token_max_lengths','2025-05-13 11:54:27.562296'),(39,'socialaccount','0003_extra_data_default_dict','2025-05-13 11:54:27.567179'),(40,'socialaccount','0004_app_provider_id_settings','2025-05-13 11:54:27.640900'),(41,'socialaccount','0005_socialtoken_nullable_app','2025-05-13 11:54:27.708472'),(42,'socialaccount','0006_alter_socialaccount_extra_data','2025-05-13 11:54:27.745319'),(43,'app','0002_alter_casedetails_options_alter_claimdetails_options_and_more','2025-05-13 12:02:00.504472'),(44,'app','0002_casedetails_claimdetails_itemdetails_listingdetails_and_more','2025-05-13 12:10:22.267136'),(45,'app','0003_auctioncase_remove_claimdetails_case_and_more','2025-05-19 19:23:41.817303');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_site`
--

DROP TABLE IF EXISTS `django_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_site` (
  `id` int NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_site_domain_a2e37b91_uniq` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_site`
--

LOCK TABLES `django_site` WRITE;
/*!40000 ALTER TABLE `django_site` DISABLE KEYS */;
INSERT INTO `django_site` VALUES (1,'example.com','example.com');
/*!40000 ALTER TABLE `django_site` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `main_profile`
--

DROP TABLE IF EXISTS `main_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `main_profile` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `wallet_address` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `id_number` varchar(20) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` varchar(200) NOT NULL,
  `balance` int unsigned NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `main_profile_user_id_b40d720a_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`),
  CONSTRAINT `main_profile_chk_1` CHECK ((`balance` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `main_profile`
--

LOCK TABLES `main_profile` WRITE;
/*!40000 ALTER TABLE `main_profile` DISABLE KEYS */;
/*!40000 ALTER TABLE `main_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `property_listing`
--

DROP TABLE IF EXISTS `property_listing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `property_listing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `location` longtext,
  `listing_type` varchar(100) DEFAULT NULL,
  `details` longtext,
  `final_result` varchar(100) DEFAULT NULL,
  `final_date` date DEFAULT NULL,
  `case_number` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `property_listing_case_number_ef7cb9c5_fk_auction_c` (`case_number`),
  CONSTRAINT `property_listing_case_number_ef7cb9c5_fk_auction_c` FOREIGN KEY (`case_number`) REFERENCES `auction_case` (`case_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `property_listing`
--

LOCK TABLES `property_listing` WRITE;
/*!40000 ALTER TABLE `property_listing` DISABLE KEYS */;
INSERT INTO `property_listing` VALUES (1,'서울특별시 서초구 서초동 1487-110 (서초동,에비앙하우스)','다세대주택','1동의 표시\n철근콘크리트구조 경사지붕 7층 도시형생활주택(단지형다세대)\n지1층 40.36㎡\n1층 20㎡\n2층 203.32㎡\n3층 203.32㎡\n4층 162.64㎡\n5층 162.64㎡\n6층 162.64㎡\n7층 151.34㎡\n옥탑1층 3.8㎡\n\n전유의 표시\n철근콘크리트구조 36.64㎡','미종국',NULL,'2023타경3460'),(2,'서울특별시 중구 신당동 200-5 (신당동,누죤빌딩)','다세대주택','1동의 표시\n철골철근콘크리트조 평슬래브지붕 15층\n판매시설, 근린생활시설 및 업무시설\n    1층 2734.46㎡\n    2층 2195.93㎡\n    3층 2195.93㎡\n    4층 2195.93㎡\n    5층 2195.93㎡\n    6층 2195.93㎡\n    7층 1998.43㎡\n    8층 1716.52㎡\n    9층 1351.46㎡\n   10층 1244.11㎡\n   11층  651.93㎡\n   12층  625.78㎡\n   13층  625.78㎡\n   14층  625.78㎡\n   15층  625.78㎡\n지하1층 3267.00㎡\n지하2층 3267.00㎡\n지하3층 3267.00㎡\n지하4층 3267.00㎡\n지하5층 3267.00㎡\n지하6층 3081.22㎡\n\n전유의 표시\n철골철근콘크리트조 5.040㎡','미종국',NULL,'2023타경5107'),(3,'서울특별시 송파구 문정동 618 (문정동,파크하비오)','16','1동의 표시\n철근콘크리트구조 (철근)콘크리트지붕\n19층 업무시설(오피스텔)\n1층  170.94㎡\n2층  51.42㎡  \n3층  1263.76㎡\n4층  1444.43㎡\n5층  1479.55㎡\n6층  1479.55㎡\n7층  1479.55㎡\n8층  1479.55㎡\n9층  1479.55㎡\n10층 1479.55㎡\n11층 1479.55㎡\n12층 1479.55㎡\n13층 1479.55㎡\n14층 1479.55㎡\n15층 1479.55㎡\n16층 1479.55㎡\n17층 1479.55㎡\n18층 1479.55㎡\n19층 1306.13㎡\n\n전유의 표시\n철근콘크리트구조 48.96㎡','미종국',NULL,'2022타경1828'),(4,'서울특별시 서대문구 홍은동 325-7 (홍은동,트라움하임홍은)','13','1동의 표시\n철근콘크리트구조 (철근)콘크리트지붕 5층\n공동주택\n1층 63.63㎡\n2층 139.47㎡\n3층 139.47㎡\n4층 159.72㎡\n5층 121.02㎡\n옥탑1층 16.2㎡\n\n전유의 표시\n철근콘크리트구조 45.99㎡','미종국',NULL,'2022타경53920');
/*!40000 ALTER TABLE `property_listing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `socialaccount_socialaccount`
--

DROP TABLE IF EXISTS `socialaccount_socialaccount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socialaccount_socialaccount` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider` varchar(200) NOT NULL,
  `uid` varchar(191) NOT NULL,
  `last_login` datetime(6) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `extra_data` json NOT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `socialaccount_socialaccount_provider_uid_fc810c6e_uniq` (`provider`,`uid`),
  KEY `socialaccount_socialaccount_user_id_8146e70c_fk_custom_user_id` (`user_id`),
  CONSTRAINT `socialaccount_socialaccount_user_id_8146e70c_fk_custom_user_id` FOREIGN KEY (`user_id`) REFERENCES `custom_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socialaccount_socialaccount`
--

LOCK TABLES `socialaccount_socialaccount` WRITE;
/*!40000 ALTER TABLE `socialaccount_socialaccount` DISABLE KEYS */;
/*!40000 ALTER TABLE `socialaccount_socialaccount` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `socialaccount_socialapp`
--

DROP TABLE IF EXISTS `socialaccount_socialapp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socialaccount_socialapp` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider` varchar(30) NOT NULL,
  `name` varchar(40) NOT NULL,
  `client_id` varchar(191) NOT NULL,
  `secret` varchar(191) NOT NULL,
  `key` varchar(191) NOT NULL,
  `provider_id` varchar(200) NOT NULL,
  `settings` json NOT NULL DEFAULT (_utf8mb4'{}'),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socialaccount_socialapp`
--

LOCK TABLES `socialaccount_socialapp` WRITE;
/*!40000 ALTER TABLE `socialaccount_socialapp` DISABLE KEYS */;
/*!40000 ALTER TABLE `socialaccount_socialapp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `socialaccount_socialapp_sites`
--

DROP TABLE IF EXISTS `socialaccount_socialapp_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socialaccount_socialapp_sites` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `socialapp_id` int NOT NULL,
  `site_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `socialaccount_socialapp_sites_socialapp_id_site_id_71a9a768_uniq` (`socialapp_id`,`site_id`),
  KEY `socialaccount_socialapp_sites_site_id_2579dee5_fk_django_site_id` (`site_id`),
  CONSTRAINT `socialaccount_social_socialapp_id_97fb6e7d_fk_socialacc` FOREIGN KEY (`socialapp_id`) REFERENCES `socialaccount_socialapp` (`id`),
  CONSTRAINT `socialaccount_socialapp_sites_site_id_2579dee5_fk_django_site_id` FOREIGN KEY (`site_id`) REFERENCES `django_site` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socialaccount_socialapp_sites`
--

LOCK TABLES `socialaccount_socialapp_sites` WRITE;
/*!40000 ALTER TABLE `socialaccount_socialapp_sites` DISABLE KEYS */;
/*!40000 ALTER TABLE `socialaccount_socialapp_sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `socialaccount_socialtoken`
--

DROP TABLE IF EXISTS `socialaccount_socialtoken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socialaccount_socialtoken` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` longtext NOT NULL,
  `token_secret` longtext NOT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `account_id` int NOT NULL,
  `app_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `socialaccount_socialtoken_app_id_account_id_fca4e0ac_uniq` (`app_id`,`account_id`),
  KEY `socialaccount_social_account_id_951f210e_fk_socialacc` (`account_id`),
  CONSTRAINT `socialaccount_social_account_id_951f210e_fk_socialacc` FOREIGN KEY (`account_id`) REFERENCES `socialaccount_socialaccount` (`id`),
  CONSTRAINT `socialaccount_social_app_id_636a42d7_fk_socialacc` FOREIGN KEY (`app_id`) REFERENCES `socialaccount_socialapp` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socialaccount_socialtoken`
--

LOCK TABLES `socialaccount_socialtoken` WRITE;
/*!40000 ALTER TABLE `socialaccount_socialtoken` DISABLE KEYS */;
/*!40000 ALTER TABLE `socialaccount_socialtoken` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-20  6:02:48
