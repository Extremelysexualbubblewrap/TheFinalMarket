class Admin::PredictiveAnalyticsController < Admin::BaseController
  def index
    @predictions = PredictiveAnalyticsService.new.generate_predictions
    
    respond_to do |format|
      format.html
      format.json { render json: @predictions }
    end
  end

  def sales_forecast
    @forecast = PredictiveAnalyticsService.new.forecast_sales(
      timeframe: params.fetch(:timeframe, 30).to_i.days
    )

    respond_to do |format|
      format.html
      format.json { render json: @forecast }
      format.csv { send_data generate_forecast_csv(@forecast), filename: "sales_forecast.csv" }
    end
  end

  def inventory_predictions
    @predictions = PredictiveAnalyticsService.new.predict_inventory_needs

    respond_to do |format|
      format.html
      format.json { render json: @predictions }
      format.csv { send_data generate_inventory_csv(@predictions), filename: "inventory_predictions.csv" }
    end
  end

  def customer_behavior
    @predictions = PredictiveAnalyticsService.new.predict_customer_behavior

    respond_to do |format|
      format.html
      format.json { render json: @predictions }
      format.csv { send_data generate_behavior_csv(@predictions), filename: "customer_behavior.csv" }
    end
  end

  def churn_risk
    @predictions = PredictiveAnalyticsService.new.predict_churn_risk

    respond_to do |format|
      format.html
      format.json { render json: @predictions }
      format.csv { send_data generate_churn_csv(@predictions), filename: "churn_risk.csv" }
    end
  end

  def retrain_models
    RetrainModelsJob.perform_later(
      models: params[:models] || ['all'],
      user_id: current_user.id
    )

    redirect_to admin_predictive_analytics_path, notice: 'Models are being retrained. You will be notified when the process is complete.'
  end

  private

  def generate_forecast_csv(forecast)
    CSV.generate(headers: true) do |csv|
      csv << ['Date', 'Predicted Sales', 'Lower Bound', 'Upper Bound']
      
      forecast[:dates].each_with_index do |date, i|
        csv << [
          date,
          forecast[:predictions][i],
          forecast[:confidence_intervals][i][:lower],
          forecast[:confidence_intervals][i][:upper]
        ]
      end
    end
  end

  def generate_inventory_csv(predictions)
    CSV.generate(headers: true) do |csv|
      csv << ['Product ID', 'Product Name', 'Current Stock', 'Predicted Demand', 
              'Reorder Point', 'Optimal Order Quantity', 'Confidence']
      
      predictions.each do |prediction|
        csv << [
          prediction[:product_id],
          prediction[:product_name],
          prediction[:current_stock],
          prediction[:predicted_demand],
          prediction[:reorder_point],
          prediction[:optimal_order_quantity],
          prediction[:confidence]
        ]
      end
    end
  end

  def generate_behavior_csv(predictions)
    CSV.generate(headers: true) do |csv|
      csv << ['User ID', 'Segment', 'Segment Confidence', 'Next Purchase Date',
              'Purchase Probability', 'Likely Categories', 'Personalization Factors']
      
      predictions.each do |prediction|
        csv << [
          prediction[:user_id],
          prediction[:segment],
          prediction[:segment_confidence],
          prediction[:predicted_next_purchase][:expected_date],
          prediction[:predicted_next_purchase][:probability],
          prediction[:predicted_next_purchase][:likely_categories].join(', '),
          prediction[:personalization_factors].to_json
        ]
      end
    end
  end

  def generate_churn_csv(predictions)
    CSV.generate(headers: true) do |csv|
      csv << ['User ID', 'Churn Probability', 'Risk Factors', 'Recommended Actions']
      
      predictions.each do |prediction|
        csv << [
          prediction[:user_id],
          prediction[:churn_probability],
          prediction[:risk_factors].to_json,
          prediction[:recommended_actions].join('; ')
        ]
      end
    end
  end
end