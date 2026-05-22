import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { CheckCircle, AlertTriangle, Search, Download, Clock, ChevronRight, X } from "lucide-react";
import type { Command } from "./VoiceControlScreen";
import { type Lang, getT } from "../translations";

type FilterType = "all" | "successful" | "unsuccessful";

interface HistoryScreenProps {
  commands: Command[];
  lang: Lang;
}

const INITIAL_COMMANDS_VI: Command[] = [
  { id: "h1", text: "Kiểm tra hệ thống", timestamp: new Date(Date.now() - 3600000), status: "success", response: "Tất cả hệ thống bình thường. Pin: 87%. Oxy: 94%" },
  { id: "h2", text: "Lặn xuống 50m", timestamp: new Date(Date.now() - 3200000), status: "success", response: "Đang thực hiện lặn xuống. Độ sâu mục tiêu: -50m" },
  { id: "h3", text: "Tiến về phía trước", timestamp: new Date(Date.now() - 2800000), status: "success", response: "Động cơ đẩy kích hoạt. Tốc độ 5 hải lý/h" },
  { id: "h4", text: "Phóng ngư lôi", timestamp: new Date(Date.now() - 2400000), status: "warning", response: "CẢNH BÁO: Cần xác nhận từ chỉ huy cấp cao" },
  { id: "h5", text: "Quay trái 15 độ", timestamp: new Date(Date.now() - 2000000), status: "success", response: "Bánh lái trái 15°. Đang điều hướng" },
  { id: "h6", text: "Chế độ tàng hình", timestamp: new Date(Date.now() - 1600000), status: "success", response: "Hệ thống âm học tắt. Chế độ im lặng kích hoạt" },
  { id: "h7", text: "Khẩn cấp nổi lên", timestamp: new Date(Date.now() - 1200000), status: "error", response: "KHẨN CẤP: Thổi két nước dằn. Nổi lên khẩn cấp!" },
  { id: "h8", text: "Kiểm tra sonar", timestamp: new Date(Date.now() - 800000), status: "success", response: "Sonar hoạt động bình thường. Không phát hiện mục tiêu" },
  { id: "h9", text: "Dừng lại", timestamp: new Date(Date.now() - 400000), status: "success", response: "Hệ thống đẩy dừng. Giữ vị trí hiện tại" },
  { id: "h10", text: "Nổi lên", timestamp: new Date(Date.now() - 120000), status: "success", response: "Đang nổi lên. Độ sâu mục tiêu: 0m" },
];

const INITIAL_COMMANDS_EN: Command[] = [
  { id: "h1", text: "Check systems", timestamp: new Date(Date.now() - 3600000), status: "success", response: "All systems normal. Battery: 87%. Oxygen: 94%" },
  { id: "h2", text: "Dive to 50m", timestamp: new Date(Date.now() - 3200000), status: "success", response: "Executing dive. Target depth: -50m" },
  { id: "h3", text: "Move forward", timestamp: new Date(Date.now() - 2800000), status: "success", response: "Propulsion engaged. Speed: 5 knots" },
  { id: "h4", text: "Launch torpedo", timestamp: new Date(Date.now() - 2400000), status: "warning", response: "WARNING: Requires senior command confirmation" },
  { id: "h5", text: "Turn left 15°", timestamp: new Date(Date.now() - 2000000), status: "success", response: "Rudder left 15°. Navigating" },
  { id: "h6", text: "Stealth mode", timestamp: new Date(Date.now() - 1600000), status: "success", response: "Acoustic systems off. Silent mode activated" },
  { id: "h7", text: "Emergency surface", timestamp: new Date(Date.now() - 1200000), status: "error", response: "EMERGENCY: Blowing ballast tanks. Emergency ascent!" },
  { id: "h8", text: "Sonar check", timestamp: new Date(Date.now() - 800000), status: "success", response: "Sonar operating normally. No targets detected" },
  { id: "h9", text: "Stop", timestamp: new Date(Date.now() - 400000), status: "success", response: "Propulsion stopped. Holding position" },
  { id: "h10", text: "Surface", timestamp: new Date(Date.now() - 120000), status: "success", response: "Surfacing. Target depth: 0m" },
];

