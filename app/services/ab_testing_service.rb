class AbTestingService
  class << self
    def register_experiment(name:, variants:, description: nil, traffic_percentage: 100)
      Split::ExperimentCatalog.find_or_create(name) do |experiment|
        experiment.alternatives = variants
        experiment.metadata = {
          description: description,
          created_at: Time.current,
          traffic_percentage: traffic_percentage
        }
        
        # Set up goals/metrics for the experiment
        experiment.goals = [
          'completed_purchase',
          'added_to_cart',
          'signup_completed',
          'newsletter_subscription'
        ]
      end
    end

    def assign_variant(experiment_name, user = nil)
      return default_variant(experiment_name) unless should_participate?(user)

      Split::Trial.new(user, experiment_name).choose!
    end

    def track_conversion(experiment_name, user, goal = nil)
      return unless user && experiment_running?(experiment_name)

      trial = Split::Trial.new(user, experiment_name)
      trial.complete!(goal)
    end

    def experiment_running?(name)
      Split::ExperimentCatalog.find(name)&.enabled?
    end

    def all_experiments
      Split::ExperimentCatalog.all
    end

    def experiment_results(name)
      experiment = Split::ExperimentCatalog.find(name)
      return unless experiment

      {
        name: experiment.name,
        start_date: experiment.metadata['created_at'],
        participants: experiment.participant_count,
        alternatives: experiment.alternatives.map do |alternative|
          {
            name: alternative.name,
            participants: alternative.participant_count,
            completed: alternative.completed_count,
            conversion_rate: alternative.conversion_rate,
            z_score: alternative.z_score,
            confidence_level: confidence_level(alternative.z_score)
          }
        end,
        goals: experiment.goals.map do |goal|
          {
            name: goal,
            completion_counts: experiment.alternatives.map do |alternative|
              {
                variant: alternative.name,
                count: alternative.completion_count(goal)
              }
            end
          }
        end
      }
    end

    private

    def should_participate?(user)
      return false if user&.admin? # Exclude admins from experiments
      return false if user&.beta_tester? # Exclude beta testers
      true
    end

    def default_variant(experiment_name)
      experiment = Split::ExperimentCatalog.find(experiment_name)
      experiment&.control&.name || 'control'
    end

    def confidence_level(z_score)
      return 'N/A' if z_score.nil?
      
      case z_score.abs
      when 0..1.28 then 'Low (< 80%)'
      when 1.28..1.64 then 'Medium (80-90%)'
      when 1.64..2.33 then 'High (90-98%)'
      else 'Very High (> 98%)'
      end
    end
  end
end