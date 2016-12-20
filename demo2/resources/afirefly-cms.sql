/*
 Navicat Premium Data Transfer

 Source Server         : local
 Source Server Type    : MySQL
 Source Server Version : 50626
 Source Host           : localhost
 Source Database       : afirefly-cms

 Target Server Type    : MySQL
 Target Server Version : 50626
 File Encoding         : utf-8

 Date: 12/14/2016 16:39:16 PM
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `SYS_FUNCTION`
-- ----------------------------
DROP TABLE IF EXISTS `SYS_FUNCTION`;
CREATE TABLE `SYS_FUNCTION` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `FUNC_NAME` varchar(255) NOT NULL,
  `PARENT_FUNC_ID` int(10) DEFAULT NULL,
  `IS_LEAF` int(4) DEFAULT '1',
  `ACTION_URL` varchar(255) DEFAULT NULL,
  `ICON_URL` varchar(255) DEFAULT NULL,
  `FUNC_ORDER` int(10) DEFAULT NULL,
  `IS_EFFECTIVE` tinyint(2) DEFAULT '1',
  `CREATED_TIME` datetime DEFAULT NULL,
  `UPDATED_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_parent_func_id` (`PARENT_FUNC_ID`) COMMENT '(null)'
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Records of `SYS_FUNCTION`
-- ----------------------------
BEGIN;
INSERT INTO `SYS_FUNCTION` VALUES ('1', '系统管理', '0', '0', null, null, '1', '1', '2016-09-28 14:09:20', '2016-09-28 14:09:23'), ('2', '用户管理', '1', '1', '/system/user', null, '1', '1', '2016-09-28 14:10:14', '2016-09-28 14:10:30'), ('3', '角色管理', '1', '1', '/system/role', null, '2', '1', '2016-09-28 14:10:42', '2016-09-28 14:10:45'), ('4', '功能管理', '1', '1', '/system/func', null, '3', '1', '2016-09-28 14:11:02', '2016-09-28 14:11:05'), ('5', '配置管理', '0', '0', null, null, '2', '1', '2016-09-28 14:11:35', '2016-09-28 14:11:40'), ('6', '字典管理', '5', '1', '/pub/dict', null, '1', '1', '2016-09-28 14:12:01', '2016-09-28 14:12:04'), ('7', '配置管理（单）', '5', '1', '/pub/conf/single', null, '2', '1', '2016-09-28 14:12:43', '2016-09-28 14:12:47'), ('8', '配置管理（多）', '5', '1', '/pub/conf/mult', null, '3', '1', '2016-09-28 14:13:08', '2016-09-28 14:13:11'), ('9', '升级管理', '0', '0', null, null, '3', '1', '2016-09-28 14:13:36', '2016-09-28 14:13:39'), ('10', '应用管理', '16', '1', '/up/app', null, '1', '1', '2016-09-28 14:14:26', '2016-12-09 18:05:20'), ('11', '应用系统管理', '16', '1', '/up/os', null, '2', '1', '2016-09-28 14:15:02', '2016-12-09 18:05:20'), ('12', '应用渠道管理', '16', '1', '/up/chn', null, '3', '1', '2016-09-28 14:15:25', '2016-12-09 18:05:20'), ('13', '机型管理', '16', '1', '/up/mod', null, '4', '1', '2016-09-28 14:15:51', '2016-12-09 18:05:20'), ('14', '应用包管理', '9', '1', '/up/pkg', null, '2', '1', '2016-09-28 14:16:15', '2016-12-09 18:06:01'), ('15', '应用版本管理', '9', '1', '/up/ver', null, '3', '1', '2016-09-28 14:16:40', '2016-12-09 18:06:01'), ('16', '应用配置', '9', '0', '', '', '1', '1', '2016-12-09 18:04:49', '2016-12-09 18:06:01');
COMMIT;

-- ----------------------------
--  Table structure for `SYS_ROLE`
-- ----------------------------
DROP TABLE IF EXISTS `SYS_ROLE`;
CREATE TABLE `SYS_ROLE` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `ROLE_NAME` varchar(255) NOT NULL,
  `CREATED_TIME` datetime DEFAULT NULL,
  `UPDATED_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Records of `SYS_ROLE`
-- ----------------------------
BEGIN;
INSERT INTO `SYS_ROLE` VALUES ('1', '超级管理员', '2016-09-28 14:07:44', '2016-09-28 14:07:47'), ('2', '运营', '2016-09-28 14:29:25', '2016-09-28 14:29:25');
COMMIT;

-- ----------------------------
--  Table structure for `SYS_ROLE_FUNCTION_RELATION`
-- ----------------------------
DROP TABLE IF EXISTS `SYS_ROLE_FUNCTION_RELATION`;
CREATE TABLE `SYS_ROLE_FUNCTION_RELATION` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `ROLE_ID` int(10) NOT NULL,
  `FUNC_ID` int(10) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `idx_roleid_funcid` (`ROLE_ID`,`FUNC_ID`) COMMENT '(null)'
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Records of `SYS_ROLE_FUNCTION_RELATION`
-- ----------------------------
BEGIN;
INSERT INTO `SYS_ROLE_FUNCTION_RELATION` VALUES ('61', '1', '1'), ('50', '1', '2'), ('51', '1', '3'), ('52', '1', '4'), ('62', '1', '5'), ('53', '1', '6'), ('54', '1', '7'), ('55', '1', '8'), ('65', '1', '9'), ('63', '1', '10'), ('56', '1', '11'), ('57', '1', '12'), ('58', '1', '13'), ('59', '1', '14'), ('60', '1', '15'), ('64', '1', '16'), ('18', '2', '9'), ('17', '2', '14'), ('16', '2', '15');
COMMIT;

-- ----------------------------
--  Table structure for `SYS_USER`
-- ----------------------------
DROP TABLE IF EXISTS `SYS_USER`;
CREATE TABLE `SYS_USER` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `LOGIN_NAME` varchar(255) NOT NULL,
  `PAZZWORD` varchar(32) NOT NULL,
  `USER_NAME` varchar(255) NOT NULL,
  `IS_EFFECTIVE` tinyint(1) DEFAULT NULL,
  `CREATED_TIME` datetime DEFAULT NULL,
  `UPDATED_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Records of `SYS_USER`
-- ----------------------------
BEGIN;
INSERT INTO `SYS_USER` VALUES ('1', 'admin', '21232f297a57a5a743894a0e4a801fc3', '超级管理员', '1', '2016-09-28 14:07:04', '2016-09-28 14:07:07');
COMMIT;

-- ----------------------------
--  Table structure for `SYS_USER_ROLE_RELATION`
-- ----------------------------
DROP TABLE IF EXISTS `SYS_USER_ROLE_RELATION`;
CREATE TABLE `SYS_USER_ROLE_RELATION` (
  `ID` int(10) NOT NULL AUTO_INCREMENT,
  `USER_ID` int(10) NOT NULL,
  `ROLE_ID` int(10) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `idx_userid_roleid` (`USER_ID`,`ROLE_ID`) COMMENT '(null)'
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

-- ----------------------------
--  Records of `SYS_USER_ROLE_RELATION`
-- ----------------------------
BEGIN;
INSERT INTO `SYS_USER_ROLE_RELATION` VALUES ('1', '1', '1');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
