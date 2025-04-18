CREATE TABLE `ls_user`  (
  `id` varchar(32) NOT NULL COMMENT '用户id',
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

CREATE TABLE `ls_role`  (
  `id` varchar(32) NOT NULL COMMENT '角色id',
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

CREATE TABLE `ls_user_role`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
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

CREATE TABLE `ls_permission`  (
  `id` varchar(32) NOT NULL COMMENT '权限id',
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

CREATE TABLE `ls_role_permission`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
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

CREATE TABLE `ls_route`  (
  `id` varchar(32) NOT NULL COMMENT '路由id',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `path` varchar(255) NOT NULL COMMENT '路径',
  `method` varchar(100) NOT NULL COMMENT '请求方法',
  `mode` varchar(20) NOT NULL COMMENT '匹配模式',
  `mid` varchar(32) NOT NULL COMMENT '模块id',
  `p1` text NULL COMMENT '参数1',
  `p2` text NULL COMMENT '参数2',
  `p3` text NULL COMMENT '参数3',
  `p4` text NULL COMMENT '参数4',
  `p5` text NULL COMMENT '参数5',
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

CREATE TABLE `ls_interceptor`  (
  `id` varchar(32) NOT NULL COMMENT '拦截器id',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `mid` varchar(32) NOT NULL COMMENT '模块id',
  `p1` text NULL COMMENT '参数1',
  `p2` text NULL COMMENT '参数2',
  `p3` text NULL COMMENT '参数3',
  `p4` text NULL COMMENT '参数4',
  `p5` text NULL COMMENT '参数5',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`)
) COMMENT = '拦截器';

CREATE TABLE `ls_interceptor_route`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `ic_id` varchar(32) NOT NULL COMMENT '拦截器id',
  `type` varchar(100) NOT NULL COMMENT '类型',
  `path` varchar(255) NOT NULL COMMENT '名称',
  `method` varchar(100) NOT NULL COMMENT '请求方式',
  `mode` varchar(100) NOT NULL COMMENT '匹配模式',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  INDEX `idx_ic_id`(`ic_id`)
) COMMENT = '拦截器路由';

CREATE TABLE `ls_module`  (
  `id` varchar(32) NOT NULL COMMENT '模块id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `desc` text NULL COMMENT '描述',
  `content` text NOT NULL COMMENT '内容',
  `p1_state` tinyint NULL COMMENT '参数1状态',
  `p1_info` text NULL COMMENT '参数1信息',
  `p2_state` tinyint NULL COMMENT '参数2状态',
  `p2_info` text NULL COMMENT '参数2信息',
  `p3_state` tinyint NULL COMMENT '参数3状态',
  `p3_info` text NULL COMMENT '参数3信息',
  `p4_state` tinyint NULL COMMENT '参数4状态',
  `p4_info` text NULL COMMENT '参数4信息',
  `p5_state` tinyint NULL COMMENT '参数5状态',
  `p5_info` text NULL COMMENT '参数5信息',
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

CREATE TABLE `ls_widget`  (
  `id` varchar(32) NOT NULL COMMENT '组件id',
  `level` varchar(255) NOT NULL COMMENT '级别',
  `type` varchar(255) NOT NULL COMMENT '类型',
  `code` varchar(100) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `desc` text NULL COMMENT '描述',
  `content` text NOT NULL COMMENT '内容',
  `p1_state` tinyint NULL COMMENT '参数1状态',
  `p1_info` text NULL COMMENT '参数1信息',
  `p2_state` tinyint NULL COMMENT '参数2状态',
  `p2_info` text NULL COMMENT '参数2信息',
  `p3_state` tinyint NULL COMMENT '参数3状态',
  `p3_info` text NULL COMMENT '参数3信息',
  `p4_state` tinyint NULL COMMENT '参数4状态',
  `p4_info` text NULL COMMENT '参数4信息',
  `p5_state` tinyint NULL COMMENT '参数5状态',
  `p5_info` text NULL COMMENT '参数5信息',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_code`(`code`),
  INDEX `idx_type`(`type`)
) COMMENT = '组件';

CREATE TABLE `ls_module_widget`  (
  `id` varchar(32) NOT NULL COMMENT 'id',
  `mid` varchar(32) NOT NULL COMMENT '模块id',
  `wid` varchar(32) NOT NULL COMMENT '组件id',
  `p1` text NULL COMMENT '参数1',
  `p2` text NULL COMMENT '参数2',
  `p3` text NULL COMMENT '参数3',
  `p4` text NULL COMMENT '参数4',
  `p5` text NULL COMMENT '参数5',
  `state` varchar(100) NOT NULL COMMENT '状态',
  `rank` bigint NOT NULL COMMENT '排序',
  `create_by` varchar(32) NULL COMMENT '创建人',
  `create_at` datetime NOT NULL COMMENT '创建时间',
  `update_by` varchar(32) NULL COMMENT '修改人',
  `update_at` datetime NOT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `idx_mid_wid`(`mid`, `wid`)
) COMMENT = '模块组件';

CREATE TABLE `ls_config`  (
  `id` varchar(32) NOT NULL COMMENT '配置id',
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