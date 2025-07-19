defmodule KidsMedia.Unsplash do
  @moduledoc """
  Unsplash API client for fetching animal images.

  This module provides functionality to search for images using the Unsplash API.
  It's designed to fetch kid-friendly animal images for the KidsMedia application.

  Features randomness in image results through multiple strategies:
  - Mixed search/random endpoint usage (70%/30% split)
  - Random ordering parameters (relevant vs latest)
  - Query enhancement with descriptive terms
  - Result shuffling for additional variety
  """

  @search_endpoint "https://api.unsplash.com/search/photos"
  @random_endpoint "https://api.unsplash.com/photos/random"
  @per_page 30

  # Random descriptive terms to add variety to searches
  @descriptive_terms [
    "cute",
    "wild",
    "beautiful",
    "majestic",
    "young",
    "adult",
    "natural",
    "wildlife",
    "nature",
    "outdoor",
    "portrait",
    "close-up"
  ]

  def search!(query) do
    # Randomly choose between search strategies for more variety
    if :rand.uniform() > 0.3 do
      search_with_randomness(query)
    else
      random_photos(query)
    end
  end

  # Search with random ordering and query variations to introduce variety in results
  defp search_with_randomness(query) do
    key = Application.fetch_env!(:kids_media, __MODULE__)[:access_key]

    # Randomly select order_by parameter for variety
    order_by = Enum.random(["relevant", "latest"])

    # Occasionally add a random descriptive term to vary the search
    enhanced_query =
      if :rand.uniform() > 0.5 do
        random_term = Enum.random(@descriptive_terms)
        "#{random_term} #{query}"
      else
        query
      end

    url =
      "#{@search_endpoint}?query=#{URI.encode(enhanced_query)}&per_page=#{@per_page}&order_by=#{order_by}&client_id=#{key}"

    {:ok, %{status_code: 200, body: body}} =
      HTTPoison.get(url, [], follow_redirect: true)

    results =
      body
      |> Jason.decode!()
      |> Map.fetch!("results")
      |> Enum.map(fn photo ->
        %{
          url: photo["urls"]["regular"],
          photographer_name: photo["user"]["name"],
          photographer_url: photo["user"]["links"]["html"],
          photo_url: photo["links"]["html"]
        }
      end)

    # Shuffle results for additional randomness
    Enum.shuffle(results)
  end

  # Use random photos endpoint for maximum randomness
  defp random_photos(query) do
    key = Application.fetch_env!(:kids_media, __MODULE__)[:access_key]

    # For random endpoint, also occasionally enhance the query
    enhanced_query =
      if :rand.uniform() > 0.6 do
        random_term = Enum.random(@descriptive_terms)
        "#{random_term} #{query}"
      else
        query
      end

    url =
      "#{@random_endpoint}?query=#{URI.encode(enhanced_query)}&count=#{@per_page}&client_id=#{key}"

    case HTTPoison.get(url, [], follow_redirect: true) do
      {:ok, %{status_code: 200, body: body}} ->
        # Random endpoint returns array directly, not wrapped in "results"
        results =
          body
          |> Jason.decode!()
          |> Enum.map(fn photo ->
            %{
              url: photo["urls"]["regular"],
              photographer_name: photo["user"]["name"],
              photographer_url: photo["user"]["links"]["html"],
              photo_url: photo["links"]["html"]
            }
          end)

        Enum.shuffle(results)

      # Fallback to search if random endpoint fails
      _ ->
        search_with_randomness(query)
    end
  end
end
