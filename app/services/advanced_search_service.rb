class AdvancedSearchService
  include Elasticsearch::DSL

  def initialize(query: nil, filters: {}, page: 1, per_page: 20)
    @query = query
    @filters = filters
    @page = page
    @per_page = per_page
  end

  def search
    definition = Elasticsearch::DSL::Search.search {
      query do
        bool do
          # Natural language query with synonyms and fuzzy matching
          must do
            multi_match do
              query @query
              fields ['name^3', 'description^2', 'category^2', 'tags', 'brand']
              fuzziness 'AUTO'
              operator 'and'
              minimum_should_match '70%'
            end if @query.present?
          end

          # Apply filters
          filter do
            bool do
              must { term category: @filters[:category] } if @filters[:category]
              must { term brand: @filters[:brand] } if @filters[:brand]
              must { range price: { gte: @filters[:min_price] } } if @filters[:min_price]
              must { range price: { lte: @filters[:max_price] } } if @filters[:max_price]
              must { terms tags: @filters[:tags] } if @filters[:tags]
            end
          end
        end
      end

      # Add aggregations for faceted search
      aggregation :categories do
        terms field: 'category.keyword'
      end

      aggregation :brands do
        terms field: 'brand.keyword'
      end

      aggregation :price_ranges do
        range field: 'price' do
          key 'under_50', to: 50
          key '50-100', from: 50, to: 100
          key '100-200', from: 100, to: 200
          key 'over_200', from: 200
        end
      end

      aggregation :popular_tags do
        terms field: 'tags.keyword', size: 20
      end

      # Add highlighting
      highlight do
        fields name: { number_of_fragments: 0 },
               description: { number_of_fragments: 3, fragment_size: 150 }
        pre_tags ['<em class="highlight">']
        post_tags ['</em>']
      end

      # Add sorting options
      sort do
        by :_score, order: 'desc'
        by @filters[:sort_by] => @filters[:sort_order] if @filters[:sort_by]
      end

      # Add pagination
      from (@page - 1) * @per_page
      size @per_page
    }

    results = Product.search(definition)
    
    # Process and enhance results
    {
      products: results.records,
      total: results.total,
      aggregations: results.aggregations,
      highlights: results.highlight,
      suggestions: generate_suggestions(results)
    }
  end

  private

  def generate_suggestions(results)
    return [] unless @query.present?

    # Get similar terms based on successful searches
    similar_terms = Elasticsearch::DSL::Search.search {
      suggest :term_suggestions do
        term field: 'name', size: 5
        text @query
      end
    }

    # Combine with related tags and categories
    related_terms = results.aggregations.dig('popular_tags', 'buckets')
                         .map { |bucket| bucket['key'] }
                         .first(5)

    (similar_terms.dig('suggestions', 'terms') + related_terms).uniq
  end
end