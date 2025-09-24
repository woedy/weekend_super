import React, { useEffect, useRef } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

const StoreIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="w-5 h-5">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h18v18H3zM3 9h18M9 21V9" />
  </svg>
);

const PinIcon = () => (
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="w-5 h-5">
    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 21s-8-4.5-8-11.8A8 8 0 0112 2a8 8 0 018 7.2c0 7.3-8 11.8-8 11.8z" />
    <circle cx="12" cy="9" r="3" strokeWidth={2} />
  </svg>
);

const LocationMap = ({ kitchenLocation, deviceLocation, mapboxToken }) => {
  const mapContainer = useRef(null);
  const map = useRef(null);

  useEffect(() => {
    if (map.current) return;

    mapboxgl.accessToken = mapboxToken;
    map.current = new mapboxgl.Map({
      container: mapContainer.current,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [kitchenLocation.lng, kitchenLocation.lat],
      zoom: 13
    });

    // Add kitchen marker
    const kitchenEl = document.createElement('div');
    kitchenEl.className = 'kitchen-marker';
    kitchenEl.innerHTML = `<div class="text-blue-600">${StoreIcon().props.children}</div>`;
    new mapboxgl.Marker(kitchenEl)
      .setLngLat([kitchenLocation.lng, kitchenLocation.lat])
      .setPopup(new mapboxgl.Popup().setHTML('Kitchen Location'))
      .addTo(map.current);

    // Add device marker
    const deviceEl = document.createElement('div');
    deviceEl.className = 'device-marker';
    deviceEl.innerHTML = `<div class="text-red-500">${PinIcon().props.children}</div>`;
    new mapboxgl.Marker(deviceEl)
      .setLngLat([deviceLocation.lng, deviceLocation.lat])
      .setPopup(new mapboxgl.Popup().setHTML('Current Location'))
      .addTo(map.current);

    // Cleanup
    return () => map.current.remove();
  }, [kitchenLocation, deviceLocation, mapboxToken]);

  return (
    <div className="w-full h-96 bg-gray-100 rounded-lg relative overflow-hidden">
      <div ref={mapContainer} className="w-full h-full" />
      
      {/* Legend */}
      <div className="absolute bottom-4 left-4 bg-white p-3 rounded-lg shadow-md">
        <div className="flex items-center space-x-4">
          <div className="flex items-center space-x-2">
            <span className="text-blue-600"><StoreIcon /></span>
            <span className="text-sm">Kitchen</span>
          </div>
          <div className="flex items-center space-x-2">
            <span className="text-red-500"><PinIcon /></span>
            <span className="text-sm">Current Location</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LocationMap;