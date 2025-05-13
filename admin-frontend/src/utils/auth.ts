// 访问 token 缓存的 key
const ACCESS_TOKEN_KEY = "access_token";

function getAccessToken(): string {
  return localStorage.getItem(ACCESS_TOKEN_KEY) || "";
}

function setAccessToken(token: string) {
  localStorage.setItem(ACCESS_TOKEN_KEY, token);
}

function clearToken() {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
}

export { getAccessToken, setAccessToken, clearToken };
