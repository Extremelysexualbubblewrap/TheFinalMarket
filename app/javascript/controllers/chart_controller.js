// app/javascript/controllers/chart_controller.js
import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  connect() {
    // Override Chartkick's default colors with our spirit theme
    Chart.defaults.color = '#2D1B4F'; // spirit-dark
    Chart.defaults.borderColor = 'rgba(107, 79, 169, 0.2)'; // spirit-primary with alpha

    // Custom tooltips with spirit theme
    Chart.defaults.plugins.tooltip.backgroundColor = 'rgba(45, 27, 79, 0.9)'; // spirit-dark with alpha
    Chart.defaults.plugins.tooltip.titleColor = '#F0E7FF'; // spirit-light
    Chart.defaults.plugins.tooltip.bodyColor = '#F0E7FF'; // spirit-light
    Chart.defaults.plugins.tooltip.borderColor = '#9C7BE3'; // spirit-secondary
    Chart.defaults.plugins.tooltip.borderWidth = 1;
    Chart.defaults.plugins.tooltip.padding = 10;
    Chart.defaults.plugins.tooltip.cornerRadius = 8;
    Chart.defaults.plugins.tooltip.displayColors = false;
  }
}