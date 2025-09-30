class Admin::FinancialsController < Admin::BaseController
  def index
    @financials = FinancialsDecorator.new
  end
end
