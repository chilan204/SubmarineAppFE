import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Mic, Map, History, LogOut, Radio } from "lucide-react";
import { LoginScreen } from "./components/LoginScreen";
import { VoiceControlScreen, type Command } from "./components/VoiceControlScreen";
import { GpsMapScreen } from "./components/GpsMapScreen";
import { HistoryScreen } from "./components/HistoryScreen";
import { BackgroundWrapper } from "./components/BackgroundWrapper";
import { type Lang, getT } from "./translations";

type Screen = "voice" | "map" | "history";

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [activeScreen, setActiveScreen] = useState<Screen>("voice");
  const [commandHistory, setCommandHistory] = useState<Command[]>([]);
  const [missionTime, setMissionTime] = useState(0);
  const [lang, setLang] = useState<Lang>("vi");

  const t = getT(lang);

  const handleLogin = () => {
    setIsLoggedIn(true);
    const start = Date.now();
    const interval = setInterval(() => {
      setMissionTime(Math.floor((Date.now() - start) / 1000));
    }, 1000);
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setCommandHistory([]);
    setMissionTime(0);
  };

  const formatMissionTime = (secs: number) => {
    const h = Math.floor(secs / 3600).toString().padStart(2, "0");
    const m = Math.floor((secs % 3600) / 60).toString().padStart(2, "0");
    const s = (secs % 60).toString().padStart(2, "0");
    return `${h}:${m}:${s}`;
  };

  const navItems: { screen: Screen; icon: React.ReactNode; label: string }[] = [
    { screen: "voice", icon: <Mic className="w-5 h-5" />, label: t.control },
    { screen: "map", icon: <Map className="w-5 h-5" />, label: t.map },
    { screen: "history", icon: <History className="w-5 h-5" />, label: t.history },
  ];

  if (!isLoggedIn) {
    return (
      <BackgroundWrapper>
        <LoginScreen onLogin={handleLogin} lang={lang} />
        {/* Language toggle on login screen */}
        <div className="absolute top-4 right-4 z-20">
          <LangToggle lang={lang} setLang={setLang} />
        </div>
      </BackgroundWrapper>
    );
  }

  return (
    <BackgroundWrapper>
      <div className="flex flex-col h-full overflow-hidden" style={{ fontFamily: "monospace" }}>
        {/* Top bar */}
        <div className="flex-shrink-0 bg-[#050f1e]/70 backdrop-blur-md border-b border-[#00ffaa]/15 px-3 py-2 flex items-center justify-between">

          {/* Left: mobile = "Sĩ Quan", desktop = nothing */}
          <div className="flex items-center gap-2">
            {/* Mobile only: show Sĩ Quan */}
            <div className="flex sm:hidden items-center gap-1.5 px-2 py-1 rounded-lg bg-[#00ffaa]/5 border border-[#00ffaa]/20">
              <span className="text-[#00ffaa]" style={{ fontSize: "0.8rem", letterSpacing: "0.1em" }}>Sĩ Quan</span>
            </div>
            {/* Desktop: empty placeholder to maintain layout */}
            <div className="hidden sm:block w-8" />
          </div>

          {/* Center: mission timer */}
          <div className="text-center">
            <div className="text-[#ffaa00]" style={{ fontSize: "1rem", fontFamily: "monospace", letterSpacing: "0.1em" }}>
              {formatMissionTime(missionTime)}
            </div>
            <div className="text-[#8899aa]" style={{ fontSize: "0.6rem", letterSpacing: "0.1em" }}>{t.missionTime}</div>
          </div>

          {/* Right */}
          <div className="flex items-center gap-2">
            <LangToggle lang={lang} setLang={setLang} />
            <div className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#4488ff]/5 border border-[#4488ff]/15">
              <Radio className="w-3.5 h-3.5 text-[#4488ff]" />
              <span className="text-[#4488ff]" style={{ fontSize: "0.65rem" }}>{commandHistory.length} {t.commandCount}</span>
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-1.5 px-2 py-1.5 rounded-lg border border-red-400/20 text-red-400/70 hover:bg-red-400/10 hover:border-red-400/40 transition-all"
              style={{ fontSize: "0.75rem" }}
            >
              <LogOut className="w-3.5 h-3.5" />
              <span className="hidden sm:inline">{t.logout}</span>
            </button>
          </div>
        </div>

        {/* Tab nav */}
        <div className="flex-shrink-0 bg-[#0a1628]/70 backdrop-blur-md border-b border-[#00ffaa]/10 flex">
          {navItems.map(({ screen, icon, label }) => {
            const isActive = activeScreen === screen;
            return (
              <button
                key={screen}
                onClick={() => setActiveScreen(screen)}
                className="flex-1 flex flex-col items-center gap-1 py-2.5 relative transition-all"
                style={{
                  color: isActive ? "#00ffaa" : "#8899aa",
                  backgroundColor: isActive ? "rgba(0,255,170,0.05)" : "transparent",
                }}
              >
                {isActive && (
                  <motion.div layoutId="activeTab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#00ffaa]" />
                )}
                {icon}
                <span style={{ fontSize: "0.65rem", letterSpacing: "0.08em" }}>{label.toUpperCase()}</span>
                {screen === "history" && commandHistory.length > 0 && (
                  <span
                    className="absolute top-1.5 right-1/4 w-4 h-4 rounded-full bg-[#00ffaa] text-[#030d1a] flex items-center justify-center"
                    style={{ fontSize: "0.55rem", fontWeight: 700 }}
                  >
                    {commandHistory.length > 9 ? "9+" : commandHistory.length}
                  </span>
                )}
              </button>
            );
          })}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-hidden">
          <AnimatePresence mode="wait">
            {activeScreen === "voice" && (
              <motion.div key="voice" initial={{ opacity: 0, x: -15 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -15 }} transition={{ duration: 0.18 }} className="h-full">
                <VoiceControlScreen onCommandAdded={(cmd) => setCommandHistory((p) => [...p, cmd])} lang={lang} />
              </motion.div>
            )}
            {activeScreen === "map" && (
              <motion.div key="map" initial={{ opacity: 0, x: 15 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 15 }} transition={{ duration: 0.18 }} className="h-full">
                <GpsMapScreen lang={lang} />
              </motion.div>
            )}
            {activeScreen === "history" && (
              <motion.div key="history" initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: 15 }} transition={{ duration: 0.18 }} className="h-full">
                <HistoryScreen commands={commandHistory} lang={lang} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </BackgroundWrapper>
  );
}

function LangToggle({ lang, setLang }: { lang: Lang; setLang: (l: Lang) => void }) {
  return (
    <div className="flex items-center rounded-lg border border-[#00ffaa]/20 overflow-hidden">
      {(["vi", "en"] as Lang[]).map((l) => (
        <button
          key={l}
          onClick={() => setLang(l)}
          className="px-2 py-1 transition-all"
          style={{
            fontSize: "0.7rem",
            letterSpacing: "0.05em",
            color: lang === l ? "#030d1a" : "#8899aa",
            backgroundColor: lang === l ? "#00ffaa" : "transparent",
            fontWeight: lang === l ? 700 : 400,
          }}
        >
          {l.toUpperCase()}
        </button>
      ))}
    </div>
  );
}
