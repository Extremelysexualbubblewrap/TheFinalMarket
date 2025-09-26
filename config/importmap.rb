# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.12
pin "sortablejs" # @1.15.6
pin "cropperjs" # @2.0.1
pin "@cropper/element", to: "@cropper--element.js" # @2.0.1
pin "@cropper/element-canvas", to: "@cropper--element-canvas.js" # @2.0.1
pin "@cropper/element-crosshair", to: "@cropper--element-crosshair.js" # @2.0.1
pin "@cropper/element-grid", to: "@cropper--element-grid.js" # @2.0.1
pin "@cropper/element-handle", to: "@cropper--element-handle.js" # @2.0.1
pin "@cropper/element-image", to: "@cropper--element-image.js" # @2.0.1
pin "@cropper/element-selection", to: "@cropper--element-selection.js" # @2.0.1
pin "@cropper/element-shade", to: "@cropper--element-shade.js" # @2.0.1
pin "@cropper/element-viewer", to: "@cropper--element-viewer.js" # @2.0.1
pin "@cropper/elements", to: "@cropper--elements.js" # @2.0.1
pin "@cropper/utils", to: "@cropper--utils.js" # @2.0.1
pin "chart.js" # @4.5.0
pin "chartkick" # @5.0.1
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.4
