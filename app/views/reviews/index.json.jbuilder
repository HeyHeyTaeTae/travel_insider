json.array!(@reviews) do |review|
  json.extract! review, :id, :stars, :text
  json.url review_url(review, format: :json)
end
