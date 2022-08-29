defmodule Digiby.Adapters.Samakning do
  def get_transports(_date) do
    generate_transports(10)
  end

  def generate_transports(amount) do
    Enum.map(1..amount, fn _ ->
      time_offset = Enum.random(1..20)
      start_time = Time.from_iso8601!("06:50:00Z") |> Time.add(time_offset * 60)
      stop_time = start_time |> Time.add(60 * 60)

      from = %{
        arrival_time: Calendar.strftime(start_time, "%H:%M:%S"),
        stop_position: random(%{lat: 66.429942, lng: 20.604759})
      }

      to = %{
        arrival_time: Calendar.strftime(stop_time, "%H:%M:%S"),
        stop_position: random(%{lat: 66.082736, lng: 20.961049})
      }

      %{
        id: generate_id,
        cost: 200,
        stops: [from, to],
        departure: from,
        destination: to,
        departure_time: start_time
      }
    end)
  end

  defp generate_id() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end

  def random(%{lng: lon, lat: lat}) do
    lon = lon + (Enum.random(0..100) - 50) / 200
    lat = lat + (Enum.random(0..100) - 50) / 500

    %{"lng" => lon, "lat" => lat}
  end
end
