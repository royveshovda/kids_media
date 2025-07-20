defmodule KidsMedia.UnsplashMock do
  @moduledoc """
  Mock implementation of Unsplash API for testing purposes.
  Returns predefined image data with photographer credits instead of making real API calls.
  """

  def search!(_query) do
    [
      %{
        url: "https://images.unsplash.com/photo-1574144611937-0df059b5ef3e",
        photographer_name: "John Photographer",
        photographer_url: "https://unsplash.com/@john",
        photo_url: "https://unsplash.com/photos/test-photo-1"
      },
      %{
        url: "https://images.unsplash.com/photo-1546026423-cc4642628d2b",
        photographer_name: "Jane Wildlife",
        photographer_url: "https://unsplash.com/@jane",
        photo_url: "https://unsplash.com/photos/test-photo-2"
      },
      %{
        url: "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7",
        photographer_name: "Bob Nature",
        photographer_url: "https://unsplash.com/@bob",
        photo_url: "https://unsplash.com/photos/test-photo-3"
      },
      %{
        url: "https://images.unsplash.com/photo-1595433707802-6b2626ef1c91",
        photographer_name: "Alice Animals",
        photographer_url: "https://unsplash.com/@alice",
        photo_url: "https://unsplash.com/photos/test-photo-4"
      },
      %{
        url: "https://images.unsplash.com/photo-1557804506-669a67965ba0",
        photographer_name: "Mike Safari",
        photographer_url: "https://unsplash.com/@mike",
        photo_url: "https://unsplash.com/photos/test-photo-5"
      }
    ]
  end

  @doc """
  Returns empty list for testing no images scenario
  """
  def search_empty!(_query) do
    []
  end

  @doc """
  Raises an error for testing error handling
  """
  def search_error!(_query) do
    raise "Network error"
  end

  @doc """
  Returns different set of images to simulate refresh
  """
  def search_refresh!(_query) do
    [
      %{
        url: "https://images.unsplash.com/photo-1555169062-013468b47731",
        photographer_name: "Sarah Refresh",
        photographer_url: "https://unsplash.com/@sarah",
        photo_url: "https://unsplash.com/photos/refresh-photo-1"
      },
      %{
        url: "https://images.unsplash.com/photo-1559827260-dc66d52bef19",
        photographer_name: "Tom New",
        photographer_url: "https://unsplash.com/@tom",
        photo_url: "https://unsplash.com/photos/refresh-photo-2"
      }
    ]
  end
end
