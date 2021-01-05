-- MySQL dump 10.13  Distrib 5.5.57-gs, for Linux (x86_64)
--
-- Host: localhost    Database: pbx_gtalk
-- ------------------------------------------------------
-- Server version	5.5.57-gs-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `default_extention` char(5) NOT NULL DEFAULT '',
  `default_did` char(13) NOT NULL DEFAULT '',
  `active` char(1) NOT NULL DEFAULT 'Y',
  `credit_amount` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `used_amount` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `acc_credit` decimal(10,2) NOT NULL DEFAULT '0.00',
  `acc_used` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tollfree_rate` decimal(4,2) unsigned NOT NULL DEFAULT '0.00',
  `bill_to_pinless_account` char(1) NOT NULL DEFAULT '',
  `email_notification` char(1) NOT NULL DEFAULT 'N',
  `prefered_codec` char(2) NOT NULL DEFAULT '0',
  `inv_day` decimal(2,0) NOT NULL DEFAULT '0',
  `payment_day` decimal(2,0) NOT NULL DEFAULT '0',
  `next_inv_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `next_payment_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `payment_method` char(2) NOT NULL DEFAULT '' COMMENT 'AH-ACH, CC-Credit Card, CH-Check, CA-Cash',
  `cc_processing_fee` decimal(4,2) NOT NULL DEFAULT '0.00',
  `auto_topup_method` char(2) NOT NULL DEFAULT '' COMMENT 'AH-ACH, CC-Credit Card, CH-Check, CA-Cash',
  PRIMARY KEY (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER account_upd AFTER UPDATE ON account
FOR EACH ROW
BEGIN

  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';
  DECLARE param_v char(10);

  IF old.default_did != new.default_did THEN
      SET param_v = 'CLI';
      SET msg_v = CONCAT('DB_TRIGGER\r\ntable: ACCOUNT\r\n', 'account_id: ', new.account_id, '\r\n' , 'param: ', param_v, '\r\n');
      SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
      IF DB_ServerPort_v != '' THEN
          SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
      END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `account_comments`
--

DROP TABLE IF EXISTS `account_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_comments` (
  `id` decimal(8,0) NOT NULL DEFAULT '0',
  `parent_id` decimal(8,0) NOT NULL DEFAULT '0',
  `account_id` char(6) NOT NULL DEFAULT '',
  `note` char(150) NOT NULL DEFAULT '',
  `note_type` char(1) NOT NULL DEFAULT 'O' COMMENT 'B=Billing, 9=911, A=address, O=Others',
  `action_type` char(1) NOT NULL DEFAULT 'I' COMMENT 'I=Info, R=Reminder, A=Action needed, T=Trouble ticket',
  `added_by` char(20) NOT NULL,
  `add_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ack_by` char(20) NOT NULL,
  `ack_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_ledger`
--

DROP TABLE IF EXISTS `account_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_ledger` (
  `account_id` char(6) NOT NULL,
  `ltime` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `utctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `description` char(200) NOT NULL DEFAULT '',
  `pre_balance` decimal(7,2) NOT NULL DEFAULT '0.00',
  `debit` decimal(7,2) NOT NULL DEFAULT '0.00',
  `credit` decimal(7,2) NOT NULL DEFAULT '0.00',
  `ref_id` char(12) NOT NULL DEFAULT '',
  `ref_type` char(2) NOT NULL DEFAULT 'UN' COMMENT 'IN=Invoice, CC=Creditcard,CA=Cash, CH=Check,CN=Credit Note,RF=Refund,UN=Unknown',
  `ip` char(15) NOT NULL DEFAULT '',
  KEY `account_time` (`account_id`,`utctime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_phonebook`
--

DROP TABLE IF EXISTS `account_phonebook`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_phonebook` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `cnam` char(15) NOT NULL DEFAULT '',
  `first_name` char(25) NOT NULL DEFAULT '',
  `last_name` char(25) NOT NULL DEFAULT '',
  `company_name` char(35) NOT NULL DEFAULT '',
  `street` char(50) NOT NULL DEFAULT '',
  `city` char(30) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(5) NOT NULL DEFAULT '',
  `phone` char(12) NOT NULL DEFAULT '',
  `fax` char(12) NOT NULL DEFAULT '',
  `contact_type` char(1) NOT NULL DEFAULT 'V' COMMENT 'V-Voice, F-Fax',
  KEY `account_id_name` (`account_id`,`first_name`),
  KEY `account_id_phone` (`account_id`,`phone`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_profile`
--

DROP TABLE IF EXISTS `account_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_profile` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `name` char(50) NOT NULL DEFAULT '',
  `contact_person` char(25) NOT NULL DEFAULT '',
  `street` char(25) NOT NULL DEFAULT '',
  `suite` char(8) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `county` char(20) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(9) NOT NULL DEFAULT '',
  `country` char(6) NOT NULL DEFAULT '',
  `contact_number` char(13) NOT NULL DEFAULT '',
  `cell_number` char(11) NOT NULL DEFAULT '',
  `email` char(35) NOT NULL DEFAULT '',
  `timezone` char(30) NOT NULL DEFAULT '',
  `is_address_verified` char(1) NOT NULL DEFAULT '',
  `billing_contact_name` char(35) NOT NULL DEFAULT '',
  `billing_phone_number` char(13) NOT NULL DEFAULT '',
  `billing_email` char(50) NOT NULL DEFAULT '' COMMENT 'Comma separated emails',
  `password` char(32) NOT NULL DEFAULT '',
  `sdate` date NOT NULL DEFAULT '0000-00-00',
  `service_update_date` date NOT NULL DEFAULT '0000-00-00',
  `plan_code` char(2) NOT NULL DEFAULT '',
  `tollfree_mrc` decimal(3,2) unsigned NOT NULL DEFAULT '0.00',
  `web_access` char(1) NOT NULL DEFAULT 'N',
  `web_access_billing` char(1) NOT NULL DEFAULT 'Y',
  `distributor_id` char(4) NOT NULL DEFAULT '',
  PRIMARY KEY (`account_id`),
  KEY `email` (`email`),
  KEY `sdate` (`sdate`),
  KEY `distributor_id` (`distributor_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_service_list`
--

DROP TABLE IF EXISTS `account_service_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_service_list` (
  `account_id` char(6) NOT NULL,
  `service_code` char(4) NOT NULL DEFAULT '' COMMENT 'Plan code Or Promocode',
  `sub_title` char(150) NOT NULL DEFAULT '',
  `service_quantity` decimal(3,0) NOT NULL,
  `service_price` decimal(5,2) NOT NULL,
  `service_discount` decimal(5,2) NOT NULL,
  `billing_cycle` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Monthly, O=One time',
  `service_added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_billed` date NOT NULL,
  `service_ref` char(8) NOT NULL DEFAULT '' COMMENT 'applied promocode or plancode',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A= Active, I=Inactive, P=Paid for one time bill',
  KEY `account_id_status` (`account_id`,`status`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_service_log`
--

DROP TABLE IF EXISTS `account_service_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_service_log` (
  `account_id` char(6) NOT NULL,
  `service_code` char(4) NOT NULL DEFAULT '' COMMENT 'Plan code Or Promocode',
  `sub_title` char(150) NOT NULL DEFAULT '',
  `service_quantity` decimal(3,0) NOT NULL,
  `service_price` decimal(5,2) NOT NULL,
  `service_discount` decimal(5,2) NOT NULL,
  `billing_cycle` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Monthly, O=One time',
  `last_billed` date NOT NULL,
  `service_ref` char(8) NOT NULL DEFAULT '' COMMENT 'applied promocode or plancode',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A= Active, I=Inactive, P=Paid for one time bill',
  `log_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `effective_date` date NOT NULL DEFAULT '0000-00-00',
  `user_id` char(15) NOT NULL DEFAULT '',
  KEY `account_id_status` (`account_id`,`status`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ach_payment_log`
--

DROP TABLE IF EXISTS `ach_payment_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ach_payment_log` (
  `utctime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_id` char(6) NOT NULL,
  `name_on_account` char(25) NOT NULL DEFAULT '',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `ac_data_aes` char(200) NOT NULL DEFAULT '',
  `amount` decimal(7,2) NOT NULL DEFAULT '0.00',
  `service` char(1) NOT NULL DEFAULT 'S' COMMENT 'S-Service, T-Topup',
  `srv_ref_id` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `bank_ref_id` char(12) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT 'N' COMMENT 'N-New, P-Processing, S-Settled/Success, F-Failed',
  `update_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  KEY `account_time` (`account_id`,`utctime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `area_code`
--

DROP TABLE IF EXISTS `area_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_code` (
  `npa` char(3) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT '',
  KEY `npa` (`npa`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auto_refill_info`
--

DROP TABLE IF EXISTS `auto_refill_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auto_refill_info` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `amount_to_refill` decimal(3,0) NOT NULL DEFAULT '0',
  `minimum_amount` decimal(2,0) NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A=Active, I=inactive, E=Process error',
  PRIMARY KEY (`account_id`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blf_key`
--

DROP TABLE IF EXISTS `blf_key`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blf_key` (
  `userid` char(6) NOT NULL DEFAULT '',
  `unit_id` decimal(1,0) NOT NULL DEFAULT '1',
  `key_id` decimal(2,0) NOT NULL DEFAULT '0',
  `monitor` char(6) NOT NULL DEFAULT '',
  `type` char(3) NOT NULL DEFAULT 'BLF',
  KEY `user_id` (`userid`),
  KEY `monitor` (`monitor`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `block_list`
--

DROP TABLE IF EXISTS `block_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `block_list` (
  `userid` char(6) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `prefix` char(7) NOT NULL DEFAULT '',
  `number` char(15) NOT NULL DEFAULT '',
  `name` char(15) NOT NULL DEFAULT '',
  `list_date` date NOT NULL DEFAULT '0000-00-00',
  KEY `pin` (`userid`,`number`),
  KEY `list_date` (`list_date`),
  KEY `name` (`userid`,`name`) USING BTREE,
  KEY `account_id` (`account_id`,`prefix`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bonded_account`
--

DROP TABLE IF EXISTS `bonded_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bonded_account` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `first_extn` decimal(5,0) NOT NULL DEFAULT '0',
  `last_extn` decimal(5,0) NOT NULL DEFAULT '0',
  `call_type` char(1) NOT NULL DEFAULT '',
  `dst_account_id` char(6) NOT NULL DEFAULT '',
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cc_profile`
--

DROP TABLE IF EXISTS `cc_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cc_profile` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `type` char(1) NOT NULL DEFAULT '',
  `name_on_card` char(20) NOT NULL DEFAULT '',
  `cc_data_aes` char(255) NOT NULL DEFAULT '',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `exp_date` char(4) NOT NULL DEFAULT '',
  `is_default` char(1) NOT NULL DEFAULT '',
  `is_topup` char(1) NOT NULL DEFAULT '',
  `next_transaction_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `failed_count` decimal(1,0) NOT NULL DEFAULT '0',
  `info_type` char(2) NOT NULL DEFAULT 'CC' COMMENT 'CC=Credit Card, AC=Bank Account',
  KEY `account_id` (`account_id`),
  KEY `last_4_digit` (`last_4_digit`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdr`
--

DROP TABLE IF EXISTS `cdr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdr` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `department_id` char(6) NOT NULL DEFAULT '',
  `sdate` date NOT NULL DEFAULT '0000-00-00' COMMENT 'GMT timezone',
  `start_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `stop_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `userid` char(6) NOT NULL DEFAULT '',
  `extn` char(5) NOT NULL DEFAULT '',
  `endpoint` char(1) NOT NULL DEFAULT '' COMMENT 'A=App; X=Phone; F=Forward; V=VM; E=E-Fax',
  `pbx_number` char(12) NOT NULL DEFAULT '',
  `cnam` char(15) NOT NULL DEFAULT '',
  `external_number` char(13) NOT NULL DEFAULT '',
  `duration` decimal(5,0) NOT NULL DEFAULT '0',
  `voice_sec` decimal(5,0) NOT NULL DEFAULT '0',
  `route_code` char(12) NOT NULL DEFAULT '',
  `bill_minute` decimal(3,0) unsigned NOT NULL DEFAULT '0',
  `rate` decimal(4,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'in cent',
  `bill` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `tax` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `total_bill` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `direction` char(1) NOT NULL DEFAULT 'O',
  `service_type` char(1) NOT NULL DEFAULT 'V' COMMENT 'V=Voice; F=Fax; P=Page;',
  `is_tollfree` char(1) NOT NULL DEFAULT '',
  `callid` char(20) NOT NULL DEFAULT '',
  `disc_party` char(1) NOT NULL DEFAULT '',
  `disc_cause` char(3) NOT NULL DEFAULT '',
  `extn_ip` char(15) NOT NULL DEFAULT '',
  `switch_ip` char(15) NOT NULL DEFAULT '',
  `gw_ip` char(15) NOT NULL DEFAULT '',
  `rtp_ip` char(15) NOT NULL DEFAULT '',
  `codec` char(2) NOT NULL DEFAULT '',
  `service_quality` decimal(4,2) unsigned NOT NULL DEFAULT '0.00',
  KEY `sdate` (`account_id`,`sdate`,`department_id`),
  KEY `stop_time_dir` (`account_id`,`stop_time`,`direction`),
  KEY `userid` (`userid`,`sdate`),
  KEY `callid` (`callid`),
  KEY `external_number` (`account_id`,`external_number`),
  KEY `sdate_all` (`sdate`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1
/*!50100 PARTITION BY KEY (account_id)
PARTITIONS 10 */;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER cdr_add BEFORE INSERT ON cdr
FOR EACH ROW
BEGIN

        DECLARE is_tollfree_v CHAR(1) DEFAULT '';
        DECLARE gcode_v CHAR(12) DEFAULT '';
        DECLARE minute_v decimal(3,0) DEFAULT 0;
        DECLARE rate_v decimal(4,2) DEFAULT 0;
        DECLARE bill_v decimal(6,4) DEFAULT 0.0000;
        DECLARE tax_v decimal(6,4) DEFAULT 0.0000;
        DECLARE total_bill_v decimal(6,4) DEFAULT 0.0000;

        IF NEW.direction = 'I' THEN
                IF NEW.duration > 0 AND LENGTH(NEW.pbx_number) > 7 THEN
                        SELECT is_tollfree INTO is_tollfree_v FROM did WHERE did_full=NEW.pbx_number;
                        IF is_tollfree_v = 'Y' THEN
                                SET NEW.is_tollfree = 'Y';
                                SET minute_v = CEIL(NEW.duration/60);
                                SELECT tollfree_rate INTO rate_v FROM account WHERE account_id=NEW.account_id;
                        END IF;
                END IF;
        ELSE
                IF NEW.route_code!= '' AND NEW.voice_sec > 0 THEN
                        SELECT gcode INTO gcode_v FROM service_free_destination WHERE gcode=NEW.route_code;
                        IF gcode_v = '' THEN
                                SET minute_v = CEIL(NEW.voice_sec/60);
                                SELECT rate INTO rate_v FROM gtalk.rate WHERE user='pinless1' AND gcode=NEW.route_code;
                        END IF;
                END IF;
        END IF;

        IF rate_v > 0 THEN
        SET bill_v = CEIL(rate_v * minute_v * 100) / 10000;
        SET tax_v = bill_v * 0.34215;
        SET total_bill_v = bill_v + tax_v;
        IF bill_v > 0 THEN
              UPDATE account SET used_amount=used_amount+total_bill_v WHERE account_id=NEW.account_id;
              SET NEW.bill_minute = minute_v;
              SET NEW.rate = rate_v;
              SET NeW.bill = bill_v;
              SET NEW.tax = tax_v;
              SET NEW.total_bill = total_bill_v;
        END IF;
    END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cdr_fax`
--

DROP TABLE IF EXISTS `cdr_fax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdr_fax` (
  `start_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `stop_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `utc` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `sdate` date NOT NULL DEFAULT '0000-00-00',
  `account_id` char(6) NOT NULL DEFAULT '',
  `user_id` char(6) NOT NULL DEFAULT '',
  `did` char(13) NOT NULL DEFAULT '',
  `caller_name` char(20) NOT NULL DEFAULT '',
  `caller_id` char(15) NOT NULL DEFAULT '',
  `duration` decimal(5,0) NOT NULL DEFAULT '0',
  `num_pages` decimal(2,0) unsigned NOT NULL DEFAULT '0',
  `transmission_rate` decimal(6,0) NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL DEFAULT '',
  `is_read` char(1) NOT NULL DEFAULT 'N',
  `label_id` char(1) NOT NULL DEFAULT '',
  `additional_info` char(40) NOT NULL DEFAULT '',
  `direction` char(1) NOT NULL DEFAULT 'I',
  `try_count` decimal(1,0) NOT NULL DEFAULT '0',
  `call_id` char(20) NOT NULL DEFAULT '',
  KEY `call_id` (`call_id`),
  KEY `user_id` (`user_id`),
  KEY `account_id_sdate_status` (`account_id`,`stop_time`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cdr_tollfree`
--

DROP TABLE IF EXISTS `cdr_tollfree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cdr_tollfree` (
  `start_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `stop_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `utc` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `offset_to_utc` decimal(3,0) NOT NULL DEFAULT '0',
  `account_id` char(6) NOT NULL DEFAULT '',
  `did` char(13) NOT NULL DEFAULT '',
  `callerid` char(13) NOT NULL DEFAULT '',
  `duration` char(12) NOT NULL DEFAULT '',
  `bill_sec` decimal(4,0) NOT NULL DEFAULT '0',
  `rate` decimal(4,2) unsigned NOT NULL DEFAULT '0.00' COMMENT 'in cent',
  `bill` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `tax` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `total_bill` decimal(6,4) unsigned NOT NULL DEFAULT '0.0000',
  `callid` char(20) NOT NULL DEFAULT '',
  `num_billed` decimal(1,0) NOT NULL DEFAULT '0',
  KEY `callid` (`callid`),
  KEY `account_id` (`account_id`,`stop_time`),
  KEY `callerid` (`account_id`,`callerid`),
  KEY `did` (`account_id`,`did`),
  KEY `start_time` (`account_id`,`start_time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `department` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `department_id` char(6) NOT NULL DEFAULT '',
  `name` char(25) NOT NULL DEFAULT '',
  `outgoing_caller_id` char(11) NOT NULL DEFAULT '',
  `office_hour` char(70) NOT NULL DEFAULT '',
  `after_hour_fwd_rule` char(1) NOT NULL DEFAULT '' COMMENT 'U=Unconditional; D=ServiceDown; A=NoAnswer',
  `after_hour_fwd_number` char(14) NOT NULL DEFAULT '',
  PRIMARY KEY (`department_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER department_upd AFTER UPDATE ON department
FOR EACH ROW
BEGIN

  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';
  DECLARE param_v char(10);

  IF old.outgoing_caller_id != new.outgoing_caller_id THEN
      SET param_v = 'CLI';
      SET msg_v = CONCAT('DB_TRIGGER\r\ntable: DEPARTMENT\r\n', 'department_id: ', new.department_id, '\r\n' , 'param: ', param_v, '\r\n');
      SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
      IF DB_ServerPort_v != '' THEN
          SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
      END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `device`
--

DROP TABLE IF EXISTS `device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `pin` char(12) NOT NULL DEFAULT '',
  `pass` char(10) NOT NULL DEFAULT '',
  `maker` char(3) NOT NULL DEFAULT '',
  `model` char(20) NOT NULL DEFAULT '',
  `device_id` char(20) NOT NULL DEFAULT '',
  `firmware` char(8) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `user_pin` char(14) NOT NULL DEFAULT '',
  `location` char(21) NOT NULL DEFAULT '',
  `tstmp` int(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `device_id` (`device_id`),
  UNIQUE KEY `pin` (`pin`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_details`
--

DROP TABLE IF EXISTS `device_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_details` (
  `device_id` char(4) NOT NULL DEFAULT '',
  `device_type` char(1) DEFAULT 'E' COMMENT 'E=Entry Lavel, S=Standard,W=Wireless, C=Conference,O=Others',
  `sub_title` char(100) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`device_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_move_out`
--

DROP TABLE IF EXISTS `device_move_out`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_move_out` (
  `device_mac` char(12) NOT NULL DEFAULT '',
  `move_to` char(2) NOT NULL DEFAULT 'HM',
  UNIQUE KEY `device_mac` (`device_mac`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dial_plan`
--

DROP TABLE IF EXISTS `dial_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dial_plan` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `prefix` char(1) NOT NULL DEFAULT '',
  `digit_len` decimal(2,0) NOT NULL DEFAULT '0',
  `call_type` char(1) NOT NULL DEFAULT '',
  `dst_account_id` char(6) NOT NULL DEFAULT '',
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `did`
--

DROP TABLE IF EXISTS `did`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `did` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `did` char(10) NOT NULL DEFAULT '',
  `did_full` char(13) NOT NULL DEFAULT '',
  `action` char(2) NOT NULL DEFAULT '' COMMENT 'DD=DirectDial; GP=GreetingsPrompt; IV=IVR; RG=RingGroup',
  `param` char(40) NOT NULL DEFAULT '',
  `arg` char(10) NOT NULL DEFAULT '',
  `is_tollfree` char(1) NOT NULL DEFAULT 'N',
  UNIQUE KEY `did` (`did`),
  KEY `account_id` (`account_id`),
  KEY `param` (`param`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER did_upd AFTER UPDATE ON did
FOR EACH ROW
BEGIN

  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';

  IF old.action != new.action OR old.param = new.param THEN
      SET msg_v = CONCAT('DB_TRIGGER\r\ntable: DID\r\n', 'did: ', new.did, '\r\n');
      SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
      IF DB_ServerPort_v != '' THEN
          SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
      END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `e911_address`
--

DROP TABLE IF EXISTS `e911_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `e911_address` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `location_id` char(4) NOT NULL DEFAULT '',
  `did` char(11) NOT NULL DEFAULT '',
  `caller_name` char(20) NOT NULL DEFAULT '',
  `address1` char(40) NOT NULL DEFAULT '',
  `address2` char(40) NOT NULL DEFAULT '',
  `city` char(30) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(5) NOT NULL DEFAULT '',
  `status` char(5) NOT NULL DEFAULT '' COMMENT 'P=Provisioned; E=Edited',
  `provision_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `did` (`did`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `facility`
--

DROP TABLE IF EXISTS `facility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `facility` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `facility_id` char(3) NOT NULL DEFAULT '',
  `street` char(50) NOT NULL DEFAULT '',
  `city` char(30) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(5) NOT NULL DEFAULT '',
  `latitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `longitude` decimal(10,7) NOT NULL DEFAULT '0.0000000',
  `lat` char(3) NOT NULL DEFAULT '' COMMENT '3 digit round',
  `lon` char(3) NOT NULL DEFAULT '' COMMENT '3 digit round unsigned',
  `event` char(2) NOT NULL DEFAULT '',
  `event_key` char(11) NOT NULL DEFAULT '',
  PRIMARY KEY (`account_id`,`facility_id`),
  KEY `account_id` (`account_id`),
  KEY `lon` (`account_id`,`lon`),
  KEY `lat` (`account_id`,`lat`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faq`
--

DROP TABLE IF EXISTS `faq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faq` (
  `faq_id` char(3) NOT NULL DEFAULT '',
  `group_id` char(1) NOT NULL DEFAULT '',
  `sub_group_id` char(3) NOT NULL DEFAULT '',
  `question` char(255) NOT NULL DEFAULT '',
  `answer` text NOT NULL,
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A=Active, I=Inactive',
  PRIMARY KEY (`faq_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faq_group`
--

DROP TABLE IF EXISTS `faq_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faq_group` (
  `group_id` char(1) NOT NULL DEFAULT '',
  `title` char(30) NOT NULL DEFAULT '',
  `icon_class` char(20) NOT NULL DEFAULT '',
  `icon_color` char(7) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT 'A',
  PRIMARY KEY (`group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faq_sub_group`
--

DROP TABLE IF EXISTS `faq_sub_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faq_sub_group` (
  `sub_group_id` char(3) NOT NULL,
  `title` char(150) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A=Active, I=Inactive',
  PRIMARY KEY (`sub_group_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fax_cover_page`
--

DROP TABLE IF EXISTS `fax_cover_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fax_cover_page` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `call_id` char(20) NOT NULL DEFAULT '',
  `cover_page_opt` char(1) NOT NULL DEFAULT '',
  `num_pages` decimal(2,0) unsigned NOT NULL DEFAULT '0',
  `from_name` char(35) NOT NULL DEFAULT '',
  `from_company` char(35) NOT NULL DEFAULT '',
  `to_name` char(35) NOT NULL DEFAULT '',
  `to_company` char(35) NOT NULL DEFAULT '',
  `subject` char(150) NOT NULL DEFAULT '',
  `note` text NOT NULL,
  KEY `call_id` (`account_id`,`call_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fax_label`
--

DROP TABLE IF EXISTS `fax_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fax_label` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `label_id` char(1) NOT NULL DEFAULT '',
  `title` char(20) NOT NULL DEFAULT '',
  UNIQUE KEY `account_label` (`account_id`,`label_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faxes_out`
--

DROP TABLE IF EXISTS `faxes_out`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faxes_out` (
  `tstamp` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `fax_id` char(20) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `user_id` char(6) NOT NULL DEFAULT '',
  `did` char(13) NOT NULL DEFAULT '',
  `dial_number` char(15) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT 'N',
  `email` char(50) NOT NULL DEFAULT '',
  `offset_to_utc` decimal(3,0) NOT NULL DEFAULT '0',
  KEY `account_id_fax` (`account_id`,`fax_id`),
  KEY `tstamp` (`tstamp`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `geo_location`
--

DROP TABLE IF EXISTS `geo_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `geo_location` (
  `ip` char(15) NOT NULL DEFAULT '',
  `city` char(30) NOT NULL DEFAULT '',
  `country` char(30) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT '',
  `isp` char(40) NOT NULL DEFAULT '',
  `lat` char(10) NOT NULL DEFAULT '',
  `lon` char(10) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `state_name` char(30) NOT NULL DEFAULT '',
  `timezone` char(40) NOT NULL DEFAULT '',
  `is_dst` char(1) NOT NULL DEFAULT '',
  `gmt_offset` char(6) NOT NULL DEFAULT '',
  `zip` char(10) NOT NULL DEFAULT '',
  `tstamp` char(10) NOT NULL DEFAULT '',
  UNIQUE KEY `ip` (`ip`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `greetings`
--

DROP TABLE IF EXISTS `greetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `greetings` (
  `userid` char(6) NOT NULL DEFAULT '',
  `gr_id` char(1) NOT NULL DEFAULT '' COMMENT '[], 0,1,2,.....11',
  `title` char(30) NOT NULL,
  `file_name` char(16) NOT NULL,
  UNIQUE KEY `userid_gr` (`userid`,`gr_id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_misslogin`
--

DROP TABLE IF EXISTS `history_misslogin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_misslogin` (
  `hit_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `account_id` char(6) NOT NULL DEFAULT '',
  `ip` char(15) NOT NULL DEFAULT '',
  KEY `phone_date` (`account_id`,`hit_date`) USING BTREE,
  KEY `ip_date` (`ip`,`hit_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `holiday_announcement`
--

DROP TABLE IF EXISTS `holiday_announcement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `holiday_announcement` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `holiday` date NOT NULL DEFAULT '0000-00-00',
  `title` char(25) NOT NULL DEFAULT '',
  `start_hour` char(2) NOT NULL DEFAULT '00',
  `ivr_branch` char(10) NOT NULL DEFAULT '' COMMENT 'IVR Node without IVR ID',
  KEY `account_id` (`account_id`,`holiday`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ivr`
--

DROP TABLE IF EXISTS `ivr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ivr` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `ivr_id` char(6) NOT NULL DEFAULT '',
  `ivr_name` char(30) NOT NULL DEFAULT '',
  `dtmf_timeout` char(2) NOT NULL DEFAULT '10',
  `ivr_timeout` char(3) NOT NULL DEFAULT '600',
  `timeout_action` char(2) NOT NULL DEFAULT 'HU',
  `value` char(1) NOT NULL DEFAULT '',
  `language` char(2) NOT NULL DEFAULT '',
  `TTS` char(1) NOT NULL DEFAULT '',
  `dayhour` char(30) NOT NULL DEFAULT '',
  `welcome_voice` char(1) NOT NULL DEFAULT 'N',
  `holiday_announcement` char(1) NOT NULL DEFAULT '',
  `debug_cli_filter` char(13) NOT NULL DEFAULT '',
  `debug_expire_time` decimal(10,0) NOT NULL DEFAULT '0',
  `TTS_update` char(1) NOT NULL DEFAULT '',
  `active` char(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`ivr_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ivr_tree`
--

DROP TABLE IF EXISTS `ivr_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ivr_tree` (
  `ivr_id` char(6) NOT NULL DEFAULT '',
  `branch` char(20) NOT NULL DEFAULT '',
  `event` char(2) NOT NULL DEFAULT '',
  `event_key` char(20) NOT NULL DEFAULT '',
  `arg` char(20) NOT NULL DEFAULT '',
  `text` char(255) NOT NULL DEFAULT '',
  `TTS_update` char(1) NOT NULL DEFAULT '',
  UNIQUE KEY `branch` (`branch`),
  KEY `ivr_id` (`ivr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ledger`
--

DROP TABLE IF EXISTS `ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ledger` (
  `sl` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` char(6) NOT NULL DEFAULT '',
  `invoice_number` char(8) NOT NULL DEFAULT '',
  `narration` char(75) NOT NULL,
  `date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `prev_balance` double NOT NULL DEFAULT '0',
  `amount` double unsigned DEFAULT '0',
  `ip` char(15) NOT NULL DEFAULT '',
  `entry_type` char(1) NOT NULL COMMENT 'B=Bonus,R=Refil,D=Deduct,I=Initial Recharge, P=Promo',
  `entry_ref` char(1) NOT NULL COMMENT 'C=Credit card, L=Paypal,M=Merchant, A=Admin, O=Offer, P=Promo. ',
  `ref_id` char(12) NOT NULL DEFAULT '',
  PRIMARY KEY (`sl`),
  KEY `date` (`date`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM AUTO_INCREMENT=220 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `location` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `userid` char(6) NOT NULL DEFAULT '',
  `extn` char(11) NOT NULL DEFAULT '',
  `ip` char(15) NOT NULL DEFAULT '',
  `location` char(21) NOT NULL DEFAULT '',
  `pin_prefix` char(1) NOT NULL DEFAULT '',
  `in_nat` char(1) NOT NULL DEFAULT '',
  `tstamp` decimal(10,0) NOT NULL DEFAULT '0',
  `location_id` char(1) NOT NULL DEFAULT '',
  UNIQUE KEY `userid` (`userid`,`pin_prefix`),
  KEY `location` (`location`),
  KEY `tstamp` (`tstamp`),
  KEY `account_id` (`account_id`,`extn`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER location_add AFTER INSERT ON location
FOR EACH ROW
BEGIN
  
  IF new.pin_prefix = 1 THEN
    UPDATE user_profile SET app_reg_status='R' WHERE userid=new.userid;
  ELSE
    UPDATE user_profile SET device_reg_status='R' WHERE userid=new.userid;
  END IF;
  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER location_del AFTER DELETE ON location
FOR EACH ROW
BEGIN

 DECLARE cnt_v int;
  
  IF old.pin_prefix = 1 THEN
    UPDATE user_profile SET app_reg_status='' WHERE userid=old.userid;
  ELSE
    SELECT COUNT(*) INTO cnt_v FROM location WHERE userid=old.userid AND pin_prefix > 1;
    IF cnt_v = 0 THEN 
        UPDATE user_profile SET device_reg_status='' WHERE userid=old.userid;
    END IF;
  END IF;
  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `macro`
--

DROP TABLE IF EXISTS `macro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `macro` (
  `macro_id` char(6) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `code` char(3) NOT NULL DEFAULT '',
  `title` char(30) NOT NULL DEFAULT '',
  `password` char(6) NOT NULL DEFAULT '',
  UNIQUE KEY `account_id` (`account_id`,`code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `macro_settings`
--

DROP TABLE IF EXISTS `macro_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `macro_settings` (
  `macro_id` char(6) NOT NULL DEFAULT '',
  `did` char(10) NOT NULL DEFAULT '',
  `action` char(2) NOT NULL DEFAULT '',
  `param` char(30) NOT NULL DEFAULT '',
  `arg` char(8) NOT NULL DEFAULT '',
  KEY `macro_id` (`macro_id`),
  KEY `did` (`did`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `npa`
--

DROP TABLE IF EXISTS `npa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `npa` (
  `npa` char(3) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT '',
  PRIMARY KEY (`npa`),
  KEY `state` (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `number_proting`
--

DROP TABLE IF EXISTS `number_proting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `number_proting` (
  `log_date` date NOT NULL DEFAULT '0000-00-00',
  `account_id` char(6) NOT NULL DEFAULT '',
  `order_id` char(8) NOT NULL DEFAULT '',
  `did` char(11) NOT NULL DEFAULT '',
  `service_provider` char(25) NOT NULL DEFAULT '',
  `account_number` char(20) NOT NULL DEFAULT '',
  `last_4_digit_ssn` char(4) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '' COMMENT 'N=New; S=Submited; P=Pending; I=InProcess; F=FOC; R=Info Requested; A=Action Required; C=Completed; X=Cancle',
  `update_date` date NOT NULL DEFAULT '0000-00-00',
  `foc_date` date NOT NULL DEFAULT '0000-00-00',
  UNIQUE KEY `did` (`did`),
  KEY `log_date` (`log_date`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page_group`
--

DROP TABLE IF EXISTS `page_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page_group` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `group_id` char(4) NOT NULL DEFAULT '',
  `department_id` char(6) NOT NULL DEFAULT '',
  `barge` char(1) NOT NULL DEFAULT '',
  `port` char(5) NOT NULL DEFAULT '',
  UNIQUE KEY `group_id` (`group_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `park_group`
--

DROP TABLE IF EXISTS `park_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `park_group` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `group_id` char(4) NOT NULL DEFAULT '',
  `label` char(20) NOT NULL DEFAULT '',
  `no_of_park_spot` decimal(1,0) NOT NULL DEFAULT '0',
  `first_key` decimal(2,0) NOT NULL DEFAULT '0',
  `first_hold_threshold` decimal(3,0) NOT NULL DEFAULT '0' COMMENT 'in sec',
  `next_hold_threshold` decimal(3,0) NOT NULL DEFAULT '0' COMMENT 'in sec',
  `active` char(1) NOT NULL DEFAULT 'Y',
  UNIQUE KEY `group_id` (`group_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_log`
--

DROP TABLE IF EXISTS `payment_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_log` (
  `invoice_number` char(8) NOT NULL DEFAULT '',
  `payment_id` char(8) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `amount` decimal(6,2) NOT NULL DEFAULT '0.00',
  `name_on_card` char(25) NOT NULL DEFAULT '',
  `street` char(30) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(8) NOT NULL DEFAULT '',
  `country` char(15) NOT NULL DEFAULT '',
  `cc_data_aes` char(96) NOT NULL DEFAULT '',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `exp_date` char(4) NOT NULL DEFAULT '',
  `transaction_id` char(40) NOT NULL DEFAULT '',
  `approval_code` char(12) NOT NULL DEFAULT '',
  `process_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `transaction_time` char(22) NOT NULL DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `result` char(1) NOT NULL DEFAULT '',
  `result_msg` char(150) NOT NULL DEFAULT '',
  `response_reason` char(3) NOT NULL DEFAULT '',
  `cvv2_response` char(1) NOT NULL DEFAULT '',
  `avs_response` char(1) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `process_status` char(6) NOT NULL DEFAULT '',
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `update_time` (`update_time`),
  KEY `account_id` (`account_id`),
  KEY `last_4_digit` (`last_4_digit`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_revarsal_log`
--

DROP TABLE IF EXISTS `payment_revarsal_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_revarsal_log` (
  `invoice_number` char(8) NOT NULL DEFAULT '' COMMENT 'C= Credit, V= Void',
  `account_id` char(6) NOT NULL DEFAULT '',
  `amount` decimal(5,2) NOT NULL DEFAULT '0.00',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `transaction_id` char(40) NOT NULL DEFAULT '',
  `ref_transaction_id` char(40) NOT NULL DEFAULT '',
  `approval_code` char(12) NOT NULL DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `result` char(1) NOT NULL DEFAULT '',
  `result_msg` char(150) NOT NULL DEFAULT '',
  `note` char(150) NOT NULL DEFAULT '',
  `response_reason` char(3) NOT NULL DEFAULT '',
  `cvv2_response` char(1) NOT NULL DEFAULT '',
  `avs_response` char(1) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `process_status` char(6) NOT NULL DEFAULT '',
  `trans_type` char(1) NOT NULL DEFAULT '',
  KEY `invoice_number` (`invoice_number`),
  KEY `update_time` (`update_time`),
  KEY `account_id` (`account_id`),
  KEY `last_4_digit` (`last_4_digit`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pbx_log`
--

DROP TABLE IF EXISTS `pbx_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pbx_log` (
  `user_id` char(15) NOT NULL DEFAULT '',
  `user_type` char(1) NOT NULL DEFAULT 'C' COMMENT 'E=Extn, A=Admin,C=Company',
  `account_id` char(6) NOT NULL DEFAULT '',
  `extn` char(3) DEFAULT '',
  `changed_page` char(30) NOT NULL DEFAULT '',
  `changed_type` char(1) NOT NULL DEFAULT 'U' COMMENT 'U=Update, A=ADD, D=Delete,O=Others',
  `changed_value` char(250) NOT NULL DEFAULT '',
  `msg_code` char(4) NOT NULL DEFAULT '',
  `msg_param` char(150) NOT NULL DEFAULT '',
  `ip` char(15) NOT NULL DEFAULT '',
  `date_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcipp_gateway`
--

DROP TABLE IF EXISTS `pcipp_gateway`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcipp_gateway` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `gateway_id` char(4) NOT NULL DEFAULT '',
  `gw_name` char(20) NOT NULL DEFAULT '',
  `login_id` char(20) NOT NULL DEFAULT '',
  `key_string` char(64) NOT NULL DEFAULT '',
  UNIQUE KEY `gateway_id` (`gateway_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcipp_payment_log`
--

DROP TABLE IF EXISTS `pcipp_payment_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcipp_payment_log` (
  `payment_id` char(8) NOT NULL DEFAULT '',
  `product_id` char(5) NOT NULL DEFAULT '',
  `gateway_id` char(4) NOT NULL DEFAULT '',
  `callid` char(20) NOT NULL DEFAULT '',
  `input_method` char(1) NOT NULL DEFAULT '' COMMENT 'M=Manual, D=DTMF',
  `userid` char(6) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `amount` decimal(6,2) NOT NULL DEFAULT '0.00',
  `name_on_card` char(25) NOT NULL DEFAULT '',
  `street` char(30) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `zip` char(8) NOT NULL DEFAULT '',
  `country` char(15) NOT NULL DEFAULT '',
  `cc_display` char(16) NOT NULL DEFAULT '',
  `last_4_digit` char(4) NOT NULL DEFAULT '',
  `exp_date` char(4) NOT NULL DEFAULT '' COMMENT 'MMYY',
  `transaction_id` char(40) NOT NULL DEFAULT '',
  `approval_code` char(12) NOT NULL DEFAULT '',
  `process_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `transaction_time` char(22) NOT NULL DEFAULT '',
  `update_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `result` char(1) NOT NULL DEFAULT '',
  `result_msg` char(150) NOT NULL DEFAULT '',
  `response_reason` char(3) NOT NULL DEFAULT '',
  `cvv2_response` char(1) NOT NULL DEFAULT '',
  `avs_response` char(1) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `process_status` char(6) NOT NULL DEFAULT '',
  `reference_id` char(32) NOT NULL DEFAULT '',
  KEY `account_update` (`account_id`,`update_time`),
  KEY `last_4_digit` (`last_4_digit`),
  KEY `callid` (`callid`),
  KEY `payment_id` (`payment_id`),
  KEY `account_user` (`account_id`,`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcipp_payment_note`
--

DROP TABLE IF EXISTS `pcipp_payment_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcipp_payment_note` (
  `payment_id` char(8) NOT NULL DEFAULT '',
  `note` text NOT NULL,
  KEY `payment_id` (`payment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcipp_product`
--

DROP TABLE IF EXISTS `pcipp_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcipp_product` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `product_id` char(5) NOT NULL DEFAULT '',
  `gateway_id` char(4) NOT NULL DEFAULT '',
  `product_name` char(30) NOT NULL DEFAULT '',
  `cc_display_mask` char(16) NOT NULL DEFAULT '',
  `cvv_display_mask` char(4) NOT NULL DEFAULT '',
  `exp_display_mask` char(4) NOT NULL DEFAULT '',
  `zip_display_mask` char(5) NOT NULL DEFAULT '',
  `exp_input_method` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Manual, D=DTMF',
  `zip_input_method` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Manual, D=DTMF',
  `max_apt` decimal(5,0) NOT NULL DEFAULT '0' COMMENT 'max_amount_per_transaction by card',
  `max_apd` decimal(5,0) NOT NULL DEFAULT '0' COMMENT 'max_amount_per_day by card',
  `max_tcph` decimal(4,0) NOT NULL DEFAULT '0' COMMENT 'max_transaction_count_per_hour by card',
  `max_tcpd` decimal(4,0) NOT NULL DEFAULT '0' COMMENT 'max_transaction_count_per_day by card',
  UNIQUE KEY `product_id` (`product_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pcipp_session`
--

DROP TABLE IF EXISTS `pcipp_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pcipp_session` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `userid` char(6) NOT NULL DEFAULT '',
  `browser_ip` char(15) NOT NULL DEFAULT '',
  `callid` char(20) NOT NULL DEFAULT '',
  `product_id` char(5) NOT NULL DEFAULT '',
  `gateway_id` char(4) NOT NULL DEFAULT '',
  `session_start` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `session_stop` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `error_count` decimal(2,0) NOT NULL DEFAULT '0',
  `cc` char(28) NOT NULL DEFAULT '',
  `cvv` char(16) NOT NULL DEFAULT '',
  `exp` char(16) NOT NULL DEFAULT '',
  `zip` char(16) NOT NULL DEFAULT '',
  `applied_field` char(3) NOT NULL DEFAULT '',
  `display_mask` char(16) NOT NULL DEFAULT '',
  `cc_display` char(16) NOT NULL DEFAULT '',
  `cvv_display` char(4) NOT NULL DEFAULT '',
  `exp_display` char(4) NOT NULL DEFAULT '',
  `zip_display` char(5) NOT NULL DEFAULT '',
  UNIQUE KEY `userid` (`userid`),
  UNIQUE KEY `callid` (`callid`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provision_code`
--

DROP TABLE IF EXISTS `provision_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provision_code` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `code` char(4) DEFAULT NULL,
  `expire` decimal(10,0) NOT NULL DEFAULT '0',
  UNIQUE KEY `account_id` (`account_id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ring_group`
--

DROP TABLE IF EXISTS `ring_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ring_group` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `group_id` char(6) NOT NULL DEFAULT '',
  `sl` decimal(2,0) NOT NULL DEFAULT '0',
  `event` char(2) NOT NULL DEFAULT '',
  `param` char(12) NOT NULL DEFAULT '',
  `ring_after` decimal(2,0) NOT NULL DEFAULT '0' COMMENT 'in-sec',
  UNIQUE KEY `group_id` (`group_id`,`sl`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ring_group_profile`
--

DROP TABLE IF EXISTS `ring_group_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ring_group_profile` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `group_id` char(6) NOT NULL DEFAULT '',
  `name` char(25) NOT NULL DEFAULT '',
  `continue_ring` char(1) NOT NULL DEFAULT 'Y',
  `ring_to_busy_extn` char(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`group_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `server`
--

DROP TABLE IF EXISTS `server`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `server` (
  `location_id` char(1) NOT NULL DEFAULT '',
  `name` char(20) NOT NULL DEFAULT '',
  `mac` char(12) NOT NULL DEFAULT '',
  `switch_ip` char(15) NOT NULL DEFAULT '',
  `switch_port` char(5) NOT NULL DEFAULT '',
  `rtp_ip_A` char(15) NOT NULL DEFAULT '',
  `rtp_ip_B` char(15) NOT NULL DEFAULT '',
  `token` char(8) NOT NULL DEFAULT '',
  `auth_key` char(32) NOT NULL DEFAULT '',
  `sw_version` char(8) NOT NULL DEFAULT '',
  `active` char(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`location_id`),
  UNIQUE KEY `mac` (`mac`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER server_upd AFTER UPDATE ON server
FOR EACH ROW
BEGIN

  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';

  IF old.rtp_ip_A != new.rtp_ip_A OR old.rtp_ip_B != new.rtp_ip_B THEN

     SET msg_v = CONCAT('DB_TRIGGER\r\ntable: SERVER\r\n', 'mac: ', new.mac, '\r\n');
     SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
     IF DB_ServerPort_v != '' THEN
         SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
     END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `service_active`
--

DROP TABLE IF EXISTS `service_active`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_active` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `service_code` char(4) NOT NULL DEFAULT '',
  `unit` decimal(3,0) NOT NULL DEFAULT '0',
  `service_end_date` date NOT NULL DEFAULT '0000-00-00',
  `discount` decimal(5,2) NOT NULL DEFAULT '0.00',
  `discount_type` char(1) NOT NULL DEFAULT '' COMMENT 'P=percent, F=fixed, U=unit',
  `day_of_billing` char(2) NOT NULL DEFAULT '',
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_deal`
--

DROP TABLE IF EXISTS `service_deal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_deal` (
  `deal_id` decimal(6,0) NOT NULL DEFAULT '0',
  `plan_code` char(2) NOT NULL DEFAULT '',
  `pay_x_month` decimal(2,0) NOT NULL DEFAULT '0',
  `free_device` decimal(1,0) NOT NULL DEFAULT '0',
  `service_code` char(4) NOT NULL DEFAULT '',
  `device_cost` decimal(5,2) NOT NULL DEFAULT '0.00',
  `valid_date` date NOT NULL DEFAULT '0000-00-00',
  `note` char(255) NOT NULL DEFAULT '',
  UNIQUE KEY `deal_id` (`deal_id`),
  KEY `plan_code` (`plan_code`),
  KEY `valid_date` (`valid_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_free_destination`
--

DROP TABLE IF EXISTS `service_free_destination`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_free_destination` (
  `gcode` char(12) NOT NULL DEFAULT '',
  UNIQUE KEY `plan_code` (`gcode`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_invoice_dids`
--

DROP TABLE IF EXISTS `service_invoice_dids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_invoice_dids` (
  `invoice_number` char(8) NOT NULL,
  `did` char(12) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT '',
  `service_type` char(2) NOT NULL DEFAULT '',
  KEY `invoice_number` (`invoice_number`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_invoice_records`
--

DROP TABLE IF EXISTS `service_invoice_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_invoice_records` (
  `invoice_number` char(8) NOT NULL,
  `service_code` char(4) NOT NULL DEFAULT '' COMMENT 'Plan code Or Promocode',
  `title` char(60) NOT NULL,
  `sub_title` char(150) NOT NULL DEFAULT '',
  `service_quantity` decimal(3,0) NOT NULL,
  `service_price` decimal(5,2) NOT NULL,
  `service_discount` decimal(5,2) NOT NULL,
  `billing_cycle` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Monthly, O=One time',
  `srv_type` char(1) NOT NULL DEFAULT '' COMMENT 'T=Telecom, S=Software, H=hardware',
  KEY `account_id_invoice_number` (`invoice_number`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_invoice_records_info`
--

DROP TABLE IF EXISTS `service_invoice_records_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_invoice_records_info` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `invoice_number` char(8) NOT NULL DEFAULT '',
  `account_inv_sl` decimal(3,0) NOT NULL DEFAULT '0',
  `invoice_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `billing_period_start` date NOT NULL DEFAULT '0000-00-00',
  `billing_period_end` date NOT NULL DEFAULT '0000-00-00',
  `street` char(25) NOT NULL DEFAULT '',
  `suite` char(5) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `county` char(20) NOT NULL DEFAULT '',
  `zip` char(5) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT 'US',
  `due_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `total_invoice_amount` decimal(7,2) NOT NULL DEFAULT '0.00',
  `current_balance` decimal(7,2) NOT NULL DEFAULT '0.00',
  `previous_balance` decimal(7,2) NOT NULL DEFAULT '0.00',
  `last_ledger_amount` decimal(7,2) NOT NULL DEFAULT '0.00',
  `due_amount` decimal(7,2) NOT NULL DEFAULT '0.00',
  `last_ledger_date` date NOT NULL DEFAULT '0000-00-00',
  `last_ledger_type` char(2) NOT NULL DEFAULT '',
  `payment_method` char(2) NOT NULL DEFAULT '' COMMENT 'AH-ACH, CC-Credit Card, CH-Check, CA-Cash',
  `is_paid` char(1) NOT NULL DEFAULT 'N',
  `is_downloadable` char(1) NOT NULL DEFAULT 'Y',
  KEY `invoice_number` (`invoice_number`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_invoice_records_tax`
--

DROP TABLE IF EXISTS `service_invoice_records_tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_invoice_records_tax` (
  `invoice_number` char(8) NOT NULL DEFAULT '',
  `tax_code` char(6) NOT NULL DEFAULT '',
  `c_value` decimal(8,6) NOT NULL DEFAULT '0.000000' COMMENT 'City Tax',
  `cn_value` decimal(8,6) NOT NULL DEFAULT '0.000000' COMMENT 'County Value',
  `s_value` decimal(8,6) NOT NULL DEFAULT '0.000000' COMMENT 'State Tax',
  `f_value` decimal(8,6) NOT NULL DEFAULT '0.000000' COMMENT 'Federal Tax',
  `t_value` decimal(7,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Tax Value',
  `invoice_head` char(2) NOT NULL DEFAULT '',
  `f_s_rate` decimal(8,6) NOT NULL,
  `c_rate` decimal(8,6) NOT NULL,
  `cn_rate` decimal(8,6) NOT NULL DEFAULT '0.000000',
  `cal_type` char(1) NOT NULL DEFAULT 'P',
  `break_down_code` char(10) NOT NULL DEFAULT '',
  `bill_type` char(1) NOT NULL DEFAULT 'M' COMMENT 'M=Montly, O=One Time',
  KEY `state_code` (`tax_code`) USING BTREE,
  KEY `tax_code` (`tax_code`) USING BTREE,
  KEY `invoice_number` (`invoice_number`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_invoice_records_tax_breakdown`
--

DROP TABLE IF EXISTS `service_invoice_records_tax_breakdown`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_invoice_records_tax_breakdown` (
  `invoice_number` char(8) NOT NULL,
  `service_code` char(4) NOT NULL DEFAULT '0000',
  `break_down_code` char(10) NOT NULL DEFAULT '',
  `amount` decimal(6,4) NOT NULL DEFAULT '0.0000'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_list`
--

DROP TABLE IF EXISTS `service_list`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_list` (
  `service_code` char(4) NOT NULL DEFAULT '',
  `title` char(80) NOT NULL DEFAULT '',
  `sub_title` char(160) NOT NULL DEFAULT '',
  `type` char(1) NOT NULL DEFAULT '' COMMENT 'T=Telecom, S=Software, H=hardware',
  `unit_name` char(8) NOT NULL DEFAULT '',
  KEY `service_code` (`service_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER service_list_a AFTER INSERT ON service_list
FOR EACH ROW
BEGIN

	IF new.service_code = 'T000' OR new.service_code = 'T001' THEN
		CALL ReloadTFAndIntTax(new.service_code);
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER service_list_d AFTER DELETE ON service_list
FOR EACH ROW
BEGIN

	IF old.service_code = 'T000' OR old.service_code = 'T001' THEN
		CALL ReloadTFAndIntTax(old.service_code);
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `service_log`
--

DROP TABLE IF EXISTS `service_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_log` (
  `log_date` date NOT NULL DEFAULT '0000-00-00',
  `account_id` char(6) NOT NULL DEFAULT '',
  `plan_code` char(2) NOT NULL DEFAULT '',
  `service_code` char(4) NOT NULL DEFAULT '',
  `unit` decimal(3,0) NOT NULL DEFAULT '0',
  `price` decimal(4,2) NOT NULL DEFAULT '0.00',
  `discount_at_rate` decimal(4,1) NOT NULL DEFAULT '0.0',
  `service_covered_till` date NOT NULL DEFAULT '0000-00-00',
  `type` char(1) NOT NULL DEFAULT '',
  KEY `account_id` (`account_id`,`log_date`),
  KEY `log_date` (`log_date`,`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_plan`
--

DROP TABLE IF EXISTS `service_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_plan` (
  `sl` char(1) NOT NULL DEFAULT '',
  `plan_type` char(1) NOT NULL DEFAULT '',
  `plan_code` char(2) NOT NULL DEFAULT '',
  `plan_title` char(20) NOT NULL DEFAULT '',
  `minimum_no_of_extn` decimal(2,0) NOT NULL DEFAULT '0',
  `domestic_call` char(1) NOT NULL DEFAULT '',
  `domestic_area` char(20) NOT NULL DEFAULT '',
  `domestic_call_monthly_limit` decimal(4,0) NOT NULL DEFAULT '0',
  `domestic_call_over_use_rate` decimal(4,2) NOT NULL DEFAULT '0.00',
  `domestic_minutes_rollover_month` decimal(1,0) NOT NULL DEFAULT '0',
  `tollfree_call_monthly_limit` decimal(4,0) NOT NULL DEFAULT '0',
  `tollfree_call_over_use_rate` decimal(4,2) NOT NULL DEFAULT '0.00',
  `tollfree_minutes_rollover_month` decimal(1,0) NOT NULL DEFAULT '0',
  PRIMARY KEY (`plan_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_price`
--

DROP TABLE IF EXISTS `service_price`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_price` (
  `plan_code` char(2) NOT NULL DEFAULT '',
  `service_code` char(4) NOT NULL DEFAULT '',
  `yield_code` char(6) NOT NULL DEFAULT '',
  `billing_cycle` char(1) NOT NULL DEFAULT '',
  `price` decimal(5,2) NOT NULL DEFAULT '0.00',
  `display_price` decimal(5,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`yield_code`),
  KEY `service_code` (`service_code`,`plan_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER distributor_yield_drop AFTER DELETE ON service_price
FOR EACH ROW
BEGIN

  IF LEFT(old.service_code,1) = 'S' THEN
      DELETE FROM distributor_yield WHERE yield_code=old.yield_code;
  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `service_promocode`
--

DROP TABLE IF EXISTS `service_promocode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_promocode` (
  `promocode` char(8) NOT NULL DEFAULT '',
  `plancode` char(2) NOT NULL DEFAULT '',
  `promo_title` char(40) NOT NULL DEFAULT '',
  `service_code` char(4) NOT NULL DEFAULT '',
  `billing_cycle` char(1) NOT NULL DEFAULT '',
  `price` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT 'Per extension price',
  `discount` decimal(5,2) NOT NULL DEFAULT '0.00',
  `minimum_no_of_extn` decimal(2,0) NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A=Active, I=Inactive, U=Used',
  UNIQUE KEY `plancode` (`plancode`,`promocode`,`service_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_tax`
--

DROP TABLE IF EXISTS `service_tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_tax` (
  `service_code` char(4) NOT NULL DEFAULT '',
  `tax_code` char(10) NOT NULL DEFAULT '',
  UNIQUE KEY `service_tax_code` (`service_code`,`tax_code`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER service_tax_a AFTER INSERT ON service_tax
FOR EACH ROW
BEGIN

	IF new.service_code = 'T000' OR new.service_code = 'T001' THEN
		CALL ReloadTFAndIntTax(new.service_code);
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER service_tax_d AFTER DELETE ON service_tax
FOR EACH ROW
BEGIN

	IF old.service_code = 'T000' OR old.service_code = 'T001' THEN
		CALL ReloadTFAndIntTax(old.service_code);
	END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `db_ip` char(15) NOT NULL DEFAULT '',
  `db_port` char(5) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sip_code`
--

DROP TABLE IF EXISTS `sip_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sip_code` (
  `disc_cause` char(3) NOT NULL DEFAULT '',
  `string` char(100) DEFAULT NULL,
  UNIQUE KEY `disc_cause` (`disc_cause`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sip_trunk`
--

DROP TABLE IF EXISTS `sip_trunk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sip_trunk` (
  `trunk_id` char(1) NOT NULL DEFAULT '',
  `label` char(12) NOT NULL DEFAULT '',
  `gw_ip` char(15) NOT NULL DEFAULT '',
  `gw_port` char(5) NOT NULL DEFAULT '',
  `dial_in_prefix` char(8) NOT NULL DEFAULT '',
  `dial_out_prefix` char(8) NOT NULL DEFAULT '',
  `min_number_len` char(2) NOT NULL DEFAULT '',
  `max_number_len` char(2) NOT NULL DEFAULT '',
  `ch_capacity` decimal(3,0) NOT NULL DEFAULT '0',
  `priority` decimal(1,0) NOT NULL DEFAULT '5',
  `rewrite_cli` char(11) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A=Active; I=Inactive',
  PRIMARY KEY (`trunk_id`),
  KEY `dial_in_prefix` (`dial_in_prefix`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER sip_trunk_upd AFTER UPDATE ON sip_trunk
FOR EACH ROW
BEGIN

  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';

  IF old.status !=new.status OR old.dial_in_prefix != new.dial_in_prefix OR old.dial_out_prefix != new.dial_out_prefix OR 
        old.min_number_len != new.min_number_len OR old.max_number_len != new.max_number_len OR old.ch_capacity != new.ch_capacity OR 
        old.priority != new.priority OR old.rewrite_cli != new.rewrite_cli THEN

     SET msg_v = CONCAT('DB_TRIGGER\r\ntable: SIP_TRUNK\r\n', 'trunk_id: ', new.trunk_id, '\r\n');
     SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
     IF DB_ServerPort_v != '' THEN
         SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
     END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `site_pages`
--

DROP TABLE IF EXISTS `site_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_pages` (
  `id` char(2) NOT NULL,
  `page_url` char(150) NOT NULL,
  `page_name` char(50) NOT NULL,
  `add_date` datetime NOT NULL,
  `status` char(1) NOT NULL DEFAULT 'A' COMMENT 'A= Active, I=Inactivie, D=Only for Root user',
  PRIMARY KEY (`id`),
  UNIQUE KEY `page_url` (`page_url`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `speed_dial`
--

DROP TABLE IF EXISTS `speed_dial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `speed_dial` (
  `userid` char(6) NOT NULL DEFAULT '',
  `speed_key` decimal(2,0) NOT NULL DEFAULT '1',
  `name` char(20) NOT NULL DEFAULT '',
  `dst_number` char(13) NOT NULL DEFAULT '',
  PRIMARY KEY (`userid`,`speed_key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `state`
--

DROP TABLE IF EXISTS `state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `state` (
  `state_code` char(2) NOT NULL DEFAULT '',
  `state_name` char(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`state_code`),
  KEY `state_name` (`state_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_by_state`
--

DROP TABLE IF EXISTS `tax_by_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_by_state` (
  `state_code` char(2) NOT NULL DEFAULT '',
  `tax_code` char(6) NOT NULL DEFAULT '',
  `value` decimal(7,5) NOT NULL DEFAULT '0.00000',
  UNIQUE KEY `code` (`state_code`,`tax_code`),
  KEY `state_code` (`state_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_code`
--

DROP TABLE IF EXISTS `tax_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_code` (
  `tax_code` char(10) NOT NULL DEFAULT '',
  `tax_title` char(150) NOT NULL DEFAULT '',
  `tax_head` char(10) NOT NULL DEFAULT '',
  `break_down_code` char(6) NOT NULL DEFAULT '',
  PRIMARY KEY (`tax_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_federal`
--

DROP TABLE IF EXISTS `tax_federal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_federal` (
  `tax_code` char(10) NOT NULL DEFAULT '',
  `inv_head_id` char(2) NOT NULL DEFAULT '',
  `tax_value` decimal(8,6) NOT NULL DEFAULT '0.000000',
  `cal_type` char(1) NOT NULL DEFAULT 'P',
  KEY `tax_code` (`tax_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER tax_federal_u AFTER UPDATE ON tax_federal
FOR EACH ROW
BEGIN
	CALL ReloadTFAndIntTax('T000');
	CALL ReloadTFAndIntTax('T001');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER tax_federal_d AFTER DELETE ON tax_federal
FOR EACH ROW
BEGIN
	CALL ReloadTFAndIntTax('T000');
	CALL ReloadTFAndIntTax('T001');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tax_invoice_head`
--

DROP TABLE IF EXISTS `tax_invoice_head`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_invoice_head` (
  `inv_head_id` char(2) NOT NULL DEFAULT 'AA',
  `title` char(200) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_service_charge_breakdown`
--

DROP TABLE IF EXISTS `tax_service_charge_breakdown`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_service_charge_breakdown` (
  `break_down_code` char(6) NOT NULL DEFAULT '',
  `title` char(100) NOT NULL DEFAULT '',
  `basis` decimal(2,0) NOT NULL DEFAULT '0',
  UNIQUE KEY `break_down_code` (`break_down_code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_state`
--

DROP TABLE IF EXISTS `tax_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_state` (
  `tax_code` char(10) NOT NULL DEFAULT '',
  `inv_head_id` char(2) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `city_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `state_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `county_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `cal_type` char(1) NOT NULL DEFAULT 'P',
  UNIQUE KEY `tax_code` (`tax_code`,`state`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER tax_state_u AFTER UPDATE ON tax_state
FOR EACH ROW
BEGIN
	CALL ReloadTFAndIntTax('T000');
	CALL ReloadTFAndIntTax('T001');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER tax_state_d AFTER DELETE ON tax_state
FOR EACH ROW
BEGIN
	CALL ReloadTFAndIntTax('T000');
	CALL ReloadTFAndIntTax('T001');
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `tax_zip`
--

DROP TABLE IF EXISTS `tax_zip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_zip` (
  `zip` char(5) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `tax_code` char(10) NOT NULL DEFAULT '',
  `inv_head_id` char(2) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `city_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `state_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `county_value` decimal(6,4) NOT NULL DEFAULT '0.0000',
  `cal_type` char(1) NOT NULL DEFAULT 'P'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tf_int_tax`
--

DROP TABLE IF EXISTS `tf_int_tax`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tf_int_tax` (
  `state` char(2) NOT NULL DEFAULT '',
  `tf_tax_rate` decimal(7,6) NOT NULL DEFAULT '0.000000',
  `int_tax_rate` decimal(7,6) NOT NULL DEFAULT '0.000000',
  PRIMARY KEY (`state`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `userid` char(6) NOT NULL DEFAULT '',
  `department_id` char(6) NOT NULL DEFAULT '',
  `fname` char(25) NOT NULL DEFAULT '',
  `lname` char(12) NOT NULL DEFAULT '',
  `cname` char(15) NOT NULL DEFAULT '',
  `pin` char(13) NOT NULL DEFAULT '',
  `pass` char(8) NOT NULL DEFAULT '',
  `app_access_token` char(8) NOT NULL DEFAULT '',
  `ws_auth_token` char(8) NOT NULL DEFAULT '',
  `extn` char(5) NOT NULL DEFAULT '',
  `extn_line_number` char(1) NOT NULL DEFAULT '1',
  `extn_outgoing_cli` char(11) NOT NULL DEFAULT '',
  `find_me_userid` char(6) NOT NULL DEFAULT '',
  `fwd_rule` char(1) NOT NULL DEFAULT 'U' COMMENT 'U=Unconditional; D=ServiceDown; T=RingTimeout',
  `fwd_number` char(16) NOT NULL DEFAULT '',
  `prefered_device` char(1) NOT NULL DEFAULT '' COMMENT 'A=App, X=Device, B=Both',
  `ring_timeout` decimal(2,0) NOT NULL DEFAULT '30' COMMENT 'in-sec',
  `allow_idd_call` char(1) NOT NULL DEFAULT 'Y',
  `allow_local_call` char(1) NOT NULL DEFAULT 'Y',
  `allow_efax` char(1) NOT NULL DEFAULT 'N',
  `voice_log` char(1) NOT NULL DEFAULT 'N',
  `zone_id` char(6) NOT NULL DEFAULT '',
  `voice_mail` char(1) NOT NULL DEFAULT '' COMMENT 'A=active',
  `voice_mail_pin` char(6) NOT NULL DEFAULT '',
  `park_group_id` char(4) NOT NULL DEFAULT '',
  `blf_alert_beep` char(1) NOT NULL DEFAULT '',
  `status` char(1) NOT NULL DEFAULT '',
  `active` char(1) NOT NULL DEFAULT 'Y',
  `directory_listing` char(1) NOT NULL DEFAULT 'Y',
  `block_callerid` char(1) NOT NULL DEFAULT 'N',
  `block_anonymous_call` char(1) NOT NULL DEFAULT '',
  `dnd_enable` char(1) NOT NULL DEFAULT '',
  `allow_pci_pp` char(1) NOT NULL DEFAULT '' COMMENT 'Y=Allow PCI Payment Process',
  `pci_pp_manual_input` char(1) NOT NULL DEFAULT '',
  `primary_service` char(1) NOT NULL DEFAULT 'V' COMMENT 'V=Voice; F=Fax',
  `send_push` char(1) NOT NULL DEFAULT '' COMMENT 'Y=SendPush; N=DoNotSend; blank=NotRegistered',
  `notify` char(1) NOT NULL DEFAULT '' COMMENT 'S=ReSync; B=ReBoot',
  PRIMARY KEY (`userid`),
  UNIQUE KEY `account_id` (`account_id`,`extn`),
  KEY `zone_id` (`zone_id`),
  KEY `department_id` (`department_id`),
  KEY `find_me_userid` (`find_me_userid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER user_upd AFTER UPDATE ON user
FOR EACH ROW
BEGIN

  DECLARE cnt_v, send_msg_v int;
  DECLARE DB_ServerIP_v char(15) DEFAULT '';
  DECLARE DB_ServerPort_v char(5) DEFAULT '';
  DECLARE msg_v char(64) DEFAULT '';
       
  IF old.find_me_userid != new.find_me_userid OR old.fwd_rule != new.fwd_rule OR old.fwd_number != new.fwd_number OR old.active != new.active OR
   old.app_access_token !=new.app_access_token THEN
     SET send_msg_v = 1;

  ELSE
     SELECT COUNT(*) INTO cnt_v FROM location WHERE userid=old.userid;
     IF cnt_v > 0 THEN
     IF old.prefered_device != new.prefered_device OR old.dnd_enable != new.dnd_enable OR new.voice_log != old.voice_log OR
 old.voice_mail != new.voice_mail OR old.voice_mail_pin != new.voice_mail_pin OR old.department_id != new.department_id OR
 old.cname != new.cname OR old.extn_outgoing_cli != new.extn_outgoing_cli OR old.allow_idd_call != new.allow_idd_call OR old.send_push != new.send_push OR
 old.allow_local_call != new.allow_local_call OR old.zone_id != new.zone_id OR old.block_callerid != new.block_callerid OR
 old.pass != new.pass OR old.ring_timeout != new.ring_timeout THEN

        SET send_msg_v = 1;   

     END IF;
     END IF;
  END IF;
  
  IF send_msg_v = 1 THEN
       SET msg_v = CONCAT('DB_TRIGGER\r\ntable: USER\r\n', 'userid: ', new.userid, '\r\n');
  
  
       
  
    
  ELSEIF old.extn != new.extn THEN
       
       SET msg_v = CONCAT('DB_TRIGGER\r\ntable: EXTN_CHANGE\r\n', 'userid: ', new.userid, '\r\n');
    
  END IF;
    
  IF msg_v != '' THEN
      SELECT db_ip,db_port INTO DB_ServerIP_v,DB_ServerPort_v FROM settings;
      IF DB_ServerPort_v != '' THEN
          SELECT updatedb(DB_ServerIP_v, DB_ServerPort_v, msg_v) INTO msg_v;
      END IF;
  END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `user_permission`
--

DROP TABLE IF EXISTS `user_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permission` (
  `account_id` char(6) NOT NULL,
  `user_pin` char(14) NOT NULL,
  `type` char(1) NOT NULL DEFAULT 'P' COMMENT 'P=Page,  E= Extension',
  `extn` char(5) NOT NULL DEFAULT '',
  `page_id` char(2) NOT NULL,
  `permission` char(1) NOT NULL DEFAULT 'A' COMMENT 'A= Allow',
  `add_date` datetime NOT NULL,
  `update_date` datetime NOT NULL,
  `added_by` char(20) NOT NULL COMMENT 'this can be root users or admin id'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_profile`
--

DROP TABLE IF EXISTS `user_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_profile` (
  `userid` char(6) NOT NULL DEFAULT '',
  `account_id` char(6) NOT NULL DEFAULT '',
  `device_port_id` char(1) NOT NULL DEFAULT '1' COMMENT 'Port or unit for multi user device',
  `device_maker` char(3) NOT NULL DEFAULT '',
  `device_model` char(20) NOT NULL DEFAULT '',
  `device_mac` char(12) NOT NULL DEFAULT '',
  `device_fw` char(10) NOT NULL DEFAULT '',
  `device_last_sync_time` int(4) NOT NULL DEFAULT '0',
  `device_reg_status` char(1) NOT NULL DEFAULT '' COMMENT 'R=Registered; blank=NotRegistered',
  `app_reg_status` char(1) NOT NULL DEFAULT '' COMMENT 'R=Registered; P=Push; blank=NotRegistered',
  `mobile_os` char(1) NOT NULL DEFAULT '',
  `sdate` date NOT NULL DEFAULT '0000-00-00',
  `password` char(32) NOT NULL DEFAULT '',
  `pass_status` char(1) NOT NULL DEFAULT '' COMMENT 'F-Force to change password',
  `web_access` char(1) NOT NULL DEFAULT 'N',
  `email` char(35) NOT NULL DEFAULT '',
  `email_notification` char(1) NOT NULL DEFAULT 'Y',
  `cell_phone` char(13) NOT NULL DEFAULT '',
  `e911_location_id` char(4) NOT NULL DEFAULT '',
  `timezone` char(30) NOT NULL DEFAULT '',
  `is_dst` char(1) NOT NULL DEFAULT '',
  `gmt_offset` char(6) NOT NULL DEFAULT '',
  `country_code` char(2) NOT NULL DEFAULT '',
  `city` char(20) NOT NULL DEFAULT '',
  `state` char(2) NOT NULL DEFAULT '',
  `device_ip` char(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`userid`),
  KEY `device_mac` (`device_mac`),
  KEY `account_id` (`account_id`),
  KEY `device_ip` (`device_ip`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `verified_invoice_account`
--

DROP TABLE IF EXISTS `verified_invoice_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `verified_invoice_account` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `inv_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`account_id`,`inv_date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vm_log`
--

DROP TABLE IF EXISTS `vm_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vm_log` (
  `userid` char(6) NOT NULL DEFAULT '',
  `did` char(13) NOT NULL DEFAULT '',
  `callername` char(20) NOT NULL DEFAULT '',
  `callerid` char(15) NOT NULL DEFAULT '',
  `duration` decimal(3,0) unsigned NOT NULL DEFAULT '0',
  `status` char(1) NOT NULL DEFAULT '',
  `log_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tstamp` int(4) NOT NULL DEFAULT '0',
  `utc` int(4) NOT NULL DEFAULT '0',
  KEY `utc` (`utc`),
  KEY `userid` (`userid`,`status`,`utc`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ws_token`
--

DROP TABLE IF EXISTS `ws_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ws_token` (
  `token` char(32) NOT NULL DEFAULT '',
  `generate_time` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ip` char(15) NOT NULL DEFAULT '',
  KEY `token` (`token`),
  KEY `generate_time` (`generate_time`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zone`
--

DROP TABLE IF EXISTS `zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zone` (
  `account_id` char(6) NOT NULL DEFAULT '',
  `zone_id` char(6) NOT NULL DEFAULT '',
  `name` char(25) NOT NULL DEFAULT '',
  `prefered_codec` char(2) NOT NULL DEFAULT '0' COMMENT '0 = 711-u, 8=711-a 18 = 719',
  PRIMARY KEY (`zone_id`),
  KEY `account_id` (`account_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-03-06  6:42:15
