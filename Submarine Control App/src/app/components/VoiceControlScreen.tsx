import { useState, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mic, MicOff, Send, CheckCircle, AlertTriangle, Gauge, Navigation, Waves } from "lucide-react";
import { type Lang, getT } from "../translations";

export interface Command {
  id: string;
  text: string;
  timestamp: Date;
  status: "success" | "warning" | "error";
  response: string;
}

interface VoiceControlScreenProps {
  onCommandAdded: (cmd: Command) => void;
  lang: Lang;
}

const COMMANDS_VI: Record<string, { response: string; status: "success" | "warning" | "error" }> = {
  "lặn xuống": { response: "Đang thực hiện lặn xuống. Độ sâu mục tiêu: -50m", status: "success" },
  "nổi lên": { response: "Đang nổi lên. Độ sâu mục tiêu: 0m", status: "success" },
  "tiến": { response: "Động cơ đẩy kích hoạt. Tốc độ 5 hải lý/h", status: "success" },
  "dừng": { response: "Hệ thống đẩy dừng. Giữ vị trí hiện tại", status: "success" },
  "quay trái": { response: "Bánh lái trái 15°. Đang điều hướng", status: "success" },
  "quay phải": { response: "Bánh lái phải 15°. Đang điều hướng", status: "success" },
  "phóng ngư lôi": { response: "CẢNH BÁO: Cần xác nhận từ chỉ huy cấp cao", status: "warning" },
  "tàng hình": { response: "Hệ thống âm học tắt. Chế độ im lặng kích hoạt", status: "success" },
  "kiểm tra": { response: "Tất cả hệ thống bình thường. Pin: 87%. Oxy: 94%", status: "success" },
  "khẩn cấp": { response: "KHẨN CẤP: Thổi két nước dằn. Nổi lên khẩn cấp!", status: "error" },
};

const COMMANDS_EN: Record<string, { response: string; status: "success" | "warning" | "error" }> = {
  "dive": { response: "Executing dive. Target depth: -50m", status: "success" },
  "surface": { response: "Surfacing. Target depth: 0m", status: "success" },
  "forward": { response: "Propulsion engaged. Speed: 5 knots", status: "success" },
  "stop": { response: "Propulsion stopped. Holding current position", status: "success" },
  "turn left": { response: "Rudder left 15°. Navigating", status: "success" },
  "turn right": { response: "Rudder right 15°. Navigating", status: "success" },
  "torpedo": { response: "WARNING: Requires senior command confirmation", status: "warning" },
  "stealth": { response: "Acoustic systems off. Silent mode activated", status: "success" },
  "check": { response: "All systems normal. Battery: 87%. Oxygen: 94%", status: "success" },
  "emergency": { response: "EMERGENCY: Blowing ballast tanks. Emergency ascent!", status: "error" },
};

function parseCommand(text: string, lang: Lang): { response: string; status: "success" | "warning" | "error" } {
  const lower = text.toLowerCase();
  const cmds = lang === "vi" ? COMMANDS_VI : COMMANDS_EN;
  for (const [key, val] of Object.entries(cmds)) {
    if (lower.includes(key)) return val;
  }
  return lang === "vi"
    ? { response: `Lệnh nhận được: "${text}". Đang xử lý...`, status: "success" }
    : { response: `Command received: "${text}". Processing...`, status: "success" };
}

// Sound bars animation shown when mic is active
function SoundBars() {
  const heights = [0.4, 0.8, 1, 0.6, 0.9, 0.5, 0.7];
  return (
    <div className="flex items-center justify-center gap-0.5 h-8">
      {heights.map((h, i) => (
        <motion.div
          key={i}
          className="w-1 rounded-full bg-[#00ffaa]"
          animate={{ height: [`${h * 28}px`, `${h * 6}px`, `${h * 28}px`] }}
          transition={{ duration: 0.4 + i * 0.07, repeat: Infinity, ease: "easeInOut", delay: i * 0.05 }}
        />
      ))}
    </div>
  );
}

