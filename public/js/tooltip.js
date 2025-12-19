class Tooltip {
  constructor() {
    const $items = $('[data-toggle="tooltip"]')
    $items.tooltip()
  }
}

window.Tooltip = Tooltip
