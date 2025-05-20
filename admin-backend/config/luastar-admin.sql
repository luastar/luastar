DROP TABLE IF EXISTS `ls_user`;
CREATE TABLE `ls_user`  (
  `id` varchar(32) NOT NULL COMMENT '用户id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `username` varchar(100) NOT NULL COMMENT '用户登录名',
  `nickname` varchar(255) NULL COMMENT '用户别名',
  `email` varchar(100) NULL COMMENT '邮箱',
  `passwd` varchar(100) NOT NULL COMMENT '密码',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_username`(`username`),
  UNIQUE INDEX `idx_email`(`email`)
) COMMENT = '用户';

DROP TABLE IF EXISTS `ls_role`;
CREATE TABLE `ls_role`  (
  `id` varchar(32) NOT NULL COMMENT '角色id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `code` varchar(100) NOT NULL COMMENT '角色编码',
  `name` varchar(255) NULL COMMENT '角色名称',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`)
) COMMENT = '角色';

DROP TABLE IF EXISTS `ls_user_role`;
CREATE TABLE `ls_user_role`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `uid` varchar(32) NOT NULL COMMENT '用户id',
  `rid` varchar(32) NOT NULL COMMENT '角色id',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_uid_rid`(`uid`, `rid`),
  INDEX `idx_rid`(`rid`)
) COMMENT = '用户角色';

DROP TABLE IF EXISTS `ls_route`;
CREATE TABLE `ls_route`  (
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
  `params` text NULL COMMENT '参数',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`),
  INDEX `idx_type`(`type`)
) COMMENT = '路由';

INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf0', 'system', 'luastar-admin', 'health.check', '健康检查', '/active', '*', 'p', 'controller.health', 'active', NULL, 'enable', 1, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf1', 'system', 'luastar-admin', 'auth.login', '登录', '/api/admin/auth/login', '*', 'p', 'controller.auth', 'login', NULL, 'enable', 2, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf2', 'system', 'luastar-admin', 'auth.refresh-token', '刷新token', '/api/admin/auth/refresh-token', '*', 'p', 'controller.auth', 'refresh_token', NULL, 'enable', 3, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf3', 'system', 'luastar-admin', 'auth.logout', '退出登录', '/api/admin/auth/logout', '*', 'p', 'controller.auth', 'logout', NULL, 'enable', 4, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf4', 'system', 'luastar-admin', 'user.me', '获取我的信息', '/api/admin/users/me', 'GET', 'p', 'controller.user', 'get_user_info', NULL, 'enable', 5, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf5', 'system', 'luastar-admin', 'user.get-profile', '查询用户信息', '/api/admin/users/profile', 'GET', 'p', 'controller.user', 'get_user_profile', NULL, 'enable', 6, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf6', 'system', 'luastar-admin', 'config.get-config-list', '获取配置列表', '/api/admin/config/page', '*', 'p', 'controller.config', 'get_config_list', NULL, 'enable', 7, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf7', 'system', 'luastar-admin', 'config.get-config-info', '获取配置信息', '/api/admin/config/form', '*', 'p', 'controller.config', 'get_config_info', NULL, 'enable', 8, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf8', 'system', 'luastar-admin', 'config.get-max-rank', '获取配置最大排序值', '/api/admin/config/get-max-rank', '*', 'p', 'controller.config', 'get_max_rank', NULL, 'enable', 9, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cf9', 'system', 'luastar-admin', 'config.create-config', '创建配置', '/api/admin/config/create', '*', 'p', 'controller.config', 'create_config', NULL, 'enable', 10, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cfa', 'system', 'luastar-admin', 'config.update-config', '修改配置', '/api/admin/config/update', '*', 'p', 'controller.config', 'update_config', '', 'enable', 11, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cfb', 'system', 'luastar-admin', 'config.delete-config', '删除配置', '/api/admin/config/delete', '*', 'p', 'controller.config', 'delete_config', NULL, 'enable', 12, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cfc', 'system', 'luastar-admin', 'config.content', '获取配置内容', '/api/admin/config/content', '*', 'p', 'controller.config', 'get_config_content', NULL, 'enable', 13, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cfd', 'system', 'luastar-admin', 'route.get-route-list', '获取路由列表', '/api/admin/route/page', '*', 'p', 'controller.route', 'get_route_list', NULL, 'enable', 14, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cfe', 'system', 'luastar-admin', 'route.get-route-info', '获取路由信息', '/api/admin/route/form', '*', 'p', 'controller.route', 'get_route_info', NULL, 'enable', 15, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7cff', 'system', 'luastar-admin', 'route.get-max-rank', '获取路由最大排序值', '/api/admin/route/get-max-rank', '*', 'p', 'controller.route', 'get_max_rank', NULL, 'enable', 16, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d00', 'system', 'luastar-admin', 'route.create-route', '创建路由', '/api/admin/route/create', '*', 'p', 'controller.route', 'create_route', NULL, 'enable', 17, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d01', 'system', 'luastar-admin', 'route.update-route', '修改路由', '/api/admin/route/update', '*', 'p', 'controller.route', 'update_route', '', 'enable', 18, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d02', 'system', 'luastar-admin', 'route.delete-route', '删除路由', '/api/admin/route/delete', '*', 'p', 'controller.route', 'delete_route', NULL, 'enable', 19, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d03', 'system', 'luastar-admin', 'interceptor.get-interceptor-list', '获取拦截器列表', '/api/admin/interceptor/page', '*', 'p', 'controller.interceptor', 'get_interceptor_list', NULL, 'enable', 20, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d04', 'system', 'luastar-admin', 'interceptor.get-interceptor-info', '获取拦截器信息', '/api/admin/interceptor/form', '*', 'p', 'controller.interceptor', 'get_interceptor_info', NULL, 'enable', 21, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d05', 'system', 'luastar-admin', 'interceptor.get-max-rank', '获取拦截器最大排序值', '/api/admin/interceptor/get-max-rank', '*', 'p', 'controller.interceptor', 'get_max_rank', NULL, 'enable', 22, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d06', 'system', 'luastar-admin', 'interceptor.create-interceptor', '创建拦截器', '/api/admin/interceptor/create', '*', 'p', 'controller.interceptor', 'create_interceptor', NULL, 'enable', 23, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d07', 'system', 'luastar-admin', 'interceptor.update-interceptor', '修改拦截器', '/api/admin/interceptor/update', '*', 'p', 'controller.interceptor', 'update_interceptor', '', 'enable', 24, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d08', 'system', 'luastar-admin', 'interceptor.delete-interceptor', '删除拦截器', '/api/admin/interceptor/delete', '*', 'p', 'controller.interceptor', 'delete_interceptor', NULL, 'enable', 25, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d09', 'system', 'luastar-admin', 'module.get-module-list', '获取代码列表', '/api/admin/module/page', '*', 'p', 'controller.module', 'get_module_list', NULL, 'enable', 26, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0a', 'system', 'luastar-admin', 'module.get-module-info', '获取代码信息', '/api/admin/module/form', '*', 'p', 'controller.module', 'get_module_info', NULL, 'enable', 27, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0b', 'system', 'luastar-admin', 'module.get-max-rank', '获取代码最大排序值', '/api/admin/module/get-max-rank', '*', 'p', 'controller.module', 'get_max_rank', NULL, 'enable', 28, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0c', 'system', 'luastar-admin', 'module.create-module', '创建代码', '/api/admin/module/create', '*', 'p', 'controller.module', 'create_module', NULL, 'enable', 29, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0d', 'system', 'luastar-admin', 'module.update-module', '修改代码', '/api/admin/module/update', '*', 'p', 'controller.module', 'update_module', '', 'enable', 30, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0e', 'system', 'luastar-admin', 'module.delete-module', '删除代码', '/api/admin/module/delete', '*', 'p', 'controller.module', 'delete_module', NULL, 'enable', 31, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d0f', 'system', 'luastar-admin', 'module.get-hint-module-list', '获取提示代码列表', '/api/admin/module/get-hint-module-list', '*', 'p', 'controller.module', 'get_hint_module_list', '', 'enable', 32, 'admin', now(), 'admin', now());
INSERT INTO `ls_route` (`id`, `level`, `type`, `code`, `name`, `path`, `method`, `mode`, `mcode`, `mfunc`, `params`, `state`, `rank`, `create_by`, `create_at`, `update_by`, `update_at`) VALUES ('682af49e2f0e8e4a94fe7d10', 'system', 'luastar-admin', 'module.get-hint-func-list', '获取提示代码函数列表', '/api/admin/module/get-hint-func-list', '*', 'p', 'controller.module', 'get_hint_func_list', NULL, 'enable', 33, 'admin', now(), 'admin', now());

DROP TABLE IF EXISTS `ls_interceptor`;
CREATE TABLE `ls_interceptor`  (
  `id` varchar(32) NOT NULL COMMENT '拦截器id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `routes` text NOT NULL COMMENT '拦截路由',
  `routes_exclude` text NULL COMMENT '排除路由',
  `mcode` varchar(255) NOT NULL COMMENT '模块编码',
  `mfunc_before` varchar(255) NOT NULL COMMENT '模块前置函数',
  `mfunc_after` varchar(255) NOT NULL COMMENT '模块后置函数',
  `params` text NULL COMMENT '参数',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`)
) COMMENT = '拦截器';

DROP TABLE IF EXISTS `ls_module`;
CREATE TABLE `ls_module`  (
  `id` varchar(32) NOT NULL COMMENT '模块id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `desc` text NULL COMMENT '描述',
  `content` text NOT NULL COMMENT '内容',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`),
  INDEX `idx_type`(`type`)
) COMMENT = '模块';

DROP TABLE IF EXISTS `ls_config`;
CREATE TABLE `ls_config`  (
  `id` varchar(32) NOT NULL COMMENT '配置id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(100) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `vtype` varchar(100) NOT NULL COMMENT '值类型',
  `vcontent` text NOT NULL COMMENT '值内容',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`),
  INDEX `idx_type`(`type`)
) COMMENT = '配置';