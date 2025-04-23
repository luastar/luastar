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

DROP TABLE IF EXISTS `ls_permission`;
CREATE TABLE `ls_permission`  (
  `id` varchar(32) NOT NULL COMMENT '权限id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `code` varchar(100) NOT NULL COMMENT '权限编码',
  `name` varchar(255) NULL COMMENT '权限名称',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`)
) COMMENT = '权限';

DROP TABLE IF EXISTS `ls_role_permission`;
CREATE TABLE `ls_role_permission`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `rid` varchar(32) NOT NULL COMMENT '角色id',
  `pid` varchar(32) NOT NULL COMMENT '权限id',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_rid_pid`(`rid`, `pid`),
  INDEX `idx_pid`(`pid`)
) COMMENT = '角色权限';

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