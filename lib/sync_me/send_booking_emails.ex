defmodule SyncMe.Workers.SendBookingEmails do
  use Oban.Worker, queue: :default

  alias SyncMe.Repo
  alias SyncMe.Bookings.Booking
  alias SyncMe.Calendar.ICS
  alias SyncMe.Google.Meet
  alias SyncMe.BookingMailer

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"booking_id" => booking_id}}) do
    booking =
      Repo.get!(Booking, booking_id)
      |> Repo.preload([:event_type, :guest_user, partner: :user])

    booking =
      case Meet.create_event(booking) do
        {:ok, meet_link} ->
          IO.inspect("Meeting link #{meet_link}",
            label: "Generated google meet link successfully"
          )

          changeset = Booking.changeset(booking, %{video_conference_link: meet_link})
          {:ok, updated_booking} = Repo.update(changeset)
          # Preload associations again on the updated struct
          Repo.preload(updated_booking, [:event_type, :guest_user, partner: :user])

        {:error, reason} ->
          # Handle error: maybe retry the job or log it.
          # For now, we proceed without a link.
          IO.inspect("#{inspect(reason)}", label: "Inside Oban email sending job")
          booking
      end

    ics_content = ICS.generate(booking)
    guest = booking.guest_user
    partner = booking.partner

    # Email to Guest
    BookingMailer.booking_confirmation_email(booking, guest.email, guest.first_name, ics_content)
    |> BookingMailer.deliver()

    # Email to Partner
    BookingMailer.booking_confirmation_email(
      booking,
      partner.user.email,
      partner.user.first_name,
      ics_content
    )
    |> BookingMailer.deliver()

    :ok
  end
end
