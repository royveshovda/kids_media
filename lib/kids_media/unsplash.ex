defmodule KidsMedia.Unsplash do
  @endpoint "https://api.unsplash.com/search/photos"
  @per_page 10
  def search!(query) do
    key = Application.fetch_env!(:kids_media, __MODULE__)[:access_key]

    {:ok, %{status_code: 200, body: body}} =
      HTTPoison.get(
        "#{@endpoint}?query=#{URI.encode(query)}&per_page=#{@per_page}&client_id=#{key}",
        [],
        follow_redirect: true
      )

    body
    |> Jason.decode!()
    |> Map.fetch!("results")
    |> Enum.map(& &1["urls"]["regular"])
  end
end
