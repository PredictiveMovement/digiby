defmodule Digiby.Fardtjanst do
  alias Digiby.Transport
  @maximum_walking_distance 2500
  # Travel time in seconds
  @max_extra_travel_time_for_fardtjanst 360

  def filter_trips_too_far_from_original_trip(
        %{
          "from_position" => %{"lat" => depLat, "lng" => depLng},
          "to_position" => %{"lat" => destLat, "lng" => destLng}
        },
        _,
        _
      )
      when is_nil(depLat) or is_nil(depLng) or is_nil(destLat) or
             is_nil(destLng),
      do: false

  def filter_trips_too_far_from_original_trip(
        %{
          "from_position" => departure,
          "to_position" => destination
        },
        query_from_position,
        query_to_position
      ) do
    {query_to_lng, query_to_lat} = query_to_position
    {query_from_lng, query_from_lat} = query_from_position

    extra_time_to_pickup_passenger =
      [
        [departure, destination],
        [
          departure,
          %{"lat" => query_from_lat, "lng" => query_from_lng},
          %{"lat" => query_to_lat, "lng" => query_to_lng},
          destination
        ]
      ]
      |> Enum.map(&Osrm.get_duration/1)
      |> Enum.reduce(0, fn duration, before_duration ->
        duration - before_duration
      end)

    extra_time_to_pickup_passenger < @max_extra_travel_time_for_fardtjanst
  end

  def list_transports(date, options) do
    start_time = Keyword.get(options, :start_time, ~T[00:00:00])

    query_from_position = Keyword.get(options, :from)
    query_to_position = Keyword.get(options, :to)
    end_time = Keyword.get(options, :end_time, ~T[23:59:59])
    {_year, month, day} = Date.to_erl(date)

    # pretend it's 2019 to match with data
    new_date = Date.from_erl!({2019, month, day})

    Digiby.Adapters.Fardtjanst.get_transports(Date.to_string(new_date))
    |> Flow.from_enumerable()
    |> Flow.partition(stages: 200)
    |> Flow.filter(
      &filter_trips_too_far_from_original_trip(&1, query_from_position, query_to_position)
    )
    |> Flow.map(fn %{
                     "type" => type,
                     "car_type" => car_type,
                     "departure_time" => departure_time,
                     "id" => id
                   } ->
      {query_from_lng, query_from_lat} = query_from_position
      {query_to_lng, query_to_lat} = query_to_position

      from_stop_position =
        Map.put(%{"lat" => query_from_lat, "lng" => query_from_lng}, :name, "Min position")

      to_stop_position =
        Map.put(%{"lat" => query_to_lat, "lng" => query_to_lng}, :name, "Destination")

      first_stop =
        Map.new()
        # arrival_time should be departure_time + what it takes to get there
        |> Map.put(:arrival_time, Time.from_iso8601!(departure_time))
        |> Map.put(:stop_position, from_stop_position)

      %{"duration" => duration, "geometry" => geometry} =
        Osrm.route(from_stop_position, to_stop_position)

      last_stop =
        Map.new()
        |> Map.put(:stop_position, to_stop_position)
        |> Map.put_new(
          :arrival_time,
          Time.from_iso8601!(departure_time)
          |> Time.add(round(duration))
        )

      %{
        id: id,
        type: type,
        car_type: car_type,
        start_stop:
          first_stop
          |> Map.put(
            :meters_from_query_to_stop,
            get_meters_between_positions(first_stop.stop_position, query_from_position)
          ),
        last_stop:
          last_stop
          |> Map.put(
            :meters_from_query_to_stop,
            get_meters_between_positions(last_stop.stop_position, query_to_position)
          ),
        stop_times: [first_stop, last_stop],
        travel_time: duration,
        geometry: Map.get(geometry, "coordinates")
      }
    end)
    |> Enum.filter(fn %{start_stop: departure} ->
      Time.compare(departure.arrival_time, start_time) == :gt
    end)
    |> Enum.map(&fardtjanst_to_transport_struct/1)
  end

  defp car_type_to_readable("AN"), do: "Personbil"
  defp car_type_to_readable("S1"), do: "Specialfordon"

  defp fardtjanst_to_transport_struct(
         %{
           start_stop: start_stop,
           last_stop: last_stop,
           geometry: geometry,
           travel_time: travel_time
         } = trip
       ),
       do: %Transport{
         id: trip.id,
         line_number: nil,
         agency: "Länstrafiken Norrbotten",
         vehicle_type: car_type_to_readable(trip.car_type),
         transportation_type: trip.type,
         travel_time: travel_time,
         cost: 900_000,
         departure: start_stop,
         destination: last_stop,
         stops: trip.stop_times,
         geometry: geometry
       }

  defp get_meters_between_positions(%{"lat" => lat1, "lng" => lng1}, pos2) do
    Distance.GreatCircle.distance(
      {lng1, lat1},
      pos2
    )
  end
end
