initComponents = ->
  componentsMap = {}

  for item in $('[data-js-component]')
    $item = $(item)
    componentsMap[$item.data('js-component')] = true

  for componentName, _ of componentsMap
    component = window[componentName]
    console.log("Initializing #{componentName}")
    new component

$ ->
  initComponents()
