import request from "@/utils/request";

const BASE_URL = "/api/admin/stats";

const StatsAPI = {
  /**
   * 获取统计数据
   *
   * @param queryParams 查询参数
   */
  getData(queryParams: StatsQuery) {
    return request<any, StatsData[]>({
      url: `${BASE_URL}/data`,
      method: "post",
      data: queryParams,
    });
  },
};

export default StatsAPI;

/** 统计数据查询类型 */
export interface StatsQuery {
  /** 类型 */
  type: string;
  /** 开始时间 */
  start_time: number;
  /** 结束时间 */
  end_time: number;
}

/** 统计数据类型 */
export interface StatsData {
  /** ID */
  id: string;
  /** 类型 */
  type: string;
  /** 时间戳 */
  timestamp: number;
  /** 时间戳字符串 */
  timestamp_str: string;
  /** 值01 */
  value01?: number;
  /** 值02 */
  value02: number;
  /** 值03 */
  value03?: number;
  /** 值04 */
  value04: number;
  /** 值05 */
  value05?: number;
  /** 值06 */
  value06: number;
  /** 值07 */
  value07?: number;
  /** 值08 */
  value08: number;
  /** 值09 */
  value09?: number;
  /** 值10 */
  value10: number;
}