export function VoiceControlScreen({ onCommandAdded, lang }: VoiceControlScreenProps) {
  const t = getT(lang);
  const [isListening, setIsListening] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [inputText, setInputText] = useState("");
  const [commands, setCommands] = useState<Command[]>([]);
  const [status, setStatus] = useState(t.systemReady);
  const [depth, setDepth] = useState(-35);
  const [speed, setSpeed] = useState(4.2);
  const [heading, setHeading] = useState(247);
  const [pressure, setPressure] = useState(3.5);
  const recognitionRef = useRef<SpeechRecognition | null>(null);
  const logRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setStatus(t.systemReady);
  }, [lang]);

  useEffect(() => {
    if (logRef.current) logRef.current.scrollTop = logRef.current.scrollHeight;
  }, [commands]);

  const addCommand = (text: string) => {
    const { response, status: cmdStatus } = parseCommand(text, lang);
    const newCmd: Command = { id: Date.now().toString(), text, timestamp: new Date(), status: cmdStatus, response };
    setCommands((prev) => [...prev, newCmd]);
    onCommandAdded(newCmd);

    const lower = text.toLowerCase();
    if (lower.includes("lặn") || lower.includes("dive")) setDepth((d) => Math.min(d - 15, -150));
    if (lower.includes("nổi") || lower.includes("surface")) setDepth((d) => Math.max(d + 15, 0));
    if (lower.includes("tiến") || lower.includes("forward")) setSpeed(5.0);
    if (lower.includes("dừng") || lower.includes("stop")) setSpeed(0);
    if (lower.includes("trái") || lower.includes("left")) setHeading((h) => (h - 15 + 360) % 360);
    if (lower.includes("phải") || lower.includes("right")) setHeading((h) => (h + 15) % 360);
  };

  const startListening = () => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) return;
    const recognition = new SpeechRecognition();
    recognition.lang = lang === "vi" ? "vi-VN" : "en-US";
    recognition.continuous = true;
    recognition.interimResults = true;

    recognition.onstart = () => { setIsListening(true); setStatus(t.listeningCmd); };

    recognition.onresult = (event) => {
      let interim = "";
      let final = "";
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const res = event.results[i];
        if (res.isFinal) final += res[0].transcript;
        else interim += res[0].transcript;
      }
      setTranscript(interim || final);
      if (final.trim()) {
        addCommand(final.trim());
        setTranscript("");
        setStatus(t.cmdReceived);
      }
    };

    recognition.onerror = () => { setIsListening(false); setStatus(t.systemReady); };
    recognition.onend = () => { setIsListening(false); setStatus(t.systemReady); setTranscript(""); };

    recognitionRef.current = recognition;
    recognition.start();
  };

  const stopListening = () => {
    recognitionRef.current?.stop();
    setIsListening(false);
    setStatus(t.systemReady);
    setTranscript("");
  };

  const sendTextCommand = () => {
    if (!inputText.trim()) return;
    addCommand(inputText.trim());
    setInputText("");
  };

  const statusCfg = {
    success: { icon: <CheckCircle className="w-3.5 h-3.5" />, color: "#00ffaa", bg: "border-[#00ffaa]/20 bg-[#00ffaa]/5" },
    warning: { icon: <AlertTriangle className="w-3.5 h-3.5" />, color: "#ffaa00", bg: "border-yellow-400/20 bg-yellow-400/5" },
    error: { icon: <AlertTriangle className="w-3.5 h-3.5" />, color: "#ff4444", bg: "border-red-400/20 bg-red-400/5" },
  };

  return (
    <div className="flex flex-col h-full text-white overflow-hidden">
      {/* Status bar */}
      <div className="flex items-center justify-between px-4 py-2 bg-[#0a1628]/70 backdrop-blur-md border-b border-[#00ffaa]/10">
        <div className="flex items-center gap-2">
          <div className={`w-2 h-2 rounded-full ${isListening ? "bg-[#00ffaa] animate-pulse" : "bg-[#8899aa]"}`} />
          <span className="text-[#8899aa]" style={{ fontSize: "0.75rem" }}>{status}</span>
        </div>
        <span className="text-[#00ffaa]/40" style={{ fontSize: "0.65rem", letterSpacing: "0.15em" }}>COMBAT SYS v2.4</span>
      </div>

      {/* Metrics row */}
      <div className="grid grid-cols-4 gap-px bg-[#00ffaa]/10 border-b border-[#00ffaa]/10 backdrop-blur-md">
        {[
          { icon: <Navigation className="w-3 h-3" />, label: t.depth, value: `${depth}m`, color: "#4488ff" },
          { icon: <Gauge className="w-3 h-3" />, label: t.speed, value: `${speed.toFixed(1)} kn`, color: "#00ffaa" },
          { icon: <Navigation className="w-3 h-3" />, label: t.heading, value: `${heading}°`, color: "#ffaa00" },
          { icon: <Waves className="w-3 h-3" />, label: t.pressure, value: `${pressure.toFixed(1)} atm`, color: "#ff4488" },
        ].map((m) => (
          <div key={m.label} className="bg-[#0a1628]/70 px-3 py-2 flex flex-col items-center">
            <div className="flex items-center gap-1 mb-1" style={{ color: m.color }}>
              {m.icon}
              <span style={{ fontSize: "0.6rem", letterSpacing: "0.08em" }}>{m.label}</span>
            </div>
            <span style={{ color: m.color, fontSize: "0.9rem", fontFamily: "monospace", fontWeight: 700 }}>{m.value}</span>
          </div>
        ))}
      </div>

      {/* Command log */}
      <div ref={logRef} className="flex-1 overflow-y-auto p-4 space-y-3 bg-[#030d1a]/30 backdrop-blur-sm">
        {commands.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <Waves className="w-12 h-12 text-[#00ffaa]/20 mb-4" />
            <p className="text-[#8899aa] mb-4" style={{ fontSize: "0.85rem" }}>
              {lang === "vi"
                ? "Nhấn microphone hoặc nhập lệnh để điều khiển tàu ngầm"
                : "Press microphone or type a command to control the submarine"}
            </p>
            <div className="grid grid-cols-2 gap-2">
              {(t.quickCmds as string[]).map((cmd) => (
                <button
                  key={cmd}
                  onClick={() => addCommand(cmd)}
                  className="px-3 py-1.5 rounded-lg border border-[#00ffaa]/20 text-[#00ffaa]/70 hover:bg-[#00ffaa]/10 hover:border-[#00ffaa]/50 transition-all"
                  style={{ fontSize: "0.75rem" }}
                >
                  {cmd}
                </button>
              ))}
            </div>
          </div>
        )}

        <AnimatePresence>
          {commands.map((cmd) => {
            const cfg = statusCfg[cmd.status];
            return (
              <motion.div key={cmd.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="space-y-1">
                <div className="flex items-start gap-2 justify-end">
                  <div className="bg-[#1a2a4a]/80 border border-[#4488ff]/20 rounded-lg rounded-tr-sm px-3 py-2 max-w-xs">
                    <p className="text-[#88aaff]" style={{ fontSize: "0.85rem" }}>{cmd.text}</p>
                    <p className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{cmd.timestamp.toLocaleTimeString(lang === "vi" ? "vi-VN" : "en-US")}</p>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <div className={`border rounded-lg rounded-tl-sm px-3 py-2 max-w-sm ${cfg.bg}`}>
                    <div className="flex items-center gap-1.5 mb-1" style={{ color: cfg.color }}>
                      {cfg.icon}
                      <span style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>{t.systemLabel}</span>
                    </div>
                    <p className="text-white/80" style={{ fontSize: "0.85rem" }}>{cmd.response}</p>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>

        {transcript && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex justify-end">
            <div className="bg-[#1a2a4a]/60 border border-[#4488ff]/10 rounded-lg px-3 py-2 max-w-xs">
              <p className="text-[#88aaff]/60 italic" style={{ fontSize: "0.85rem" }}>{transcript}...</p>
            </div>
          </motion.div>
        )}
      </div>

      {/* Input area */}
      <div className="border-t border-[#00ffaa]/10 bg-[#0a1628]/70 backdrop-blur-md p-4">
        <div className="flex items-center gap-3">
          {/* Mic button with full animation */}
          <div className="relative flex-shrink-0">
            {/* Pulsing rings */}
            {isListening && (
              <>
                <motion.div
                  className="absolute rounded-full border-2 border-[#00ffaa]/50"
                  initial={{ inset: 0, opacity: 0.8 }}
                  animate={{ inset: -10, opacity: 0 }}
                  transition={{ duration: 1.2, repeat: Infinity, ease: "easeOut" }}
                />
                <motion.div
                  className="absolute rounded-full border border-[#00ffaa]/30"
                  initial={{ inset: 0, opacity: 0.6 }}
                  animate={{ inset: -20, opacity: 0 }}
                  transition={{ duration: 1.2, repeat: Infinity, ease: "easeOut", delay: 0.4 }}
                />
                <motion.div
                  className="absolute rounded-full border border-[#00ffaa]/20"
                  initial={{ inset: 0, opacity: 0.4 }}
                  animate={{ inset: -30, opacity: 0 }}
                  transition={{ duration: 1.2, repeat: Infinity, ease: "easeOut", delay: 0.8 }}
                />
              </>
            )}
            <button
              onClick={isListening ? stopListening : startListening}
              className={`relative w-12 h-12 rounded-full border-2 flex items-center justify-center transition-all z-10 ${
                isListening
                  ? "bg-[#00ffaa]/20 border-[#00ffaa] shadow-lg shadow-[#00ffaa]/40"
                  : "bg-[#00ffaa]/5 border-[#00ffaa]/30 hover:bg-[#00ffaa]/15 hover:border-[#00ffaa]/60"
              }`}
            >
              {isListening ? <MicOff className="w-5 h-5 text-[#00ffaa]" /> : <Mic className="w-5 h-5 text-[#00ffaa]" />}
            </button>
          </div>

          {/* Sound bars shown above input when active */}
          {isListening ? (
            <div className="flex-1 flex items-center justify-center bg-[#0d2040]/80 border border-[#00ffaa]/20 rounded-lg px-4 h-11">
              <SoundBars />
            </div>
          ) : (
            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && sendTextCommand()}
              placeholder={t.enterCmd}
              className="flex-1 bg-[#0d2040] border border-[#00ffaa]/20 rounded-lg px-4 py-2.5 text-white placeholder-[#8899aa]/50 focus:outline-none focus:border-[#00ffaa]/50 transition-colors"
              style={{ fontSize: "0.9rem" }}
            />
          )}

          <button
            onClick={sendTextCommand}
            disabled={!inputText.trim() || isListening}
            className="w-12 h-12 rounded-full bg-[#00ffaa]/10 border border-[#00ffaa]/30 flex items-center justify-center hover:bg-[#00ffaa]/20 hover:border-[#00ffaa]/60 disabled:opacity-30 disabled:cursor-not-allowed transition-all flex-shrink-0"
          >
            <Send className="w-5 h-5 text-[#00ffaa]" />
          </button>
        </div>
        <p className="text-center text-[#8899aa]/30 mt-2" style={{ fontSize: "0.65rem" }}>
          {t.cmdHint}
        </p>
      </div>
    </div>
  );
}
