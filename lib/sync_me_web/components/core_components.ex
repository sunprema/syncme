defmodule SyncMeWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as tables, forms, and
  inputs. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The foundation for styling is Tailwind CSS, a utility-first CSS framework,
  augmented with daisyUI, a Tailwind CSS plugin that provides UI components
  and themes. Here are useful references:

    * [daisyUI](https://daisyui.com/docs/intro/) - a good place to get
      started and see the available components.

    * [Tailwind CSS](https://tailwindcss.com) - the foundational framework
      we build on. You will use it for layout, sizing, flexbox, grid, and
      spacing.

    * [Heroicons](https://heroicons.com) - see `icon/1` for usage.

    * [Phoenix.Component](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html) -
      the component system used by Phoenix. Some components, such as `<.link>`
      and `<.form>`, are defined there.

  """
  use Phoenix.Component
  use Gettext, backend: SyncMeWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="toast toast-top toast-end z-50"
      {@rest}
    >
      <div class={[
        "alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap",
        @kind == :info && "alert-info",
        @kind == :error && "alert-error"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="size-5 shrink-0" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="size-5 shrink-0" />
        <div>
          <p :if={@title} class="font-semibold">{@title}</p>
          <p>{msg}</p>
        </div>
        <div class="flex-1" />
        <button type="button" class="group self-start cursor-pointer" aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="size-5 opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button with navigation support.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" variant="primary">Send!</.button>
      <.button navigate={~p"/"}>Home</.button>
  """
  attr :rest, :global, include: ~w(href navigate patch)
  attr :variant, :string, values: ~w(primary neutral)
  slot :inner_block, required: true

  def button(%{rest: rest} = assigns) do
    variants = %{
      "primary" => "btn-neutral",
      "neutral" => "btn-neutral",
      nil => "btn-neutral btn-soft"
    }

    assigns = assign(assigns, :class, Map.fetch!(variants, assigns[:variant]))

    if rest[:href] || rest[:navigate] || rest[:patch] do
      ~H"""
      <.link class={["btn ", @class]} {@rest}>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button class={["btn btn-neutral", @class]} {@rest}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week path)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :path, :string, default: "syncme.link/"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "path"} = assigns) do

    ~H"""

     <fieldset class="fieldset mb-2">
      <label class="input">
        <span class="text-sm font-semibold text-secondary font-meidum bg-gray-300/30 p-2 -ml-3 rounded">{@path}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[ "pl-0", "grow", @errors != [] && "input-error"]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <fieldset class="fieldset mb-2">
      <label>
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <span class="fieldset-label">
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            class="checkbox checkbox-sm"
            {@rest}
          />{@label}
        </span>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <fieldset class="fieldset mb-2">
      <label>
        <span :if={@label} class="fieldset-label mb-1">{@label}</span>
        <select
          id={@id}
          name={@name}
          class={["w-full select", @errors != [] && "select-error"]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <fieldset class="fieldset mb-2">
      <label>
        <span :if={@label} class="fieldset-label mb-1">{@label}</span>
        <textarea
          id={@id}
          name={@name}
          class={["w-full textarea", @errors != [] && "textarea-error"]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <fieldset class="fieldset mb-2">
      <label>
        <span :if={@label} class="fieldset-legend mb-2">{@label}</span>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={["w-full input", @errors != [] && "input-error"]}
          {@rest}
        />
      </label>
      <.error :for={msg <- @errors}>{msg}</.error>
    </fieldset>
    """
  end

  # Helper used by inputs to generate form errors
  defp error(assigns) do
    ~H"""
    <p class="mt-1.5 flex gap-2 items-center text-sm text-error">
      <.icon name="hero-exclamation-circle-mini" class="size-5" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", "pb-4", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="text-sm text-base-content/70">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table class="table table-zebra">
      <thead>
        <tr>
          <th :for={col <- @col}>{col[:label]}</th>
          <th :if={@action != []}>
            <span class="sr-only">{gettext("Actions")}</span>
          </th>
        </tr>
      </thead>
      <tbody id={@id} phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}>
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={col <- @col}
            phx-click={@row_click && @row_click.(row)}
            class={@row_click && "hover:cursor-pointer"}
          >
            {render_slot(col, @row_item.(row))}
          </td>
          <td :if={@action != []} class="w-0 font-semibold">
            <div class="flex gap-4">
              <%= for action <- @action do %>
                {render_slot(action, @row_item.(row))}
              <% end %>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <ul class="list">
      <li :for={item <- @item} class="list-row">
        <div>
          <div class="font-bold">{item.title}</div>
          <div>{render_slot(item)}</div>
        </div>
      </li>
    </ul>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in `assets/vendor/heroicons.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(SyncMeWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(SyncMeWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc """
  Renders a message notice.

  Similar to `flash/1`, but for permanent messages on the page.

  ## Examples

      <.message_box kind="info" message="🦊 in a 📦" />

      <.message_box kind="info">
        <span>🦊</span> in a <span>📦</span>
      </.message_box>

  """

  attr :message, :string, default: nil
  attr :kind, :string, values: ~w(info neutral success warning error)

  slot :inner_block

  def message_box(assigns) do
    if assigns.message && assigns.inner_block != [] do
      raise ArgumentError, "expected either message or inner_block, got both."
    end

    ~H"""
    <div class={[
      "shadow text-sm rounded-sm px-4 py-2 border-l-4 rounded-l-none bg-white text-gray-700",
      @kind == "info" && "border-blue-500",
      @kind == "success" && "border-green-400",
      @kind == "warning" && "border-yellow-300",
      @kind == "error" && "border-red-500",
      @kind == "neutral" && "border-gray-500"
    ]}>
      <div
        :if={@message}
        class="whitespace-pre-wrap pr-2 max-h-52 overflow-y-auto tiny-scrollbar"
        phx-no-format
      >{@message}</div>
      <%= if @inner_block != [] do %>
        {render_slot(@inner_block)}
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a text content skeleton.
  """
  attr :empty, :boolean, default: false, doc: "if the source is empty"
  attr :bg_class, :string, default: "bg-gray-200", doc: "the skeleton background color"

  def content_skeleton(assigns) do
    ~H"""
    <%= if @empty do %>
      <div class="h-4"></div>
    <% else %>
      <div class="max-w-2xl w-full animate-pulse">
        <div class="flex-1 space-y-4">
          <div class={[@bg_class, "h-4 rounded-lg w-3/4"]}></div>
          <div class={[@bg_class, "h-4 rounded-lg"]}></div>
          <div class={[@bg_class, "h-4 rounded-lg w-5/6"]}></div>
        </div>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders text with a tiny label.

  ## Examples

      <.labeled_text label="Name">Sherlock Holmes</.labeled_text>

  """
  attr :label, :string, required: true

  attr :one_line, :boolean,
    default: false,
    doc: "whether to force the text into a single scrollable line"

  attr :class, :string, default: nil

  slot :inner_block, required: true

  def labeled_text(assigns) do
    ~H"""
    <div class={["flex flex-col space-y-1", @class]}>
      <span class="text-xs text-gray-500">
        {@label}
      </span>
      <span class={[
        "text-gray-800 text-xs font-semibold",
        @one_line &&
          "whitespace-nowrap overflow-hidden text-ellipsis hover:text-clip hover:overflow-auto hover:tiny-scrollbar"
      ]}>
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  @doc """
  Renders a choice button that is either active or not.

  ## Examples

      <.choice_button active={@tab == "my_tab"} phx-click="set_my_tab">
        My tab
      </.choice_button>

  """
  attr :active, :boolean, required: true
  attr :disabled, :boolean
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def choice_button(assigns) do
    assigns =
      assigns
      |> assign_new(:disabled, fn -> assigns.active end)

    ~H"""
    <button
      class={[
        "px-5 py-2 rounded-lg text-gray-700 border",
        if(@active, do: "bg-blue-100 border-blue-600", else: "bg-white border-gray-200"),
        @class
      ]}
      disabled={@disabled}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders an status indicator circle.
  """
  attr :variant, :string,
    required: true,
    values: ~w(success warning error inactive waiting progressing)

  def status_indicator(assigns) do
    ~H"""
    <span class="relative flex h-2.5 w-2.5">
      <span
        :if={animated_status_circle_class(@variant)}
        class={[
          animated_status_circle_class(@variant),
          "animate-ping absolute inline-flex h-full w-full rounded-full opacity-75"
        ]}
      >
      </span>
      <span class={[status_circle_class(@variant), "relative inline-flex rounded-full h-2.5 w-2.5"]}>
      </span>
    </span>
    """
  end

  @doc """
  Returns background class based on the given variant.

  See `status_indicator/1` for available variants.
  """
  def status_circle_class(variant)

  def status_circle_class("success"), do: "bg-green-400"
  def status_circle_class("warning"), do: "bg-yellow-200"
  def status_circle_class("error"), do: "bg-red-400"
  def status_circle_class("inactive"), do: "bg-gray-500"
  def status_circle_class("waiting"), do: "bg-gray-400"
  def status_circle_class("progressing"), do: "bg-blue-500"

  defp animated_status_circle_class("waiting"), do: "bg-gray-300"
  defp animated_status_circle_class("progressing"), do: "bg-blue-400"
  defp animated_status_circle_class(_other), do: nil

  @doc """
  Renders an informative box as a placeholder for a list.
  """

  slot :inner_block, required: true
  slot :actions

  def no_entries(assigns) do
    ~H"""
    <div class="p-5 flex space-x-4 items-center border border-gray-200 rounded-lg">
      <div>
        <.icon name="hero-viewfinder-circle" class="text-gray-400 text-xl" />
      </div>
      <div class="grow flex items-center justify-between">
        <div class="text-gray-600">
          {render_slot(@inner_block)}
        </div>
        {render_slot(@actions)}
      </div>
    </div>
    """
  end

  @doc """
  Renders a circular spinner.
  """

  attr :class, :string, default: nil
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <svg
      aria-hidden="true"
      class={["inline w-4 h-4 text-gray-200 animate-spin fill-blue-600", @class]}
      viewBox="0 0 100 101"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      {@rest}
    >
      <path
        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
        fill="currentColor"
      />
      <path
        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
        fill="currentFill"
      />
    </svg>
    """
  end

  @doc """
  Renders stateful tabs with content.

  ## Examples

      <.tabs id="animals" default="cat">
        <:tab id="cat" label="Cat">
          This is a cat.
        </:tab>
        <:tab id="dog" label="Dog">
          This is a dog.
        </:tab>
      </.tabs>

  """

  attr :id, :string, required: true
  attr :default, :string, required: true
  attr :variant, :string, default: "border", values: ~w(border box lift)
  attr :size, :string, default: "md", values: ~w(xs sm md l xl)

  slot :tab do
    attr :id, :string, required: true
    attr :label, :string, required: true
  end

  def tabs(assigns) do
    variants = %{"border" => "tabs-border", "box" => "tabs-box", "lift" => "tabs-lift"}
    assigns = assign(assigns, :tab_class, Map.fetch!(variants, assigns[:variant]))

    sizes = %{
      "xs" => "tabs-xs",
      "sm" => "tabs-sm",
      "md" => "",
      "l" => "tabs-lg",
      "xl" => "tabs-xl"
    }

    assigns = assign(assigns, :tab_size, Map.fetch!(sizes, assigns[:size]))

    ~H"""
    <div id={@id} class="flex flex-col gap-4">
      <div class={["tabs", @tab_class, @tab_size]}>
        <button
          :for={tab <- @tab}
          class={["tab", @default == tab.id && "active tab-active"]}
          phx-click={
            JS.remove_class("tab-active", to: "##{@id} .tab-active")
            |> JS.add_class("tab-active")
            |> JS.add_class("hidden", to: "##{@id} [data-tab]")
            |> JS.remove_class("hidden", to: "##{@id} [data-tab='#{tab.id}']")
          }
        >
          <span class="font-medium">
            {tab.label}
          </span>
        </button>
      </div>

      <div :for={tab <- @tab} data-tab={tab.id} class={@default == tab.id || "hidden"}>
        {render_slot(tab)}
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true, doc: "card body inner block"
  slot :actions

  def card(assigns) do
    ~H"""
    <div class={["card bg-base-100 border overflow-auto", @class]}>
      <div class="card-body">
        <h2 class="card-title">{@title}</h2>
        {render_slot(@inner_block)}
        <div class="card-actions justify-end">
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end
end
