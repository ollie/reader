class @Confirm
  constructor: ->
    $items = $('[data-confirm]')
    $items.on('click', @_handleClick)

  _handleClick: (e) =>
    $item   = $(e.currentTarget)
    message = $item.data('confirm')

    if message && !confirm(message)
      e.preventDefault()
