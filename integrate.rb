# frozen_string_literal: true
​
require "graphql/client"
require "graphql/client/http"
​
module Catalog
  module Nautical
    class Client
      DEFAULT_PRODUCT_TYPE = "Q2F0ZWdvcnk6MzE="
      GBG_SELLER = "U2VsbGVyOjg="
​
      RAW_CLIENT = GraphQL::Client.new(
        schema: GraphQL::Client.load_schema("./nautical-schema.json"), # TODO: currently broken...
        execute: connection
      )
​
      CONNECTION = GraphQL::Client::HTTP.new(ENV["NAUTICAL_GRAPHQL"]) do
        def headers(context)
          {
            "User-Agent": "GBG-Catalog",
            Authorization: "JWT #{ENV["NAUTICAL_JWT"]}" # TODO: replace with bearer? we'll need a refresh scheme...
          }
        end
      end
​
      PRODUCT_CREATE_MUTATION = Catalog::Nautical::Client::RAW_CLIENT.parse <<-"GRAPHQL"
        mutation CreateProduct($input: $CreateProductInput) {
          productCreate(input: $input) {
        } {
          product {
            id
          }
          productErrors {
            message
          }
        }
      }
      GRAPHQL
​
      class << self
        def introspect
          Catalog::Nautical::Client::RAW_CLIENT.introspection_query
        end

        def create_master_product(product:)
          RAW_CLIENT.query(PRODUCT_CREATE_MUTATION, {
            variables: {
              input: {
                name: product.name,
                slug: product.slug,
                category: product.category.id,
                description: product.description,
                is_master: true,
                brand: product.brand.id,
                seller: GBG_SELLER,
                product_type: DEFAULT_PRODUCT_TYPE
              }
            }
          })
        end
      end
    end
  end
end
