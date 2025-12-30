/*
 Navicat Premium Data Transfer

 Source Server         : mysql-local
 Source Server Type    : MySQL
 Source Server Version : 50718 (5.7.18)
 Source Host           : localhost:3306
 Source Schema         : luastar-admin

 Target Server Type    : MySQL
 Target Server Version : 50718 (5.7.18)
 File Encoding         : 65001

 Date: 30/12/2025 19:50:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for ls_config
-- ----------------------------
DROP TABLE IF EXISTS `ls_config`;
CREATE TABLE `ls_config` (
  `id` varchar(32) NOT NULL COMMENT '配置id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(100) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `vtype` varchar(100) NOT NULL COMMENT '值类型',
  `vcontent` text NOT NULL COMMENT '值内容',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint(20) NOT NULL COMMENT '排序',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配置';

-- ----------------------------
-- Records of ls_config
-- ----------------------------
BEGIN;
INSERT INTO `ls_config` (`id`, `level`, `type`, `code`, `name`, `vtype`, `vcontent`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682589db115c4960eb163230', 'system', 'route', 'route.type', '路由类型', 'array', '[\n  {\n    \"label\": \"LuastarAdmin\",\n    \"value\": \"luastar-admin\"\n  },\n  {\n    \"label\": \"demo\",\n    \"value\": \"demo\"\n  }\n]', 'enable', 1, 'admin', '2025-05-15 14:31:38', 'admin', '2025-05-21 20:54:31');
INSERT INTO `ls_config` (`id`, `level`, `type`, `code`, `name`, `vtype`, `vcontent`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682589db115c4960eb163231', 'system', 'module', 'module.type', '代码类型', 'array', '[\n  {\n    \"label\": \"控制器\",\n    \"value\": \"controller\"\n  },\n  {\n    \"label\": \"拦截器\",\n    \"value\": \"interceptor\"\n  },\n  {\n    \"label\": \"服务\",\n    \"value\": \"service\"\n  },\n  {\n    \"label\": \"其他\",\n    \"value\": \"other\"\n  }\n]', 'enable', 2, 'admin', '2025-05-19 19:07:28', 'admin', '2025-05-19 19:09:23');
INSERT INTO `ls_config` (`id`, `level`, `type`, `code`, `name`, `vtype`, `vcontent`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682dcbc7c453ec8c45000001', 'user', 'project', 'project.demo', '示例系统1', 'object', '{\n  \"mode\": \"rr\",\n  \"servers\": [\n    {\n      \"host\": \"127.0.0.1\",\n      \"port\": \"9001\",\n      \"weight\": 2\n    },\n    {\n      \"host\": \"127.0.0.1\",\n      \"port\": \"9002\",\n      \"weight\": 1\n    }\n  ]\n}', 'enable', 3, 'admin', '2025-05-21 20:49:11', 'admin', '2025-05-21 20:49:11');
INSERT INTO `ls_config` (`id`, `level`, `type`, `code`, `name`, `vtype`, `vcontent`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('694e5491baa147bd2c000001', 'user', 'project', 'project.dify', 'dify', 'object', '{\n  \"mode\": \"rr\",\n  \"servers\": [\n    {\n      \"host\": \"127.0.0.1\",\n      \"port\": \"9003\",\n      \"weight\": 10\n    }\n  ]\n}', 'enable', 4, 'admin', '2025-12-26 17:25:37', 'admin', '2025-12-26 17:59:16');
COMMIT;

-- ----------------------------
-- Table structure for ls_interceptor
-- ----------------------------
DROP TABLE IF EXISTS `ls_interceptor`;
CREATE TABLE `ls_interceptor` (
  `id` varchar(32) NOT NULL COMMENT '拦截器id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `routes` text NOT NULL COMMENT '拦截路由',
  `routes_exclude` text COMMENT '排除路由',
  `mcode` varchar(32) NOT NULL COMMENT '模块编码',
  `mfunc_before` varchar(255) NOT NULL COMMENT '模块前置函数',
  `mfunc_after` varchar(255) NOT NULL COMMENT '模块后置函数',
  `params` text COMMENT '参数',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint(20) NOT NULL COMMENT '排序',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拦截器';

-- ----------------------------
-- Records of ls_interceptor
-- ----------------------------
BEGIN;
INSERT INTO `ls_interceptor` (`id`, `level`, `code`, `name`, `routes`, `routes_exclude`, `mcode`, `mfunc_before`, `mfunc_after`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('68020dc7d03ee13ec0330702', 'system', 'auth-check', '授权检查', '[{\"path\":\"^/api/admin/.*\",\"method\":\"*\",\"mode\":\"v\"}]', '[{\n\"path\":\"/api/admin/auth/login\",\n\"method\":\"*\",\n\"mod\":\"p\"\n},{\n\"path\":\"/api/admin/auth/refresh-token\",\n\"method\":\"*\",\n\"mod\":\"p\"\n}]', 'interceptor.auth', 'handle_before', 'handle_after', '', 'enable', 1, 'admin', '2025-04-18 17:00:20', 'admin', '2025-12-30 19:35:53');
COMMIT;

-- ----------------------------
-- Table structure for ls_module
-- ----------------------------
DROP TABLE IF EXISTS `ls_module`;
CREATE TABLE `ls_module` (
  `id` varchar(32) NOT NULL COMMENT '模块id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `desc` text COMMENT '描述',
  `content` text COMMENT '内容',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint(20) NOT NULL COMMENT '排序',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='模块';

-- ----------------------------
-- Records of ls_module
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for ls_route
-- ----------------------------
DROP TABLE IF EXISTS `ls_route`;
CREATE TABLE `ls_route` (
  `id` varchar(32) NOT NULL COMMENT '路由id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `path` varchar(255) NOT NULL COMMENT '路径',
  `method` varchar(100) NOT NULL COMMENT '请求方法',
  `mode` varchar(20) NOT NULL COMMENT '匹配模式',
  `mcode` varchar(255) NOT NULL COMMENT '模块编码',
  `mfunc` varchar(255) NOT NULL COMMENT '模块函数',
  `params` text COMMENT '参数',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint(20) NOT NULL COMMENT '排序',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='路由';

-- ----------------------------
-- Records of ls_route
-- ----------------------------
BEGIN;
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d0', 'system', 'luastar-admin', 'health.check', '健康检查', '/active', '*', 'p', 'controller.health', 'active', NULL, 'enable', 1, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d1', 'system', 'luastar-admin', 'auth.login', '登录', '/api/admin/auth/login', '*', 'p', 'controller.auth', 'login', NULL, 'enable', 2, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d2', 'system', 'luastar-admin', 'auth.refresh-token', '刷新token', '/api/admin/auth/refresh-token', '*', 'p', 'controller.auth', 'refresh_token', NULL, 'enable', 3, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d3', 'system', 'luastar-admin', 'auth.routes', '获取动态路由', '/api/admin/auth/routes', '*', 'p', 'controller.auth', 'get_routes', NULL, 'enable', 4, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d4', 'system', 'luastar-admin', 'auth.logout', '退出登录', '/api/admin/auth/logout', '*', 'p', 'controller.auth', 'logout', NULL, 'enable', 5, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d5', 'system', 'luastar-admin', 'user.me', '获取我的信息', '/api/admin/user/me', '*', 'p', 'controller.user', 'get_my_info', NULL, 'enable', 6, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d6', 'system', 'luastar-admin', 'user.get-profile', '查询个人中心信息', '/api/admin/user/profile', 'GET', 'p', 'controller.user', 'get_user_profile', NULL, 'enable', 7, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d7', 'system', 'luastar-admin', 'user.update-profile', '修改个人中心信息', '/api/admin/user/profile', 'PUT', 'p', 'controller.user', 'update_user_profile', NULL, 'enable', 8, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d8', 'system', 'luastar-admin', 'user.change-password', '修改密码', '/api/admin/user/change-password', '*', 'p', 'controller.user', 'change_password', NULL, 'enable', 9, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279d9', 'system', 'luastar-admin', 'user.get-user-list', '获取用户列表', '/api/admin/user/page', '*', 'p', 'controller.user', 'get_user_list', NULL, 'enable', 10, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279da', 'system', 'luastar-admin', 'user.get-user-info', '获取用户信息', '/api/admin/user/form', '*', 'p', 'controller.user', 'get_user_info', NULL, 'enable', 11, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279db', 'system', 'luastar-admin', 'user.get-max-rank', '获取用户最大排序值', '/api/admin/user/get-max-rank', '*', 'p', 'controller.user', 'get_max_rank', NULL, 'enable', 12, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279dc', 'system', 'luastar-admin', 'user.create-user', '创建用户', '/api/admin/user/create', '*', 'p', 'controller.user', 'create_user', NULL, 'enable', 13, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279dd', 'system', 'luastar-admin', 'user.update-user', '修改用户', '/api/admin/user/update', '*', 'p', 'controller.user', 'update_user', NULL, 'enable', 14, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279de', 'system', 'luastar-admin', 'user.reset-password', '重置密码', '/api/admin/user/reset-password', '*', 'p', 'controller.user', 'reset_password', NULL, 'enable', 15, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279df', 'system', 'luastar-admin', 'user.delete-user', '删除用户', '/api/admin/user/delete', '*', 'p', 'controller.user', 'delete_user', NULL, 'enable', 16, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e0', 'system', 'luastar-admin', 'config.get-config-list', '获取配置列表', '/api/admin/config/page', '*', 'p', 'controller.config', 'get_config_list', NULL, 'enable', 17, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e1', 'system', 'luastar-admin', 'config.get-config-info', '获取配置信息', '/api/admin/config/form', '*', 'p', 'controller.config', 'get_config_info', NULL, 'enable', 18, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e2', 'system', 'luastar-admin', 'config.get-max-rank', '获取配置最大排序值', '/api/admin/config/get-max-rank', '*', 'p', 'controller.config', 'get_max_rank', NULL, 'enable', 19, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e3', 'system', 'luastar-admin', 'config.create-config', '创建配置', '/api/admin/config/create', '*', 'p', 'controller.config', 'create_config', NULL, 'enable', 20, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e4', 'system', 'luastar-admin', 'config.update-config', '修改配置', '/api/admin/config/update', '*', 'p', 'controller.config', 'update_config', NULL, 'enable', 21, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e5', 'system', 'luastar-admin', 'config.delete-config', '删除配置', '/api/admin/config/delete', '*', 'p', 'controller.config', 'delete_config', NULL, 'enable', 22, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e6', 'system', 'luastar-admin', 'config.content', '获取配置内容', '/api/admin/config/content', '*', 'p', 'controller.config', 'get_config_content', NULL, 'enable', 23, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e7', 'system', 'luastar-admin', 'route.get-route-list', '获取路由列表', '/api/admin/route/page', '*', 'p', 'controller.route', 'get_route_list', NULL, 'enable', 24, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e8', 'system', 'luastar-admin', 'route.get-route-info', '获取路由信息', '/api/admin/route/form', '*', 'p', 'controller.route', 'get_route_info', NULL, 'enable', 25, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279e9', 'system', 'luastar-admin', 'route.get-max-rank', '获取路由最大排序值', '/api/admin/route/get-max-rank', '*', 'p', 'controller.route', 'get_max_rank', NULL, 'enable', 26, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279ea', 'system', 'luastar-admin', 'route.create-route', '创建路由', '/api/admin/route/create', '*', 'p', 'controller.route', 'create_route', NULL, 'enable', 27, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279eb', 'system', 'luastar-admin', 'route.update-route', '修改路由', '/api/admin/route/update', '*', 'p', 'controller.route', 'update_route', NULL, 'enable', 28, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279ec', 'system', 'luastar-admin', 'route.delete-route', '删除路由', '/api/admin/route/delete', '*', 'p', 'controller.route', 'delete_route', NULL, 'enable', 29, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279ed', 'system', 'luastar-admin', 'interceptor.get-interceptor-list', '获取拦截器列表', '/api/admin/interceptor/page', '*', 'p', 'controller.interceptor', 'get_interceptor_list', NULL, 'enable', 30, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279ee', 'system', 'luastar-admin', 'interceptor.get-interceptor-info', '获取拦截器信息', '/api/admin/interceptor/form', '*', 'p', 'controller.interceptor', 'get_interceptor_info', NULL, 'enable', 31, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279ef', 'system', 'luastar-admin', 'interceptor.get-max-rank', '获取拦截器最大排序值', '/api/admin/interceptor/get-max-rank', '*', 'p', 'controller.interceptor', 'get_max_rank', NULL, 'enable', 32, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f0', 'system', 'luastar-admin', 'interceptor.create-interceptor', '创建拦截器', '/api/admin/interceptor/create', '*', 'p', 'controller.interceptor', 'create_interceptor', NULL, 'enable', 33, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f1', 'system', 'luastar-admin', 'interceptor.update-interceptor', '修改拦截器', '/api/admin/interceptor/update', '*', 'p', 'controller.interceptor', 'update_interceptor', NULL, 'enable', 34, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f2', 'system', 'luastar-admin', 'interceptor.delete-interceptor', '删除拦截器', '/api/admin/interceptor/delete', '*', 'p', 'controller.interceptor', 'delete_interceptor', NULL, 'enable', 35, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f3', 'system', 'luastar-admin', 'module.get-module-list', '获取代码列表', '/api/admin/module/page', '*', 'p', 'controller.module', 'get_module_list', NULL, 'enable', 36, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f4', 'system', 'luastar-admin', 'module.get-module-info', '获取代码信息', '/api/admin/module/form', '*', 'p', 'controller.module', 'get_module_info', NULL, 'enable', 37, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f5', 'system', 'luastar-admin', 'module.get-max-rank', '获取代码最大排序值', '/api/admin/module/get-max-rank', '*', 'p', 'controller.module', 'get_max_rank', NULL, 'enable', 38, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f6', 'system', 'luastar-admin', 'module.create-module', '创建代码', '/api/admin/module/create', '*', 'p', 'controller.module', 'create_module', NULL, 'enable', 39, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f7', 'system', 'luastar-admin', 'module.update-module', '修改代码', '/api/admin/module/update', '*', 'p', 'controller.module', 'update_module', NULL, 'enable', 40, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f8', 'system', 'luastar-admin', 'module.delete-module', '删除代码', '/api/admin/module/delete', '*', 'p', 'controller.module', 'delete_module', NULL, 'enable', 41, 'admin', '2025-05-19 17:21:42', 'admin', '2025-05-19 17:21:42');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279f9', 'system', 'luastar-admin', 'module.get-hint-module-list', '获取提示代码列表', '/api/admin/module/get-hint-module-list', '*', 'p', 'controller.module', 'get_hint_module_list', NULL, 'enable', 42, 'admin', '2025-05-20 16:29:04', 'admin', '2025-05-20 16:29:04');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279fa', 'system', 'luastar-admin', 'module.get-hint-func-list', '获取提示代码函数列表', '/api/admin/module/get-hint-func-list', '*', 'p', 'controller.module', 'get_hint_func_list', NULL, 'enable', 43, 'admin', '2025-05-20 16:29:04', 'admin', '2025-05-20 16:29:04');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d7fea4304b277f40279fb', 'system', 'luastar-admin', 'stats.get-data', '获取统计数据', '/api/admin/stats/data', '*', 'p', 'controller.stats', 'get_data', NULL, 'enable', 44, 'admin', '2025-06-17 19:31:12', 'admin', '2025-06-17 19:31:20');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682dcdbec453ec8a45000001', 'user', 'demo', 'demo.fake', 'demo项目路由', '/api/fake', '*', 'p', 'controller.proxy', 'proxy', '{\n\"project\":\"project.demo\",\n\"mode\": \"http\",\n\"sub_prefix\":\"/api\",\n\"add_prefix\": null\n}', 'enable', 45, 'admin', '2025-05-21 20:57:34', 'admin', '2025-05-22 12:10:26');
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('694e53c9baa147bd2c000001', 'user', 'demo', 'demo.sse', 'AI代理', '/api/v1/chat-messages', '*', 'p', 'controller.proxy', 'proxy', '{\n\"project\":\"project.dify\",\n\"mode\": \"http_sse\",\n\"sub_prefix\":\"/api\",\n\"add_prefix\": null\n}', 'enable', 46, 'admin', '2025-12-26 17:22:17', 'admin', '2025-12-26 17:26:18');
COMMIT;

-- ----------------------------
-- Table structure for ls_stats
-- ----------------------------
DROP TABLE IF EXISTS `ls_stats`;
CREATE TABLE `ls_stats` (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `timestamp` bigint(20) NOT NULL COMMENT '时间戳',
  `timestamp_str` varchar(255) NOT NULL COMMENT '时间戳字符串',
  `value01` bigint(20) DEFAULT NULL COMMENT '值1',
  `value02` bigint(20) DEFAULT NULL COMMENT '值2',
  `value03` bigint(20) DEFAULT NULL COMMENT '值3',
  `value04` bigint(20) DEFAULT NULL COMMENT '值4',
  `value05` bigint(20) DEFAULT NULL COMMENT '值5',
  `value06` bigint(20) DEFAULT NULL COMMENT '值6',
  `value07` bigint(20) DEFAULT NULL COMMENT '值7',
  `value08` bigint(20) DEFAULT NULL COMMENT '值8',
  `value09` bigint(20) DEFAULT NULL COMMENT '值9',
  `value10` bigint(20) DEFAULT NULL COMMENT '值10',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_timestamp` (`type`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='统计';

-- ----------------------------
-- Records of ls_stats
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for ls_user
-- ----------------------------
DROP TABLE IF EXISTS `ls_user`;
CREATE TABLE `ls_user` (
  `id` varchar(32) NOT NULL COMMENT '用户id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `username` varchar(100) NOT NULL COMMENT '用户登录名',
  `nickname` varchar(255) DEFAULT NULL COMMENT '用户别名',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `passwd` varchar(100) NOT NULL COMMENT '密码',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `roles` varchar(255) NOT NULL COMMENT '角色',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint(20) NOT NULL COMMENT '排序',
  `create_by` varchar(32) DEFAULT NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) DEFAULT NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  UNIQUE KEY `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户';

-- ----------------------------
-- Records of ls_user
-- ----------------------------
BEGIN;
INSERT INTO `ls_user` (`id`, `level`, `username`, `nickname`, `email`, `passwd`, `avatar`, `roles`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d822359fa5227368b6a01', 'system', 'admin', '管理员', '19102630@163.com', 'ac0e7d037817094e9e0b4441f9bae3209d67b02fa484917065f71b16109a1a78', 'https://avatars.githubusercontent.com/u/44761321', 'admin', 'enable', 1, 'admin', '2025-04-18 16:31:31', 'admin', '2025-04-18 16:31:38');
INSERT INTO `ls_user` (`id`, `level`, `username`, `nickname`, `email`, `passwd`, `avatar`, `roles`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682d822359fa5227368b6a02', 'user', 'common', '普通用户', '5917332@qq.com', 'bce7176ba73b5342f0e65eb5a00f6f5623571df696d797846f081a3251c39a48', NULL, 'common', 'enable', 2, 'admin', '2025-05-21 14:28:20', 'admin', '2025-05-21 14:38:22');
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
