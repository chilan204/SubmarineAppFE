import { useState, useEffect, useRef } from "react";
import { motion } from "motion/react";
import { Mic, MicOff, Lock, Eye, EyeOff, Shield, AlertCircle, User } from "lucide-react";
import { type Lang, getT } from "../translations";

interface LoginScreenProps {
  onLogin: () => void;
  lang: Lang;
}

declare global {
  interface Window {
    SpeechRecognition: typeof SpeechRecognition;
    webkitSpeechRecognition: typeof SpeechRecognition;
  }
}

export function LoginScreen({ onLogin, lang }: LoginScreenProps) {
  const t = getT(lang);
  const [mode, setMode] = useState<"select" | "password" | "voice">("select");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");
  const [isListening, setIsListening] = useState(false);
  const [transcript, setTranscript] = useState("");
  const [voiceStatus, setVoiceStatus] = useState("");
  const [pulseRing, setPulseRing] = useState(false);
  const recognitionRef = useRef<SpeechRecognition | null>(null);

  useEffect(() => {
    setVoiceStatus(t.pressmic);
  }, [lang]);

  useEffect(() => {
    return () => recognitionRef.current?.stop();
  }, []);

  const handlePasswordLogin = () => {
    if (username.trim() === "admin" && password === "SUBMARINE2024") {
      setError("");
      onLogin();
    } else {
      setError(t.wrongCreds);
    }
  };

  const startVoiceRecognition = () => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      setVoiceStatus(t.voiceNotSupported);
      return;
    }
    const recognition = new SpeechRecognition();
    recognition.lang = lang === "vi" ? "vi-VN" : "en-US";
    recognition.continuous = false;
    recognition.interimResults = true;

    recognition.onstart = () => {
      setIsListening(true);
      setPulseRing(true);
      setVoiceStatus(t.listening);
      setTranscript("");
      setError("");
    };

    recognition.onresult = (event) => {
      const result = event.results[event.results.length - 1];
      const text = result[0].transcript.toLowerCase();
      setTranscript(text);
      if (result.isFinal) {
        const isValid =
          lang === "vi"
            ? text.includes("kích hoạt") || text.includes("tàu ngầm")
            : text.includes("activate") || text.includes("submarine");
        if (isValid) {
          setVoiceStatus(t.authSuccess);
          setTimeout(() => onLogin(), 800);
        } else {
          setError(t.authFailed);
          setVoiceStatus(t.voiceVerifyFailed);
        }
      }
    };

    recognition.onerror = () => {
      setIsListening(false);
      setPulseRing(false);
      setVoiceStatus(t.voiceError);
    };

    recognition.onend = () => {
      setIsListening(false);
      setPulseRing(false);
    };

    recognitionRef.current = recognition;
    recognition.start();
  };

  const stopVoiceRecognition = () => {
    recognitionRef.current?.stop();
    setIsListening(false);
    setPulseRing(false);
    setVoiceStatus(t.pressmic);
  };

  const resetToSelect = () => {
    setMode("select");
    setError("");
    setPassword("");
    setUsername("");
    setTranscript("");
    stopVoiceRecognition();
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      {/* Grid overlay */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `
            linear-gradient(rgba(0,255,170,0.3) 1px, transparent 1px),
            linear-gradient(90deg, rgba(0,255,170,0.3) 1px, transparent 1px)
          `,
          backgroundSize: "50px 50px",
        }}
      />
      {/* Sonar rings */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full border border-[#00ffaa]/5" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[400px] h-[400px] rounded-full border border-[#00ffaa]/8" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[200px] h-[200px] rounded-full border border-[#00ffaa]/12" />

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative z-10 w-full max-w-md mx-4"
      >
        {/* Header */}
        <div className="text-center mb-8">
          <div className="flex justify-center mb-4">
            <div className="w-20 h-20 rounded-full bg-[#00ffaa]/10 border-2 border-[#00ffaa]/50 flex items-center justify-center">
              <Shield className="w-10 h-10 text-[#00ffaa]" />
            </div>
          </div>
          <h1 className="text-[#00ffaa] tracking-[0.3em] uppercase mb-1" style={{ fontSize: "1.5rem", fontWeight: 700 }}>
            NAUTICOM
          </h1>
          <p className="text-[#00ffaa]/50 tracking-widest uppercase" style={{ fontSize: "0.7rem" }}>
            {t.loginSubtitle}
          </p>
          <div className="mt-2 flex items-center justify-center gap-2">
            <div className="w-2 h-2 rounded-full bg-[#00ffaa] animate-pulse" />
            <span className="text-[#00ffaa]/60" style={{ fontSize: "0.7rem" }}>{t.online}</span>
          </div>
        </div>

        {/* Card */}
        <div className="bg-[#0a1628]/85 border border-[#00ffaa]/20 rounded-2xl p-6 shadow-2xl shadow-black/50 backdrop-blur-md">

          {/* SELECT */}
          {mode === "select" && (
            <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
              <p className="text-center text-[#8899aa] mb-6" style={{ fontSize: "0.85rem" }}>
                {t.selectAuth}
              </p>
              <div className="space-y-3">
                <button
                  onClick={() => setMode("voice")}
                  className="w-full flex items-center gap-4 p-4 rounded-xl border border-[#00ffaa]/20 bg-[#00ffaa]/5 hover:bg-[#00ffaa]/10 hover:border-[#00ffaa]/50 transition-all group"
                >
                  <div className="w-12 h-12 rounded-full bg-[#00ffaa]/10 border border-[#00ffaa]/30 flex items-center justify-center group-hover:bg-[#00ffaa]/20 transition-all">
                    <Mic className="w-6 h-6 text-[#00ffaa]" />
                  </div>
                  <div className="text-left">
                    <p className="text-[#00ffaa]" style={{ fontSize: "0.9rem" }}>{t.voiceAuth}</p>
                    <p className="text-[#8899aa]" style={{ fontSize: "0.75rem" }}>{t.voiceAuthDesc}</p>
                  </div>
                </button>
                <button
                  onClick={() => setMode("password")}
                  className="w-full flex items-center gap-4 p-4 rounded-xl border border-[#4488ff]/20 bg-[#4488ff]/5 hover:bg-[#4488ff]/10 hover:border-[#4488ff]/50 transition-all group"
                >
                  <div className="w-12 h-12 rounded-full bg-[#4488ff]/10 border border-[#4488ff]/30 flex items-center justify-center group-hover:bg-[#4488ff]/20 transition-all">
                    <Lock className="w-6 h-6 text-[#4488ff]" />
                  </div>
                  <div className="text-left">
                    <p className="text-[#4488ff]" style={{ fontSize: "0.9rem" }}>{t.passwordAuth}</p>
                    <p className="text-[#8899aa]" style={{ fontSize: "0.75rem" }}>{t.passwordAuthDesc}</p>
                  </div>
                </button>
              </div>
            </motion.div>
          )}

          {/* PASSWORD */}
          {mode === "password" && (
            <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }}>
              <button onClick={resetToSelect} className="text-[#8899aa] hover:text-white transition-colors mb-5 block" style={{ fontSize: "0.8rem" }}>
                {t.back}
              </button>

              {/* Username */}
              <label className="block text-[#4488ff] mb-1.5" style={{ fontSize: "0.75rem", letterSpacing: "0.1em" }}>
                {t.username}
              </label>
              <div className="relative mb-3">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#4488ff]/50" />
                <input
                  type="text"
                  value={username}
                  onChange={(e) => { setUsername(e.target.value); setError(""); }}
                  onKeyDown={(e) => e.key === "Enter" && handlePasswordLogin()}
                  placeholder="admin"
                  className="w-full bg-[#0d2040] border border-[#4488ff]/30 rounded-lg pl-10 pr-4 py-3 text-white placeholder-[#4466aa]/40 focus:outline-none focus:border-[#4488ff] transition-colors"
                  style={{ fontFamily: "monospace", letterSpacing: "0.1em" }}
                />
              </div>

              {/* Password */}
              <label className="block text-[#4488ff] mb-1.5" style={{ fontSize: "0.75rem", letterSpacing: "0.1em" }}>
                {t.password}
              </label>
              <div className="relative mb-4">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#4488ff]/50" />
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => { setPassword(e.target.value); setError(""); }}
                  onKeyDown={(e) => e.key === "Enter" && handlePasswordLogin()}
                  placeholder="••••••••••••"
                  className="w-full bg-[#0d2040] border border-[#4488ff]/30 rounded-lg pl-10 pr-12 py-3 text-white placeholder-[#4466aa]/40 focus:outline-none focus:border-[#4488ff] transition-colors"
                  style={{ fontFamily: "monospace", letterSpacing: "0.15em" }}
                />
                <button
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-[#4488ff]/50 hover:text-[#4488ff] transition-colors"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>

              {error && (
                <div className="flex items-center gap-2 text-red-400 mb-4" style={{ fontSize: "0.8rem" }}>
                  <AlertCircle className="w-4 h-4 flex-shrink-0" />
                  {error}
                </div>
              )}
              <button
                onClick={handlePasswordLogin}
                className="w-full py-3 rounded-lg bg-[#4488ff] hover:bg-[#5599ff] text-white transition-all"
                style={{ letterSpacing: "0.15em" }}
              >
                {t.authenticate}
              </button>
              <p className="text-center text-[#8899aa]/50 mt-3" style={{ fontSize: "0.7rem" }}>
                {t.hint}
              </p>
            </motion.div>
          )}

          {/* VOICE */}
          {mode === "voice" && (
            <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="text-center">
              <button onClick={resetToSelect} className="text-[#8899aa] hover:text-white transition-colors mb-5 block" style={{ fontSize: "0.8rem" }}>
                {t.back}
              </button>
              <p className="text-[#8899aa] mb-1" style={{ fontSize: "0.8rem" }}>{t.sayPhrase}</p>
              <p className="text-[#00ffaa] mb-6" style={{ fontSize: "0.9rem", fontStyle: "italic" }}>
                {t.voicePhrase}
              </p>

              {/* Mic button with rings */}
              <div className="flex justify-center mb-6">
                <div className="relative">
                  {pulseRing && (
                    <>
                      <div className="absolute inset-0 rounded-full border-2 border-[#00ffaa]/40 animate-ping" />
                      <div className="absolute inset-[-10px] rounded-full border border-[#00ffaa]/20 animate-ping" style={{ animationDelay: "0.3s" }} />
                      <div className="absolute inset-[-20px] rounded-full border border-[#00ffaa]/10 animate-ping" style={{ animationDelay: "0.6s" }} />
                    </>
                  )}
                  <button
                    onClick={isListening ? stopVoiceRecognition : startVoiceRecognition}
                    className={`relative w-24 h-24 rounded-full border-2 flex items-center justify-center transition-all ${
                      isListening
                        ? "bg-[#00ffaa]/20 border-[#00ffaa] shadow-lg shadow-[#00ffaa]/30"
                        : "bg-[#00ffaa]/5 border-[#00ffaa]/30 hover:bg-[#00ffaa]/15 hover:border-[#00ffaa]/60"
                    }`}
                  >
                    {isListening ? <MicOff className="w-10 h-10 text-[#00ffaa]" /> : <Mic className="w-10 h-10 text-[#00ffaa]" />}
                  </button>
                </div>
              </div>

              <p className="text-[#8899aa] mb-3" style={{ fontSize: "0.8rem" }}>{voiceStatus}</p>

              {transcript && (
                <div className="bg-[#0d2040] border border-[#00ffaa]/20 rounded-lg p-3 mb-4">
                  <p className="text-[#00ffaa]/80 italic" style={{ fontSize: "0.85rem" }}>"{transcript}"</p>
                </div>
              )}

              {error && (
                <div className="flex items-center justify-center gap-2 text-red-400" style={{ fontSize: "0.8rem" }}>
                  <AlertCircle className="w-4 h-4" />
                  {error}
                </div>
              )}
            </motion.div>
          )}
        </div>

        <p className="text-center text-[#8899aa]/30 mt-6" style={{ fontSize: "0.65rem", letterSpacing: "0.2em" }}>
          {t.classified}
        </p>
      </motion.div>
    </div>
  );
}
