export type Address = {
  coordinates: [lon: number, lat: number];
  address: string;
};

export type FormattedState = {
  from: Address;
  to: Address;
  time: string;
  date: string;
};

export type FormData = {
  from: Address;
  to: Address;
  date: Date;
};

type StopPosition = {
  lat: string;
  lng: string;
  name: string;
};

type Travelinfo = {
  arrival_time: string;
  meters_from_query_to_stop: number;
  stop_position: StopPosition;
};

type Stop = {
  arrival_time: string;
  stop_position: StopPosition;
};

type LatLng = [number, number];

export type Departure = {
  date: string;
  cost: number;
  departure: Travelinfo;
  destination: Travelinfo;
  line_number: string;
  stops: Stop[];
  transportation_type: string;
  travel_time: number;
  geometry: LatLng[];
};

export type DepartureSearchParams = {
  fromLat: string;
  fromLng: string;
  toLat: string;
  toLng: string;
  time: string;
  date: string;
};
