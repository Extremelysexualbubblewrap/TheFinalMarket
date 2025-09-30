class Admin::AbTestsController < Admin::BaseController
  def index
    @experiments = AbTestingService.all_experiments
    @active_experiments = @experiments.select(&:enabled?)
    @completed_experiments = @experiments.reject(&:enabled?)
  end

  def show
    @experiment = Split::ExperimentCatalog.find(params[:id])
    @results = AbTestingService.experiment_results(params[:id])
  end

  def new
    @experiment = Split::Experiment.new
  end

  def create
    AbTestingService.register_experiment(
      name: params[:name],
      variants: params[:variants].split(',').map(&:strip),
      description: params[:description],
      traffic_percentage: params[:traffic_percentage]
    )

    redirect_to admin_ab_tests_path, notice: 'Experiment was successfully created.'
  end

  def update
    experiment = Split::ExperimentCatalog.find(params[:id])
    
    case params[:action_type]
    when 'start'
      experiment.start
      notice = 'Experiment started'
    when 'pause'
      experiment.pause
      notice = 'Experiment paused'
    when 'resume'
      experiment.resume
      notice = 'Experiment resumed'
    when 'reset'
      experiment.reset
      notice = 'Experiment reset'
    when 'delete'
      experiment.delete
      notice = 'Experiment deleted'
    end

    redirect_to admin_ab_tests_path, notice: notice
  end

  def report
    @experiment = Split::ExperimentCatalog.find(params[:id])
    @results = AbTestingService.experiment_results(params[:id])
    
    respond_to do |format|
      format.html
      format.json { render json: @results }
      format.csv { send_data generate_csv_report(@results), filename: "ab-test-#{params[:id]}.csv" }
    end
  end

  private

  def generate_csv_report(results)
    CSV.generate(headers: true) do |csv|
      # Basic experiment info
      csv << ['Experiment Name', results[:name]]
      csv << ['Start Date', results[:start_date]]
      csv << ['Total Participants', results[:participants]]
      csv << []

      # Variant results
      csv << ['Variant', 'Participants', 'Completions', 'Conversion Rate', 'Z-Score', 'Confidence Level']
      results[:alternatives].each do |alt|
        csv << [
          alt[:name],
          alt[:participants],
          alt[:completed],
          "#{(alt[:conversion_rate] * 100).round(2)}%",
          alt[:z_score],
          alt[:confidence_level]
        ]
      end
      csv << []

      # Goal completions
      results[:goals].each do |goal|
        csv << ["Goal: #{goal[:name]}"]
        csv << ['Variant', 'Completions']
        goal[:completion_counts].each do |count|
          csv << [count[:variant], count[:count]]
        end
        csv << []
      end
    end
  end
end