defmodule SyncMeWeb.PrivacyAndTOSHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use SyncMeWeb, :html

  embed_templates "privacy_tos_html/*"
end
