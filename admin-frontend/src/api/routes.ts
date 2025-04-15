import { http } from "@/utils/http";
import { baseUrlApi } from "./utils";

type Result = HttpRes & {
  data: Array<any>;
};

export const getAsyncRoutes = () => {
  return http.request<Result>("get", baseUrlApi("get-async-routes"));
};