export function HistoryScreen({ commands, lang }: HistoryScreenProps) {
  const t = getT(lang);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<FilterType>("all");
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const initialCmds = lang === "vi" ? INITIAL_COMMANDS_VI : INITIAL_COMMANDS_EN;
  const allCommands = [...initialCmds, ...commands].sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());

  const isSuccessful = (cmd: Command) => cmd.status === "success";
  const isUnsuccessful = (cmd: Command) => cmd.status === "warning" || cmd.status === "error";

  const filtered = allCommands.filter((cmd) => {
    const matchSearch =
      cmd.text.toLowerCase().includes(search.toLowerCase()) ||
      cmd.response.toLowerCase().includes(search.toLowerCase());
    const matchFilter =
      filter === "all" ||
      (filter === "successful" && isSuccessful(cmd)) ||
      (filter === "unsuccessful" && isUnsuccessful(cmd));
    return matchSearch && matchFilter;
  });

  const counts = {
    all: allCommands.length,
    successful: allCommands.filter(isSuccessful).length,
    unsuccessful: allCommands.filter(isUnsuccessful).length,
  };

  const tabs: { key: FilterType; label: string; color: string; countColor: string }[] = [
    { key: "all", label: t.all, color: "border-[#8899aa]/40 bg-[#8899aa]/10", countColor: "#aabbcc" },
    { key: "successful", label: t.successful, color: "border-[#00ffaa]/40 bg-[#00ffaa]/10", countColor: "#00ffaa" },
    { key: "unsuccessful", label: t.unsuccessful, color: "border-red-400/40 bg-red-400/10", countColor: "#ff6666" },
  ];

  const statusCfg = {
    success: { icon: <CheckCircle className="w-4 h-4" />, color: "#00ffaa", bg: "border-[#00ffaa]/20 bg-[#00ffaa]/5", label: t.statusSuccess },
    warning: { icon: <AlertTriangle className="w-4 h-4" />, color: "#ffaa00", bg: "border-yellow-400/20 bg-yellow-400/5", label: t.statusWarning },
    error: { icon: <AlertTriangle className="w-4 h-4" />, color: "#ff4444", bg: "border-red-400/20 bg-red-400/5", label: t.statusError },
  };

  const timeAgo = (date: Date) => {
    const diff = Date.now() - date.getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return t.timeJustNow;
    if (mins < 60) return `${mins} ${t.timeMinAgo}`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs} ${t.timeHrAgo}`;
    return `${Math.floor(hrs / 24)} ${t.timeDayAgo}`;
  };

  const formatTime = (date: Date) =>
    date.toLocaleString(lang === "vi" ? "vi-VN" : "en-US", {
      day: "2-digit", month: "2-digit", year: "numeric",
      hour: "2-digit", minute: "2-digit", second: "2-digit",
    });

  return (
    <div className="flex flex-col h-full overflow-hidden">
      {/* Header */}
      <div className="px-4 py-3 bg-[#0a1628]/70 backdrop-blur-md border-b border-[#00ffaa]/10">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="text-[#00ffaa]" style={{ fontSize: "0.95rem" }}>{t.historyTitle}</h2>
            <p className="text-[#8899aa]" style={{ fontSize: "0.7rem" }}>{allCommands.length} {t.historySubtitle}</p>
          </div>
          <button className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#00ffaa]/20 text-[#00ffaa]/70 hover:bg-[#00ffaa]/10 transition-all" style={{ fontSize: "0.75rem" }}>
            <Download className="w-3.5 h-3.5" />
            {t.exportReport}
          </button>
        </div>

        {/* 3-tab filter */}
        <div className="flex gap-2 mb-3">
          {tabs.map(({ key, label, color, countColor }) => (
            <button
              key={key}
              onClick={() => setFilter(key)}
              className={`flex-1 flex flex-col items-center py-2 rounded-lg border transition-all ${
                filter === key ? color : "border-[#8899aa]/10 bg-transparent hover:border-[#8899aa]/20"
              }`}
            >
              <span style={{ color: filter === key ? countColor : "#8899aa", fontSize: "1.1rem", fontWeight: 700, fontFamily: "monospace" }}>
                {counts[key]}
              </span>
              <span style={{ color: filter === key ? countColor : "#8899aa", fontSize: "0.65rem" }}>{label}</span>
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#8899aa]" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={t.searchPlaceholder}
            className="w-full bg-[#0d2040] border border-[#00ffaa]/15 rounded-lg pl-9 pr-9 py-2 text-white placeholder-[#8899aa]/50 focus:outline-none focus:border-[#00ffaa]/40 transition-colors"
            style={{ fontSize: "0.85rem" }}
          />
          {search && (
            <button onClick={() => setSearch("")} className="absolute right-3 top-1/2 -translate-y-1/2 text-[#8899aa] hover:text-white">
              <X className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* List */}
      <div className="flex-1 overflow-y-auto bg-[#030d1a]/40 backdrop-blur-sm">
        {filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center p-8">
            <Search className="w-12 h-12 text-[#8899aa]/20 mb-4" />
            <p className="text-[#8899aa]" style={{ fontSize: "0.85rem" }}>{t.noCommands}</p>
          </div>
        ) : (
          <div className="divide-y divide-[#00ffaa]/5">
            {filtered.map((cmd, i) => {
              const cfg = statusCfg[cmd.status];
              const isOpen = selectedId === cmd.id;
              return (
                <motion.button
                  key={cmd.id}
                  initial={{ opacity: 0, x: -8 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: i * 0.025 }}
                  onClick={() => setSelectedId(isOpen ? null : cmd.id)}
                  className="w-full text-left px-4 py-3 hover:bg-[#0a1628]/50 transition-all"
                >
                  <div className="flex items-start gap-3">
                    <div className={`mt-0.5 p-1.5 rounded-lg border ${cfg.bg} flex-shrink-0`} style={{ color: cfg.color }}>
                      {cfg.icon}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between gap-2 mb-0.5">
                        <span className="text-white truncate" style={{ fontSize: "0.875rem" }}>{cmd.text}</span>
                        <div className="flex items-center gap-1.5 flex-shrink-0">
                          <Clock className="w-3 h-3 text-[#8899aa]" />
                          <span className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{timeAgo(cmd.timestamp)}</span>
                        </div>
                      </div>
                      <p className="text-[#8899aa] truncate" style={{ fontSize: "0.75rem" }}>{cmd.response}</p>

                      <AnimatePresence>
                        {isOpen && (
                          <motion.div
                            initial={{ opacity: 0, height: 0 }}
                            animate={{ opacity: 1, height: "auto" }}
                            exit={{ opacity: 0, height: 0 }}
                            className={`mt-2 p-3 rounded-lg border overflow-hidden ${cfg.bg}`}
                          >
                            <div className="grid grid-cols-2 gap-3 mb-2">
                              <div>
                                <p className="text-[#8899aa] mb-1" style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>{t.timeLabel}</p>
                                <p style={{ color: cfg.color, fontSize: "0.75rem", fontFamily: "monospace" }}>{formatTime(cmd.timestamp)}</p>
                              </div>
                              <div>
                                <p className="text-[#8899aa] mb-1" style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>{t.statusLabel}</p>
                                <p style={{ color: cfg.color, fontSize: "0.75rem" }}>{cfg.label}</p>
                              </div>
                            </div>
                            <div className="mb-2">
                              <p className="text-[#8899aa] mb-1" style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>{t.sysResponse}</p>
                              <p className="text-white" style={{ fontSize: "0.8rem" }}>{cmd.response}</p>
                            </div>
                            <div>
                              <p className="text-[#8899aa] mb-1" style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>{t.cmdId}</p>
                              <p style={{ color: "#8899aa", fontSize: "0.65rem", fontFamily: "monospace" }}>#{cmd.id.toUpperCase()}</p>
                            </div>
                          </motion.div>
                        )}
                      </AnimatePresence>
                    </div>
                    <ChevronRight className={`w-4 h-4 text-[#8899aa] flex-shrink-0 mt-1 transition-transform ${isOpen ? "rotate-90" : ""}`} />
                  </div>
                </motion.button>
              );
            })}
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="px-4 py-2 bg-[#0a1628]/70 backdrop-blur-md border-t border-[#00ffaa]/10 flex items-center justify-between">
        <span className="text-[#8899aa]" style={{ fontSize: "0.7rem" }}>
          {t.showing} {filtered.length} {t.of} {allCommands.length}
        </span>
        <div className="flex items-center gap-1">
          <div className="w-1.5 h-1.5 rounded-full bg-[#00ffaa] animate-pulse" />
          <span className="text-[#00ffaa]/50" style={{ fontSize: "0.65rem" }}>{t.autoRecord}</span>
        </div>
      </div>
    </div>
  );
}
