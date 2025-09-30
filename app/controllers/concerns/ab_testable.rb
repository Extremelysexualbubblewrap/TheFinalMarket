module AbTestable
  extend ActiveSupport::Concern

  included do
    helper_method :ab_test
    helper_method :ab_finished
    helper_method :ab_active?
  end

  def ab_test(experiment_name, *variants)
    # Register the experiment if it doesn't exist
    unless AbTestingService.experiment_running?(experiment_name)
      AbTestingService.register_experiment(
        name: experiment_name,
        variants: variants,
        description: "Auto-created experiment for #{experiment_name}"
      )
    end

    # Get the variant for this user
    variant = AbTestingService.assign_variant(experiment_name, current_user)

    # Track exposure in analytics
    track_ab_test_exposure(experiment_name, variant) if defined?(ahoy)

    variant
  end

  def ab_finished(experiment_name, goal = nil)
    AbTestingService.track_conversion(experiment_name, current_user, goal)
  end

  def ab_active?(experiment_name)
    AbTestingService.experiment_running?(experiment_name)
  end

  private

  def track_ab_test_exposure(experiment_name, variant)
    ahoy.track "ab_test_exposure", {
      experiment: experiment_name,
      variant: variant,
      user_id: current_user&.id
    }
  end
end