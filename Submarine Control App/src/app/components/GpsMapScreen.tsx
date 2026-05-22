import { useState, useEffect, useCallback } from "react";
import { GoogleMap, LoadScript, Marker, Polyline, InfoWindow } from "@react-google-maps/api";
import { Navigation, Gauge, Waves, Compass } from "lucide-react";
import { type Lang, getT } from "../translations";

const GOOGLE_MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY || "";

const MAP_STYLES = [
  { elementType: "geometry", stylers: [{ color: "#0a1628" }] },
  { elementType: "labels.text.stroke", stylers: [{ color: "#0a1628" }] },
  { elementType: "labels.text.fill", stylers: [{ color: "#4488ff" }] },
  { featureType: "administrative", elementType: "geometry.stroke", stylers: [{ color: "#1a3a5a" }] },
  { featureType: "administrative.land_parcel", elementType: "labels.text.fill", stylers: [{ color: "#4488ff" }] },
  { featureType: "landscape.natural", elementType: "geometry", stylers: [{ color: "#091520" }] },
  { featureType: "poi", elementType: "geometry", stylers: [{ color: "#0d2035" }] },
  { featureType: "poi", elementType: "labels.text.fill", stylers: [{ color: "#4488ff" }] },
  { featureType: "poi.park", elementType: "geometry.fill", stylers: [{ color: "#0d2a1a" }] },
  { featureType: "poi.park", elementType: "labels.text.fill", stylers: [{ color: "#3a8a55" }] },
  { featureType: "road", elementType: "geometry", stylers: [{ color: "#1a2a40" }] },
  { featureType: "road.arterial", elementType: "labels.text.fill", stylers: [{ color: "#4466aa" }] },
  { featureType: "road.highway", elementType: "geometry", stylers: [{ color: "#1f3a5a" }] },
  { featureType: "road.highway", elementType: "labels.text.fill", stylers: [{ color: "#4488cc" }] },
  { featureType: "road.local", elementType: "labels.text.fill", stylers: [{ color: "#334455" }] },
  { featureType: "transit.line", elementType: "geometry", stylers: [{ color: "#1a2a40" }] },
  { featureType: "transit.station", elementType: "geometry", stylers: [{ color: "#0d2035" }] },
  { featureType: "water", elementType: "geometry", stylers: [{ color: "#030d1a" }] },
  { featureType: "water", elementType: "labels.text.fill", stylers: [{ color: "#2244aa" }] },
];

const MAP_CENTER = { lat: 10.8, lng: 108.5 };

interface SubPosition {
  lat: number;
  lng: number;
  depth: number;
  heading: number;
  speed: number;
}

const SUB_ICON_SVG = `
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">
  <ellipse cx="20" cy="22" rx="14" ry="6" fill="#00ffaa" opacity="0.9"/>
  <rect x="16" y="12" width="8" height="10" rx="2" fill="#00cc88"/>
  <circle cx="20" cy="22" r="3" fill="#030d1a"/>
  <circle cx="20" cy="22" r="16" fill="none" stroke="#00ffaa" stroke-width="1" opacity="0.3"/>
</svg>
`;

const SUB_ICON_URL = "data:image/svg+xml;charset=UTF-8," + encodeURIComponent(SUB_ICON_SVG);

interface GpsMapScreenProps {
  lang: Lang;
}

