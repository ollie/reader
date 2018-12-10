class Confirm
  constructor: ->
    $items = $('[data-confirm]')
    $items.on('click', this._handleClick)

  _handleClick: (e) =>
    $item   = $(e.currentTarget)
    message = $item.data('confirm')

    if message && !confirm(message)
      e.preventDefault()



class Tooltip
  constructor: ->
    $items = $('[data-toggle="tooltip"]')
    $items.tooltip()



$ ->
  new Confirm
  new Tooltip
