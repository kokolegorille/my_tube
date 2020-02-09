defmodule MyTubeWeb.Helpers.BootstrapHelper do
  @moduledoc """
  This is the documentation for the Bootstrap 4 helpers.
  It includes also fa helper, for Font awesome
  """
  use Phoenix.HTML
  alias MyTubeWeb.{BootstrapView, ErrorHelpers}

  @doc """
  Font Awesome helper
  """
  def fa(icon), do: content_tag(:i, nil, class: "fa fa-#{icon}")

  @doc """
  Definition helper
  """
  def definition(key, values, opts \\ [])
  def definition(key, values, opts) when is_list(values) do
    [content_tag(:dt, key)] ++ Enum.map(values, fn value ->
      content_tag(:dd, value, opts)
    end)
  end
  def definition(key, nil, opts),
    do: [content_tag(:dt, key), content_tag(:dd, raw("&nbsp;"), opts)]
  def definition(key, value, opts),
    do: [content_tag(:dt, key), content_tag(:dd, value, opts)]

  @doc """
  Flash helper
  """
  def flash(nil, _mode) do
    # noop
  end

  def flash(message, mode) do
    class = "alert alert-#{mode} alert-dismissible fade show"
    content_tag(:div, class: class, role: "alert") do
      [
        message,
        content_tag(:button, type: :button, class: :close, "data-dismiss": :alert, "aria-label": "Close") do
          content_tag(:span) do
            raw("&times;")
          end
        end
      ]
    end
  end

  @doc """
  Breadcrumb
  """
  def breadcrumb(list, renderer, opts \\ []) do
    first = opts[:first]
    right = opts[:right]
    # When the element is lat, set the field to call on the element
    field = opts[:field] || :title
    len = length(list)
    content_tag(:nav, "aria-label": "breadcrumb") do
      content_tag(:ol, class: "breadcrumb") do
        links = list
        |> Enum.with_index()
        |> Enum.map(fn {element, index} ->
          is_last? = index >= (len - 1)
          class = if is_last?, do: "breadcrumb-item active", else: "breadcrumb-item"
          content_tag(:li, class: class) do
            if is_last?,
              do: Map.fetch!(element, field),
              else: renderer.(element)
          end
        end)

        links = if first, do: [content_tag(:li, first, class: "breadcrumb-item") | links], else: links
        if right, do: links ++ [content_tag(:li, right, class: "breadcrumb-item ml-auto")], else: links
      end
    end
  end

  @doc """
  Dropdown helper
  """
  def dropdown(options \\ []) do
    options = Keyword.merge(options, wrapper_class: "dropdown")
    render("dropdown.html", options)
  end

  @doc """
  Left dropdown helper
  """
  def dropleft(options \\ []) do
    options = Keyword.merge(options, wrapper_class: "dropdown dropleft")
    render("dropdown.html", options)
  end

  @doc """
  Right dropdown helper
  """
  def dropright(options \\ []) do
    options = Keyword.merge(options, wrapper_class: "dropdown dropright")
    render("dropdown.html", options)
  end

  @doc """
  Up dropdown helper
  """
  def dropup(options \\ []) do
    options = Keyword.merge(options, wrapper_class: "dropdown dropup")
    render("dropdown.html", options)
  end

  @doc """
  Langswitch helper
  """
  def langswitch(params), do: render("langswitch.html", params)

  @doc """
  Navbar helper
  """
  def navbar(conn, links), do: render("navbar.html", conn: conn, links: links)

  @doc """
  Navbar helper, with links to be placed on the right
  """
  def navbar(conn, links, right_links),
    do: render("navbar.html", conn: conn, links: links, right_links: right_links)

  @doc """
  is_active helper for navbar
  It will check if the current link is active.
  It does receive a html safe from link helper.
  You need to decode and check...
  It returns "active" | nil
  """
  def active_class(conn, {:safe, iodata} = _link) do
    string = IO.iodata_to_binary(iodata)
    regex = ~r/.*href=\"(?<href>.*)\".*/

    with %{"href" => href} <- Regex.named_captures(regex, string),
      true <- href == Path.join(["/" | conn.path_info])
    do
      "active"
    else
      _ -> nil
    end
  end
  def active_class(_conn, _link), do: nil

  @doc """
  Form Input helper
  http://blog.plataformatec.com.br/2016/09/dynamic-forms-with-phoenix/

  ## Options

    * `:using` - set the field type, eg: using: :textarea.
    * `:html_opts` - additional input opts, eg: html_opts: [rows: 10].
    * `:error` - set asdditional error field, eg: title and slug.

  ### For select

    * `:options` - the list of options for a select input.

  """
  def input(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)
    error_field = opts[:error] || field

    do_input(type, error_field, form, field, opts)
  end

  # CHECKBOX
  defp do_input(:checkbox = type, error_field, form, field, opts) do
    error = get_error(error_field, form, field)
    html_opts = opts[:html_opts] || []
    label_txt = opts[:label] || humanize(field)

    wrapper_opts = [class: "form-group form-check"]
    label_opts = [class: "form-check-label"]
    input_opts = html_opts ++
      [class: "form-check-input #{state_class(form, field, error_field)}"]

    content_tag :div, wrapper_opts do
      label = label(form, field, label_txt, label_opts)
      input = input(type, form, field, input_opts)
      error = error
      [input, label, error]
    end
  end

  # FILE INPUT
  defp do_input(:file_input = type, error_field, form, field, opts) do
    error = get_error(error_field, form, field)
    html_opts = opts[:html_opts] || []
    label_txt = opts[:label] || humanize(field)

    # Add some margin at the bottom of wrapper!
    wrapper_opts = [class: "custom-file mb-4"]
    label_opts = [class: "custom-file-label"]
    input_opts = html_opts ++
      [class: "custom-file-input #{state_class(form, field, error_field)}"]

    content_tag :div, wrapper_opts do
      label = label(form, field, label_txt, label_opts)
      input = input(type, form, field, input_opts)

      # Custom, check if previous attachment exists!
      previous = display_current_attachment(form.data, field)

      error = error
      [label, input, previous, error]
    end
  end

  # SELECT
  defp do_input(:select = type, error_field, form, field, opts) do
    error = get_error(error_field, form, field)
    html_opts = opts[:html_opts] || []
    options = opts[:options] || []
    label_txt = opts[:label] || humanize(field)

    wrapper_opts = [class: "form-group"]
    label_opts = [class: "control-label"]
    input_opts = html_opts ++
      [class: "form-control #{state_class(form, field, error_field)}"]

    content_tag :div, wrapper_opts do
      label = label(form, field, label_txt, label_opts)
      input = input(type, form, field, options, input_opts)
      error = error
      [label, input, error]
    end
  end

  # DEFAULT
  defp do_input(type, error_field, form, field, opts) do
    error = get_error(error_field, form, field)
    html_opts = opts[:html_opts] || []
    label_txt = opts[:label] || humanize(field)

    wrapper_opts = [class: "form-group"]
    label_opts = [class: "control-label"]
    input_opts = html_opts ++
      [class: "form-control #{state_class(form, field, error_field)}"]

    content_tag :div, wrapper_opts do
      label = label(form, field, label_txt, label_opts)
      input = input(type, form, field, input_opts)
      error = error
      [label, input, error]
    end
  end

  # Helpers

  # Display previous file name for file input
  defp display_current_attachment(source, field) do
    attachment = Map.get(source, field)
    if attachment do
      content_tag(:small, "Current File : #{attachment.file_name}", class: "form-text text-muted")
    else
      # Should not returns nil! This is included in a content tag
      ""
    end
  end

  defp state_class(form, field, error_field) when field == error_field do
    cond do
      # The form was not yet submitted, or the source is not a changeset
      is_nil(Map.get(form.source, :action)) -> ""
      form.errors[field] -> "is-invalid"
      true -> "is-valid"
    end
  end

  # Check for multiple errors
  defp state_class(form, field, error_field) do
    cond do
      # The form was not yet submitted, or the source is not a changeset
      is_nil(Map.get(form.source, :action)) -> ""
      form.errors[field] -> "is-invalid"
      form.errors[error_field] -> "is-invalid"
      true -> "is-valid"
    end
  end

  defp get_error(error_field, form, field) do
    case error_field == field do
      true ->
        ErrorHelpers.error_tag(form, error_field)
      _ ->
        [error_field, field]
        |> Enum.flat_map(fn f ->
          ErrorHelpers.error_tag(form, f)
        end)
    end
  end

  # Implement clauses below for custom inputs.
  # defp input(:datepicker, form, field, input_opts) do
  #   raise "not yet implemented"
  # end

  defp input(type, form, field, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, input_opts])
  end

  # For select
  defp input(type, form, field, options, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, options, input_opts])
  end

  ########################################
  ### HELPERS
  ########################################

  defp render(template, params),
    do: BootstrapView.render(template, params)
end
