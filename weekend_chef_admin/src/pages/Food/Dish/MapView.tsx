import { useState, useRef } from 'react';
import Breadcrumb from '../../../components/Breadcrumbs/Breadcrumb';
import MapGL, { Marker } from 'react-map-gl';

const MapView = () => {
  const mapRef = useRef(null);

  // Sample data: List of chef kitchen locations
  const kitchenLocations = [
    { id: 1, name: 'Chef Kitchen 1', latitude: 8.6, longitude: -3.9 },
    { id: 2, name: 'Chef Kitchen 2', latitude: 8.8, longitude: -4.0 },
    { id: 3, name: 'Chef Kitchen 3', latitude: 8.7, longitude: -3.8 },
  ];

  // State to keep track of selected location
  const [selectedLocation, setSelectedLocation] = useState(null);

  // Handler to select a location and zoom in on the map
  const handleMarkerClick = (location) => {
    setSelectedLocation(location);
    mapRef.current?.flyTo({
      center: [location.longitude, location.latitude],
      zoom: 12,
      speed: 1.2,
    });
  };

  return (
    <div>
      <Breadcrumb pageName="Dish / Details" />

      <div className="grid grid-cols-3 gap-2">
        <div className="col-span-2 rounded-sm border h-[400px] border-stroke shadow-default dark:border-strokedark dark:bg-boxdark">
          {/* Here we add the map */}
          <MapGL
            ref={mapRef}
            mapboxAccessToken="pk.eyJ1IjoiZGVsYWRlbS1waW5nc2hpcCIsImEiOiJjbTVwNGtuYnowcjUzMmlzOHYxcXd5YWkxIn0.nKSC4i5LZk2_QT0xh-WQSg"
            initialViewState={{
              longitude: -3.9,
              latitude: 8.6,
              zoom: 6,
            }}
            style={{ width: '100%', height: '100%' }}
            mapStyle="mapbox://styles/deladem-pingship/cluv4uiay004y01p5b7es8xp0"
          >
            {/* Render a Marker for each kitchen location */}
            {kitchenLocations.map((location) => (
              <Marker
                key={location.id}
                latitude={location.latitude}
                longitude={location.longitude}
              >
                <button
                  onClick={() => handleMarkerClick(location)}
                  className="bg-blue-500 text-white p-2 rounded-full shadow-md"
                  title={`Click to view ${location.name}`}
                >
                  <span>🍴</span> {/* You can use an icon here */}
                </button>
              </Marker>
            ))}
          </MapGL>
        </div>

        {/* Right panel displaying the list of kitchen locations */}
        <div className="bg-white dark:bg-boxdark rounded-sm p-4">
          <h3 className="font-bold mb-4">Chef Kitchens</h3>
          <ul>
            {kitchenLocations.map((location) => (
              <li
                key={location.id}
                className={`cursor-pointer ${selectedLocation?.id === location.id ? 'text-blue-500' : ''}`}
                onClick={() => handleMarkerClick(location)}
              >
                {location.name}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
};

export default MapView;
