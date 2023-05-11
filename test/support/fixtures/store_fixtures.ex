defmodule DigistabStore.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DigistabStore.Store` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: 42,
        promotional_price: 42,
        stock: 42
      })
      |> DigistabStore.Store.create_product()

    product
  end

  @doc """
  Generate a status.
  """
  def status_fixture(attrs \\ %{}) do
    {:ok, status} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> DigistabStore.Store.create_status()

    status
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> DigistabStore.Store.create_category()

    category
  end

  @doc """
  Generate a tag_type.
  """
  def tag_type_fixture(attrs \\ %{}) do
    {:ok, tag_type} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> DigistabStore.Store.create_tag_type()

    tag_type
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> DigistabStore.Store.create_tag()

    tag
  end

  @doc """
  Generate a product_tag.
  """
  def product_tag_fixture(attrs \\ %{}) do
    {:ok, product_tag} =
      attrs
      |> Enum.into(%{})
      |> DigistabStore.Store.create_product_tag()

    product_tag
  end

  @doc """
  Generate a product_category.
  """
  def product_category_fixture(attrs \\ %{}) do
    {:ok, product_category} =
      attrs
      |> Enum.into(%{})
      |> DigistabStore.Store.create_product_category()

    product_category
  end
end
