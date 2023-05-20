defmodule DigistabStoreWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML
  import DigistabStoreWeb.Gettext

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "cm-invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(MyAppWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MyAppWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  def error_to_string(:too_large), do: dgettext("errors", "File too large")
  def error_to_string(:not_accepted), do: dgettext("errors", "Format not accepted")

  def error_to_string(:too_many_files),
    do:
      dgettext(
        "errors",
        "You have selected too many files, please, cancel the excedent to continue."
      )

  def error_to_string(:external_client_failure), do: dgettext("errors", "Failed to upload")

  def error_to_string(something) do
    IO.inspect(something, label: "label")
    dgettext("errors", "Failed to upload")
  end
end
