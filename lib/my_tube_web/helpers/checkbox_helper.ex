defmodule MyTubeWeb.Helpers.CheckboxHelper do
  @moduledoc """
  This is the documentation for the Checkbox helpers.
  """

  use Phoenix.HTML

  @doc """
  Renders multiple checkboxes.

  ref: https://dev.to/ricardoruwer/many-to-many-associations-in-elixir-and-phoenix-21pm

  ## Example

      iex> multiselect_checkboxes(
             f,
             :amenities,
             Enum.map(@amenities, fn c -> { c.name, c.id } end),
             selected: Enum.map(@changeset.data.amenities,&(&1.id))
           )
      <div class="checkbox">
        <label>
          <input name="property[amenities][]" id="property_amenities_1" type="checkbox" value="1" checked>
          <input name="property[amenities][]" id="property_amenities_2" type="checkbox" value="2">
        </label>
      </div
  """

  # GENERIC VERSION
  #
  # def multiselect_checkboxes(form, field, options, opts \\ []) do
  #   {selected, _} = get_selected_values(form, field, opts)
  #   selected_as_strings = Enum.map(selected, &"#{&1}")

  #   for {value, key} <- options, into: [] do
  #     content_tag(:label, class: "checkbox-inline") do
  #       [
  #         tag(:input,
  #           name: input_name(form, field) <> "[]",
  #           id: input_id(form, field, key),
  #           type: "checkbox",
  #           value: key,
  #           checked: Enum.member?(selected_as_strings, "#{key}")
  #         ),
  #         value
  #       ]
  #     end
  #   end
  # end

  # BOOTSTRAP 4 VERSION
  #
  def multiselect_checkboxes(form, field, options, opts \\ []) do
    {selected, _} = get_selected_values(form, field, opts)
    selected_as_strings = Enum.map(selected, &"#{&1}")

    # Use inline mode by default
    class = opts[:class] || "form-check form-check-inline"
    # By default, input is active (not disabled)
    disabled = opts[:disabled]

    for {value, key} <- options, into: [] do
      id = input_id(form, field, key)
      content_tag(:div, class: class) do
        [
          tag(:input,
            name: input_name(form, field) <> "[]",
            id: id,
            class: "form-check-input",
            type: "checkbox",
            value: key,
            checked: Enum.member?(selected_as_strings, "#{key}"),
            disabled: disabled
          ),
          content_tag(:label, value, class: "form-check-label", for: id)
        ]
      end
    end
  end

  defp get_selected_values(form, field, opts) do
    {selected, opts} = Keyword.pop(opts, :selected)
    param = field_to_string(field)

    case form do
      %{params: %{^param => sent}} ->
        {sent, opts}

      _ ->
        {selected || input_value(form, field), opts}
    end
  end

  defp field_to_string(field) when is_atom(field), do: Atom.to_string(field)
  defp field_to_string(field) when is_binary(field), do: field
end
