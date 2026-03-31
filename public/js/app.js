function initComponents() {
  let componentsMap = new Set()

  $("[data-js-component]").each((_, item) => {
    const $item = $(item)
    let componentNames = $item.data("js-component").split(",").map(name => name.trim())

    for (const componentName of componentNames) {
      if (componentsMap.has(componentName)) {
        continue
      }

      componentsMap.add(componentName)

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