export function GpsMapScreen({ lang }: GpsMapScreenProps) {
  const t = getT(lang);
  const [sub, setSub] = useState<SubPosition>({
    lat: 10.82,
    lng: 108.2,
    depth: -35,
    heading: 60,
    speed: 4.2,
  });
  const [trail, setTrail] = useState<google.maps.LatLngLiteral[]>([
    { lat: 10.70, lng: 107.9 },
    { lat: 10.74, lng: 108.0 },
    { lat: 10.78, lng: 108.1 },
    { lat: 10.82, lng: 108.2 },
  ]);
  const [showInfoWindow, setShowInfoWindow] = useState(false);
  const [mapRef, setMapRef] = useState<google.maps.Map | null>(null);

  const onMapLoad = useCallback((map: google.maps.Map) => {
    setMapRef(map);
  }, []);

  // Animate submarine movement
  useEffect(() => {
    const interval = setInterval(() => {
      setSub((prev) => {
        const rad = (prev.heading * Math.PI) / 180;
        const newLat = prev.lat + Math.cos(rad) * 0.003;
        const newLng = prev.lng + Math.sin(rad) * 0.003;

        // Bounce heading if reaching edge
        let newHeading = prev.heading;
        if (newLat > 12 || newLat < 9) newHeading = (newHeading + 180) % 360;
        if (newLng > 110 || newLng < 106) newHeading = (360 - newHeading + 180) % 360;

        setTrail((t) => {
          const updated = [...t, { lat: newLat, lng: newLng }];
          return updated.slice(-40);
        });

        return { ...prev, lat: newLat, lng: newLng, heading: newHeading };
      });
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const noKey = !GOOGLE_MAPS_API_KEY;

  return (
    <div className="flex flex-col h-full overflow-hidden">
      {/* Info bar */}
      <div className="flex items-center justify-between px-4 py-2 bg-[#0a1628]/70 backdrop-blur-md border-b border-[#00ffaa]/10 flex-shrink-0">
        <div className="flex items-center gap-3">
          <Navigation className="w-4 h-4 text-[#00ffaa]" />
          <div>
            <div className="text-[#00ffaa]" style={{ fontSize: "0.8rem", fontFamily: "monospace" }}>
              {sub.lat.toFixed(4)}°N, {sub.lng.toFixed(4)}°E
            </div>
            <div className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{t.currentPos}</div>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <div className="text-right">
            <div className="text-[#4488ff]" style={{ fontSize: "0.8rem", fontFamily: "monospace" }}>{sub.depth}m</div>
            <div className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{t.depth}</div>
          </div>
          <div className="text-right">
            <div className="text-[#ffaa00]" style={{ fontSize: "0.8rem", fontFamily: "monospace" }}>{sub.heading}°</div>
            <div className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{t.heading}</div>
          </div>
          <div className="text-right">
            <div className="text-[#00ffaa]" style={{ fontSize: "0.8rem", fontFamily: "monospace" }}>{sub.speed.toFixed(1)} kn</div>
            <div className="text-[#8899aa]" style={{ fontSize: "0.65rem" }}>{t.speed}</div>
          </div>
        </div>
      </div>

      {/* Map container */}
      <div className="flex-1 relative">
        {noKey ? (
          <div className="absolute inset-0 flex flex-col items-center justify-center bg-[#030d1a]/80 backdrop-blur-sm">
            <div className="w-16 h-16 rounded-full bg-[#00ffaa]/10 border border-[#00ffaa]/30 flex items-center justify-center mb-4">
              <Compass className="w-8 h-8 text-[#00ffaa]" />
            </div>
            <p className="text-[#00ffaa] mb-2" style={{ fontSize: "0.9rem" }}>Google Maps</p>
            <p className="text-[#8899aa] text-center max-w-xs" style={{ fontSize: "0.8rem" }}>
              {t.mapsApiNote}
            </p>
            <code className="mt-3 px-3 py-1.5 bg-[#0a1628] border border-[#00ffaa]/20 rounded text-[#00ffaa]" style={{ fontSize: "0.75rem" }}>
              VITE_GOOGLE_MAPS_API_KEY=your_key
            </code>
            {/* Mock map background */}
            <div
              className="absolute inset-0 opacity-10 pointer-events-none"
              style={{
                backgroundImage: `
                  linear-gradient(rgba(0,255,170,0.4) 1px, transparent 1px),
                  linear-gradient(90deg, rgba(0,255,170,0.4) 1px, transparent 1px)
                `,
                backgroundSize: "60px 60px",
              }}
            />
          </div>
        ) : (
          <LoadScript googleMapsApiKey={GOOGLE_MAPS_API_KEY} loadingElement={
            <div className="absolute inset-0 flex items-center justify-center bg-[#030d1a]">
              <div className="text-[#00ffaa] animate-pulse" style={{ fontSize: "0.9rem" }}>Loading map...</div>
            </div>
          }>
            <GoogleMap
              mapContainerStyle={{ width: "100%", height: "100%" }}
              center={MAP_CENTER}
              zoom={7}
              onLoad={onMapLoad}
              options={{
                styles: MAP_STYLES,
                disableDefaultUI: false,
                zoomControl: true,
                mapTypeControl: false,
                scaleControl: false,
                streetViewControl: false,
                rotateControl: false,
                fullscreenControl: false,
              }}
            >
              {/* Trail polyline */}
              <Polyline
                path={trail}
                options={{
                  strokeColor: "#4488ff",
                  strokeOpacity: 0.7,
                  strokeWeight: 2,
                  icons: [{ icon: { path: "M 0,-1 0,1", strokeOpacity: 1, scale: 4 }, offset: "0", repeat: "20px" }],
                }}
              />

              {/* Submarine marker */}
              <Marker
                position={{ lat: sub.lat, lng: sub.lng }}
                icon={{ url: SUB_ICON_URL, scaledSize: new window.google.maps.Size(40, 40), anchor: new window.google.maps.Point(20, 20) }}
                onClick={() => setShowInfoWindow(true)}
              />

              {showInfoWindow && (
                <InfoWindow position={{ lat: sub.lat, lng: sub.lng }} onCloseClick={() => setShowInfoWindow(false)}>
                  <div style={{ background: "#0a1628", color: "#00ffaa", padding: "8px", borderRadius: "8px", fontFamily: "monospace", fontSize: "12px" }}>
                    <div style={{ fontWeight: 700, marginBottom: 4 }}>🚢 NAUTICOM SUB-1</div>
                    <div>{sub.lat.toFixed(4)}°N, {sub.lng.toFixed(4)}°E</div>
                    <div>{t.depth}: {sub.depth}m</div>
                    <div>{t.speed}: {sub.speed.toFixed(1)} kn</div>
                    <div>{t.heading}: {sub.heading}°</div>
                  </div>
                </InfoWindow>
              )}
            </GoogleMap>
          </LoadScript>
        )}

        {/* Compass overlay */}
        <div className="absolute top-3 right-3 z-10">
          <div className="w-14 h-14 rounded-full border border-[#00ffaa]/20 bg-[#0a1628]/80 backdrop-blur-sm flex items-center justify-center relative">
            <div className="absolute" style={{ transform: `rotate(${sub.heading}deg)` }}>
              <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
                <div className="w-0.5 h-4 bg-[#00ffaa]" />
                <div className="w-0.5 h-3 bg-[#8899aa]" />
              </div>
            </div>
            <span className="absolute top-0.5 left-1/2 -translate-x-1/2 text-[#00ffaa]" style={{ fontSize: "0.5rem" }}>N</span>
            <span className="absolute bottom-0.5 left-1/2 -translate-x-1/2 text-[#8899aa]" style={{ fontSize: "0.5rem" }}>S</span>
            <span className="absolute left-0.5 top-1/2 -translate-y-1/2 text-[#8899aa]" style={{ fontSize: "0.5rem" }}>W</span>
            <span className="absolute right-0.5 top-1/2 -translate-y-1/2 text-[#8899aa]" style={{ fontSize: "0.5rem" }}>E</span>
          </div>
        </div>

        {/* Live status pill */}
        <div className="absolute bottom-3 left-3 z-10">
          <div className="flex items-center gap-2 px-3 py-1.5 bg-[#0a1628]/80 backdrop-blur-sm border border-[#00ffaa]/20 rounded-full">
            <div className="w-1.5 h-1.5 rounded-full bg-[#00ffaa] animate-pulse" />
            <span className="text-[#00ffaa]" style={{ fontSize: "0.65rem", letterSpacing: "0.1em" }}>
              {lang === "vi" ? "ĐANG THEO DÕI" : "TRACKING LIVE"}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
