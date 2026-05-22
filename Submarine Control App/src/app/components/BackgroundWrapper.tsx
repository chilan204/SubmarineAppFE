const BG_URL =
  "https://vcdn1-vnexpress.vnecdn.net/2021/09/15/dh-bach-khoa-hn-1631681053-7873-1631681129.jpg?w=1200&h=0&q=100&dpr=1&fit=crop&s=k9j2tKkGTVtI12aYpD1mgA";

export function BackgroundWrapper({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative w-full h-full overflow-hidden">
      {/* Background image */}
      <div
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{ backgroundImage: `url(${BG_URL})` }}
      />
      {/* Dark overlay to keep military UI readable */}
      <div className="absolute inset-0 bg-[#030d1a]/80" />
      {/* Content */}
      <div className="relative z-10 w-full h-full">
        {children}
      </div>
    </div>
  );
}
