defmodule PhilomenaWeb.AppView do
  use Phoenix.HTML

  @time_strings %{
    seconds: "hace menos de un minuto",
    minute: "hace un minuto",
    minutes: "hace %d minutos",
    hour: "hace una hora",
    hours: "hace %d horas",
    day: "hace un día",
    days: "hace %d dias",
    month: "hace un mes",
    months: "hace %d meses",
    year: "hace un año",
    years: "hace %d años"
  }

  @months %{
    1 => "Enero",
    2 => "Febrero",
    3 => "Marzo",
    4 => "Abril",
    5 => "Mayo",
    6 => "Junio",
    7 => "Julio",
    8 => "Agosto",
    9 => "Septiembre",
    10 => "Octubre",
    11 => "Noviembre",
    12 => "Diciembre"
  }

  def pretty_time(time) do
    now = NaiveDateTime.utc_now()
    seconds = NaiveDateTime.diff(now, time, :second)
    relation = if seconds < 0, do: "from now", else: ""
    time = time |> DateTime.from_naive!("Etc/UTC")

    words = distance_of_time_in_words(now, time)

    content_tag(:time, "#{words} #{relation}",
      datetime: DateTime.to_iso8601(time),
      title: datetime_string(time)
    )
  end

  def distance_of_time_in_words(time_2, time_1) do
    seconds = abs(NaiveDateTime.diff(time_2, time_1, :second))
    minutes = div(seconds, 60)
    hours = div(minutes, 60)
    days = div(hours, 24)
    months = div(days, 30)
    years = div(days, 365)

    cond do
      seconds < 45 -> String.replace(@time_strings[:seconds], "%d", to_string(seconds))
      seconds < 90 -> String.replace(@time_strings[:minute], "%d", to_string(1))
      minutes < 45 -> String.replace(@time_strings[:minutes], "%d", to_string(minutes))
      minutes < 90 -> String.replace(@time_strings[:hour], "%d", to_string(1))
      hours < 24 -> String.replace(@time_strings[:hours], "%d", to_string(hours))
      hours < 42 -> String.replace(@time_strings[:day], "%d", to_string(1))
      days < 30 -> String.replace(@time_strings[:days], "%d", to_string(days))
      days < 45 -> String.replace(@time_strings[:month], "%d", to_string(1))
      days < 365 -> String.replace(@time_strings[:months], "%d", to_string(months))
      days < 548 -> String.replace(@time_strings[:year], "%d", to_string(1))
      true -> String.replace(@time_strings[:years], "%d", to_string(years))
    end
  end

  def can?(conn, action, model) do
    Canada.Can.can?(conn.assigns.current_user, action, model)
  end

  def map_join(enumerable, joiner, map_fn) do
    enumerable
    |> Enum.map(map_fn)
    |> Enum.intersperse(joiner)
  end

  def number_with_delimiter(nil), do: "0"

  def number_with_delimiter(number) do
    number
    |> to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(&Enum.reverse(&1))
    |> Enum.reverse()
    |> Enum.join(",")
  end

  def pluralize(singular, plural, count) do
    if count == 1 do
      singular
    else
      plural
    end
  end

  def button_to(text, route, args \\ []) do
    method = Keyword.get(args, :method, "get")
    class = Keyword.get(args, :class, nil)
    data = Keyword.get(args, :data, [])

    form_for(nil, route, [method: method, class: "button_to"], fn _f ->
      submit(text, class: class, data: data)
    end)
  end

  def escape_nl2br(nil), do: nil

  def escape_nl2br(text) do
    text
    |> String.split("\n")
    |> Enum.map(&html_escape/1)
    |> Enum.map(&safe_to_string/1)
    |> Enum.join("<br/>")
    |> raw()
  end

  defp datetime_string(time) do
    :io_lib.format("~2..0B:~2..0B:~2..0B, ~s ~B, ~B", [
      time.hour,
      time.minute,
      time.second,
      @months[time.month],
      time.day,
      time.year
    ])
    |> to_string()
  end

  def link_to_ip(_conn, nil), do: content_tag(:code, "null")

  def link_to_ip(_conn, ip) do
    link(to: "/ip_profiles/#{ip}") do
      [
        content_tag(:i, "", class: "fas fa-network-wired"),
        " ",
        to_string(ip)
      ]
    end
  end

  def link_to_fingerprint(_conn, nil), do: content_tag(:code, "null")

  def link_to_fingerprint(_conn, fp) do
    link(to: "/fingerprint_profiles/#{fp}") do
      [
        content_tag(:i, "", class: "fas fa-desktop"),
        " ",
        String.slice(fp, 0..6)
      ]
    end
  end

  def communication_body_class(%{destroyed_content: true}), do: "communication--destroyed"
  def communication_body_class(_communication), do: nil

  def hide_staff_tools?(conn),
    do: conn.cookies["hide_staff_tools"] == "true"

  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?([]), do: true
  def blank?(map) when is_map(map), do: map == %{}
  def blank?(str) when is_binary(str), do: String.trim(str) == ""
  def blank?(_object), do: false

  def present?(object), do: not blank?(object)
end
