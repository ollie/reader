initComponents = ->
  componentsMap = {}

  for item in $('[data-js-component]')
    $item          = $(item)
    componentNames = $item.data('js-component').split(',').map((name) -> name.trim())

    for componentName in componentNames
      componentsMap[componentName] = true

  for componentName, _ of componentsMap
    component = window[componentName]
    console.log("Initializing #{componentName}")
    new component

$ ->
  initComponents()
