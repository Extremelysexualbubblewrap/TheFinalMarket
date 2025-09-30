class Admin::AnalyticsController < Admin::BaseController
  def index
    @analytics = AnalyticsService.new(
      start_date: params.fetch(:start_date, 30.days.ago),
      end_date: params.fetch(:end_date, Time.current)
    )

    @sales_data = @analytics.sales_overview
    @user_metrics = @analytics.user_metrics
    @product_performance = @analytics.product_performance
    @customer_insights = @analytics.customer_insights

    respond_to do |format|
      format.html
      format.json { render json: build_dashboard_data }
      format.csv { send_data generate_csv_report, filename: "analytics-#{Date.current}.csv" }
    end
  end

  def real_time
    @current_visitors = Ahoy::Visit.where('started_at > ?', 15.minutes.ago).count
    @active_carts = Cart.where('updated_at > ?', 1.hour.ago).count
    @recent_orders = Order.where('created_at > ?', 1.hour.ago)
    @recent_events = Ahoy::Event.where('time > ?', 15.minutes.ago)
                               .order(time: :desc)
                               .limit(50)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: build_real_time_data }
    end
  end

  def cohorts
    @cohort_analysis = CohortAnalysisService.new(
      start_date: params.fetch(:start_date, 12.months.ago),
      end_date: params.fetch(:end_date, Time.current)
    ).analyze

    respond_to do |format|
      format.html
      format.json { render json: @cohort_analysis }
    end
  end

  def export
    report_type = params[:type]
    start_date = params.fetch(:start_date, 30.days.ago)
    end_date = params.fetch(:end_date, Time.current)

    ExportAnalyticsJob.perform_later(
      report_type: report_type,
      start_date: start_date,
      end_date: end_date,
      user_id: current_user.id
    )

    redirect_to admin_analytics_path, notice: 'Your report is being generated and will be emailed to you shortly.'
  end

  private

  def build_dashboard_data
    {
      sales_overview: @sales_data,
      user_metrics: @user_metrics,
      product_performance: @product_performance,
      customer_insights: @customer_insights
    }
  end

  def build_real_time_data
    {
      current_visitors: @current_visitors,
      active_carts: @active_carts,
      recent_orders: @recent_orders.as_json(
        only: [:id, :total_amount, :status],
        include: { user: { only: [:id, :email] } }
      ),
      recent_events: @recent_events.as_json(
        only: [:name, :time],
        include: { visit: { only: [:landing_page, :device_type] } }
      )
    }
  end

  def generate_csv_report
    CSV.generate(headers: true) do |csv|
      csv << ['Metric', 'Value', 'Date Range']
      
      @sales_data.each do |key, value|
        csv << [key.to_s.humanize, value, "#{params[:start_date]} - #{params[:end_date]}"]
      end
      
      @user_metrics.each do |key, value|
        csv << [key.to_s.humanize, value, "#{params[:start_date]} - #{params[:end_date]}"]
      end
    end
  end
end