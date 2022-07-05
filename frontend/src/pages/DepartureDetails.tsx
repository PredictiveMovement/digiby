import { useState } from 'react';
import { useAtom } from 'jotai';
import StaticMap from 'react-map-gl';
import DeckGL, { GeoJsonLayer, IconLayer } from 'deck.gl';

import pin from '../icons/pin.svg';
import { departuresDetails } from '../utils/atoms';
import DepartureInfo from '../components/DepartureInfo';

const DeparturesDetails = () => {
  const [mapState, setMapState] = useState({
    longitude: 20.15199,
    latitude: 66.54386,
    zoom: 7,
    pitch: 0,
    bearing: 0,
  });
  const [departure] = useAtom(departuresDetails);

  if (!departure) {
    return <p> no departure found </p>;
  }

  const geoJsonObject = {
    type: 'Feature',
    geometry: {
      type: 'LineString',
      coordinates: departure?.geometry,
    },
  };

  const layer = new GeoJsonLayer({
    id: 'geojson-layer',
    data: geoJsonObject,
    pickable: true,
    stroked: false,
    filled: true,
    extruded: true,
    pointType: 'circle',
    lineWidthScale: 5,
    lineWidthMinPixels: 2,
    getFillColor: [19, 197, 123],
    getLineColor: [19, 197, 123],
    getPointRadius: 100,
    getLineWidth: 5,
    getElevation: 3,
  });

  const stopPosition = departure?.stops.slice(-1)[0].stop_position;

  const iconLayer = new IconLayer({
    id: 'icon-layer',
    data: [
      {
        coordinates: [
          parseFloat(stopPosition.lng),
          parseFloat(stopPosition.lat),
        ],
      },
    ],
    pickable: true,
    getIcon: () => ({
      url: pin,
      mask: false,
      width: 16,
      height: 20,
    }),
    sizeScale: 1,
    getPosition: (d) => d.coordinates,
    getSize: (d) => 20,
  });

  return (
    <>
      {departure && (
        <>
          <DeckGL
            layers={[iconLayer, layer]}
            initialViewState={mapState}
            controller={true}
          >
            <StaticMap
              mapboxAccessToken={import.meta.env.VITE_MAPBOX_ACCESS_TOKEN}
              reuseMaps
              mapStyle="mapbox://styles/mapbox/dark-v10"
            />
          </DeckGL>
          <DepartureInfo departure={departure} />
        </>
      )}
    </>
  );
};

export default DeparturesDetails;
