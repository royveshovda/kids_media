defmodule KidsMedia.UnsplashMock do
  @moduledoc """
  Mock implementation of Unsplash API for testing purposes.
  Returns predefined image URLs instead of making real API calls.
  """

  def search!(_query) do
    [
      "https://images.unsplash.com/photo-1574144611937-0df059b5ef3e",
      "https://images.unsplash.com/photo-1546026423-cc4642628d2b",
      "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7",
      "https://images.unsplash.com/photo-1595433707802-6b2626ef1c91",
      "https://images.unsplash.com/photo-1557804506-669a67965ba0"
    ]
  end
end
