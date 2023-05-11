defmodule DigistabStoreWeb.ProductLive.FormComponent do
  use DigistabStoreWeb, :live_component

  alias DigistabStore.Store

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <!--:subtitle>Use this form to manage product records in your database.</!--:subtitle-->
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
      <div class="md:mx-4 flex flex-col md:flex-row">
        <div class="md:mr-4 md:w-3/5 mb-4 md:mb-0">
          <div class="mb-4 rounded-md bg-white p-4 text-left space-y-4">
            <.input field={@form[:name]} type="text" label="Product name" placeholder="Product name" />
            <.input field={@form[:description]} type="wysiwyg" label="Description" />
          </div>
          <div class="mb-4 h-fit rounded-md bg-white p-4">
            <.live_upload />
          </div>
          <div class="grid grid-rows-3 sm:grid-rows-none sm:grid-cols-3 gap-4 rounded-md bg-white p-4">
            <.input field={@form[:price]} type="price" label="Price"  value={0} />
            <.input field={@form[:promotional_price]} type="price" label="Promotional price" value={0} />
            <.input field={@form[:stock]} type="custom_counter" label="Stock" />
          </div>
        </div>
        <div class="md:w-2/5 flex flex-col md:h-128 justify-between">
          <div class="flex flex-col sm:flex-row md:flex-col sm:space-x-4 md:space-x-0 justify-between">
            <div class="mb-4 rounded-md bg-white p-4 w-full sm:w-1/2 md:w-full">
              <.input field={@form[:status_name]} type="select_with_description" label="Status" collection={@status_collection} options={@status} item={select_item(@status_collection, @product.status_id)}/>
            </div>
            <div class="mb-4 rounded-md bg-white p-4 w-full sm:w-1/2 md:w-full">
              <.input field={@form[:category_name]} type="select_with_description" label="Categories" collection={@categories_collection} options={@categories} item={select_item(@categories_collection, @product.category_id)}/>
            </div>
          </div>
          <div class="h-full bg-white rounded-md p-4">
            <.tag_selector tags={@tags} />
          </div>
        </div>
      </div>
        <:actions>
        <.button class="bg-red-400 hover:bg-red-200 hover:text-black">Cancel</.button>
        <.button class="bg-green-400" phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def tag_selector(assigns) do
    ~H"""
    <div>
    <div class="flex flex-row flex-wrap w-full justify-between border-b border-t py-4">
      <div class="text-sm border border-purple-200 px-2 my-1 mx-1 py-1 w-fit rounded-md" :for={tag <- (@tags ++ @tags)}> <%= tag.name %> </div>
    </div>
    </div>
    """
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Store.change_product(product)

    {:ok,
     socket
     |> assign(initial_assigns())
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    params =
      product_params
      |> validate_price("price")
      |> validate_price("promotional_price")
      |> validate_custom_select("status", socket.assigns.status_collection)
      |> validate_custom_select("category", socket.assigns.categories_collection)
      |> validate_stock()

    changeset =
      socket.assigns.product
      |> Store.change_product(params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    product_params =
      product_params
      |> validate_price("price")
      |> validate_price("promotional_price")
      |> save_custom_select("status", socket.assigns.status_collection)
      |> save_custom_select("category", socket.assigns.categories_collection)
      |> validate_stock()

    save_product(socket, socket.assigns.action, product_params)
  end

  defp save_product(socket, :edit, product_params) do
    case Store.update_product(socket.assigns.product, product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Store.create_product(product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp initial_assigns() do
    status_collection = DigistabStore.Store.list_status_collection()

    status =
      status_collection
      |> Enum.map(& &1.name)

    categories_collection = DigistabStore.Store.list_categories()

    categories =
      categories_collection
      |> Enum.map(& &1.name)

    tags =
      DigistabStore.Store.list_tags()

    [
      status: status,
      status_collection: status_collection,
      categories: categories,
      categories_collection: categories_collection,
      tags: tags
    ]
  end

  defp validate_price(attrs, field) do
    price = attrs[field]

    price =
      if price == "",
        do: "0",
        else:
          price
          |> String.replace(~r/\,|\./, "")
          |> String.to_integer()

    Map.put(attrs, field, price)
  end


  defp validate_stock(%{"stock" => stock} = attrs) when is_integer(stock), do: attrs
  defp validate_stock(%{"stock" => stock} = attrs) when stock == "", do: %{attrs | "stock" => 0}

  defp validate_stock(%{"stock" => stock} = attrs) do
    attrs
    |> Map.put("stock", String.to_integer(stock))
  end

  defp validate_custom_select(attrs, field, collection) do
    value = Enum.find(collection, fn st -> st.name == attrs[field] end)
    Map.put(attrs, field, value)
  end

  defp save_custom_select(attrs, field, collection) do
    value = Enum.find(collection, fn st -> st.name == attrs[field <> "_name"] end)
    Map.put(attrs, field <> "_id", value.id)
  end

  defp select_item(items, id) do
    if is_nil(id) do List.first(items) else Enum.find(items, & &1.id == id) end
    |> then(& &1.name)
  end
end
