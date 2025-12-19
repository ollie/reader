function initComponents() {
  let componentsMap = {}

  $("[data-js-component]").each((_, item) => {
    const $item = $(item)
    let componentNames = $item.data("js-component").split(",").map(name => name.trim())

    componentNames.forEach(componentName => {
      componentsMap[componentName] = true
    })

    for (const componentName of componentNames) {
      const component = window[componentName]
      console.log(`Initializing ${componentName}`)
      try {
        new component
      } catch (e) {
        console.error(e)
      }
    }
  })
}

$(function() {
  initComponents()
})
