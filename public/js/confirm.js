class Confirm {
  constructor() {
    const $items = $("[data-confirm]")
    $items.on("click", this.#handleClick.bind(this))
  }

  #handleClick(e) {
    const $item = $(e.currentTarget)
    const message = $item.data("confirm")

    if (message && !confirm(message)) {
      e.preventDefault()
    }
  }
}

window.Confirm = Confirm
