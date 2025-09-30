class MachineLearningService
  class << self
    def train_model(data, model_type: :linear_regression)
      case model_type
      when :linear_regression
        train_linear_regression(data)
      when :logistic_regression
        train_logistic_regression(data)
      when :time_series
        train_time_series_model(data)
      when :clustering
        train_clustering_model(data)
      end
    end

    private

    def train_linear_regression(data)
      x = data[:features]
      y = data[:target]
      
      # Calculate coefficients using normal equation
      x_matrix = Matrix[*x]
      y_matrix = Matrix.column_vector(y)
      
      # Add bias term
      x_with_bias = Matrix.build(x.size, x.first.size + 1) do |row, col|
        col.zero? ? 1 : x[row][col - 1]
      end
      
      # Calculate coefficients: β = (X'X)^(-1)X'y
      coefficients = (x_with_bias.transpose * x_with_bias).inverse * x_with_bias.transpose * y_matrix
      
      {
        coefficients: coefficients.to_a.flatten,
        r_squared: calculate_r_squared(x, y, coefficients)
      }
    end

    def train_logistic_regression(data)
      x = data[:features]
      y = data[:target]
      max_iterations = 1000
      learning_rate = 0.01
      
      # Initialize weights
      weights = Array.new(x.first.size + 1, 0)
      
      max_iterations.times do
        # Calculate gradients
        gradients = calculate_logistic_gradients(x, y, weights)
        
        # Update weights
        weights = weights.zip(gradients).map { |w, g| w - learning_rate * g }
        
        # Check convergence
        break if gradients.all? { |g| g.abs < 1e-5 }
      end
      
      {
        weights: weights,
        accuracy: calculate_logistic_accuracy(x, y, weights)
      }
    end

    def train_time_series_model(data)
      dates = data[:dates]
      values = data[:values]
      
      # Extract seasonal components
      seasonal_components = extract_seasonal_components(dates, values)
      
      # Remove seasonality
      deseasonalized = remove_seasonality(values, seasonal_components)
      
      # Train trend model
      trend_model = train_linear_regression(
        features: dates.map { |d| [d.to_i] },
        target: deseasonalized
      )
      
      {
        trend_coefficients: trend_model[:coefficients],
        seasonal_components: seasonal_components,
        accuracy: trend_model[:r_squared]
      }
    end

    def train_clustering_model(data)
      points = data[:points]
      k = data[:k] || Math.sqrt(points.size).ceil
      
      # Initialize centroids
      centroids = initialize_centroids(points, k)
      max_iterations = 100
      
      max_iterations.times do
        # Assign points to clusters
        clusters = assign_to_clusters(points, centroids)
        
        # Update centroids
        new_centroids = update_centroids(clusters)
        
        # Check convergence
        break if centroids_converged?(centroids, new_centroids)
        
        centroids = new_centroids
      end
      
      {
        centroids: centroids,
        cluster_assignments: assign_to_clusters(points, centroids),
        silhouette_score: calculate_silhouette_score(points, centroids)
      }
    end

    def calculate_r_squared(x, y, coefficients)
      y_pred = predict_linear(x, coefficients)
      y_mean = y.sum / y.size.to_f
      
      ss_tot = y.map { |yi| (yi - y_mean) ** 2 }.sum
      ss_res = y.zip(y_pred).map { |yi, fi| (yi - fi) ** 2 }.sum
      
      1 - (ss_res / ss_tot)
    end

    def calculate_logistic_gradients(x, y, weights)
      m = x.size
      
      gradients = Array.new(weights.size, 0)
      x.zip(y).each do |xi, yi|
        xi_with_bias = [1] + xi
        h = sigmoid(dot_product(xi_with_bias, weights))
        error = h - yi
        
        xi_with_bias.each_with_index do |xij, j|
          gradients[j] += error * xij
        end
      end
      
      gradients.map { |g| g / m.to_f }
    end

    def sigmoid(z)
      1.0 / (1.0 + Math.exp(-z))
    end

    def dot_product(a, b)
      a.zip(b).map { |x, y| x * y }.sum
    end

    def extract_seasonal_components(dates, values)
      # Group by season (e.g., month)
      seasonal_values = dates.zip(values).group_by { |d, _| d.month }
      
      # Calculate seasonal indices
      indices = {}
      seasonal_values.each do |season, points|
        indices[season] = points.map(&:last).sum / points.size.to_f
      end
      
      # Normalize indices
      mean_index = indices.values.sum / indices.size.to_f
      indices.transform_values { |v| v / mean_index }
    end

    def initialize_centroids(points, k)
      # K-means++ initialization
      centroids = [points.sample]
      
      (k - 1).times do
        # Calculate distances to nearest centroid for each point
        distances = points.map do |point|
          centroids.map { |c| euclidean_distance(point, c) }.min
        end
        
        # Choose next centroid with probability proportional to distance squared
        sum_distances = distances.sum
        probabilities = distances.map { |d| d / sum_distances }
        
        # Select next centroid
        r = rand
        cumulative_prob = 0
        next_centroid_index = probabilities.each_with_index.find do |prob, _|
          cumulative_prob += prob
          cumulative_prob >= r
        end.last
        
        centroids << points[next_centroid_index]
      end
      
      centroids
    end

    def euclidean_distance(a, b)
      Math.sqrt(a.zip(b).map { |x, y| (x - y) ** 2 }.sum)
    end
  end
end