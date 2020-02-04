# https://phraseapp.com/blog/posts/i18n-for-phoenix-applications-with-gettext/
# https://phraseapp.com/blog/posts/set-and-manage-locale-data-in-your-phoenix-l10n-project/

defmodule MyTubeWeb.Plugs.Locale do
  @moduledoc false
  import Plug.Conn

  @locales Gettext.known_locales(MyTubeWeb.Gettext)

  def init(opts), do: opts

  def call(conn, _opts) do
    case locale_from_params(conn) || locale_from_cookies(conn) || locale_from_session(conn) ||
           locale_from_header(conn) do
      nil ->
        conn

      locale ->
        Gettext.put_locale(MyTubeWeb.Gettext, locale)

        conn
        |> persist_locale(locale)
    end
  end

  # private

  defp locale_from_params(conn) do
    conn.params["locale"] |> validate_locale
  end

  defp locale_from_cookies(conn) do
    conn.cookies["locale"] |> validate_locale
  end

  defp locale_from_session(conn) do
    conn
    |> get_session(:locale)
    |> validate_locale
  end

  defp validate_locale(locale) when locale in @locales, do: locale
  defp validate_locale(_locale), do: nil

  defp persist_locale(conn, new_locale) do
    conn
    |> persist_cookie(new_locale)
    |> persist_session(new_locale)
  end

  defp persist_cookie(conn, new_locale) do
    if conn.cookies["locale"] != new_locale do
      conn
      |> put_resp_cookie("locale", new_locale, max_age: 10 * 24 * 60 * 60)
    else
      conn
    end
  end

  defp persist_session(conn, new_locale) do
    if get_session(conn, :locale) != new_locale do
      conn
      |> put_session(:locale, new_locale)
    else
      conn
    end
  end

  # Taken from set_locale plug written by Gerard de Brieder
  # https://github.com/smeevil/set_locale/blob/fd35624e25d79d61e70742e42ade955e5ff857b8/lib/headers.ex
  defp locale_from_header(conn) do
    conn
    |> extract_accept_language
    |> Enum.find(nil, fn accepted_locale -> Enum.member?(@locales, accepted_locale) end)
  end

  def extract_accept_language(conn) do
    case Plug.Conn.get_req_header(conn, "accept-language") do
      [value | _] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(& &1.tag)
        |> Enum.reject(&is_nil/1)
        |> ensure_language_fallbacks()

      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = Regex.named_captures(~r/^\s?(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i, string)

    quality =
      case Float.parse(captures["quality"] || "1.0") do
        {val, _} -> val
        _ -> 1.0
      end

    %{tag: captures["tag"], quality: quality}
  end

  defp ensure_language_fallbacks(tags) do
    Enum.flat_map(tags, fn tag ->
      [language | _] = String.split(tag, "-")
      if Enum.member?(tags, language), do: [tag], else: [tag, language]
    end)
  end
end
