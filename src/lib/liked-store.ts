// 按讚紀錄：每個 session 內每題只能 +1 一次
// 換分頁、關掉重開即重置（教學情境夠用）
const KEY = "classwall:liked";

function read(): Set<string> {
  if (typeof window === "undefined") return new Set();
  try {
    const raw = sessionStorage.getItem(KEY);
    if (!raw) return new Set();
    const arr = JSON.parse(raw);
    return Array.isArray(arr) ? new Set(arr) : new Set();
  } catch {
    return new Set();
  }
}

function write(set: Set<string>) {
  if (typeof window === "undefined") return;
  try {
    sessionStorage.setItem(KEY, JSON.stringify(Array.from(set)));
  } catch {
    // sessionStorage 不可用時靜默 (隱私模式等)
  }
}

export function hasLiked(id: string): boolean {
  return read().has(id);
}

export function addLiked(id: string): void {
  const set = read();
  set.add(id);
  write(set);
}
