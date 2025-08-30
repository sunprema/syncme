defmodule SyncMeWeb.PartnerLive.Component do
  use Phoenix.Component
  import SyncMeWeb.CoreComponents

  def partner_bookings(assigns) do

    ~H"""
    <.header>Partner Bookings</.header>
    """
  end

  def partner_event_types(assigns) do

    ~H"""
    <.header>Event Types </.header>
    """
  end

  def partner_availability(assigns) do

    ~H"""
    <.header>Partner Availability</.header>
    """
  end



  def partner_insights(assigns) do

    ~H"""
    <.header>Partner Insights</.header>
    """
  end

  def partner_settings(assigns) do

    ~H"""
    <.header>Partner Settings</.header>
    """
  end


end
