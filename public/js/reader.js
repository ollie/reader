class App {
  #htmlBody
  #errorMessage
  #scrollLink
  #anchor
  #channelsWrapper
  #itemsWrapper
  #markChannelsAsReadLink
  #markChannelAsReadLink
  #itemTitle
  #itemInfo
  #itemContent
  #itemMarkAsRead
  #itemMarkAsUnread
  #itemTemplate
  #activeChannel
  #activeItem

  constructor() {
    this.#htmlBody = $("html, body")
    this.#errorMessage = $("#error-message")
    this.#scrollLink = $("#scroll-link")
    this.#anchor = $("#anchor")
    this.#channelsWrapper = $("#channels-wrapper")
    this.#itemsWrapper = $("#items-wrapper")
    this.#markChannelsAsReadLink = $("#mark-channels-as-read-link")
    this.#markChannelAsReadLink = $("#mark-channel-as-read-link")
    this.#itemTitle = $("#item-title")
    this.#itemInfo = $("#item-info")
    this.#itemContent = $("#item-content")
    this.#itemMarkAsRead = $(".js-item-mark-as-read")
    this.#itemMarkAsUnread = $(".js-item-mark-as-unread")
    const $itemTemplate = $("#item-template")
    this.#itemTemplate = Hogan.compile($itemTemplate.html())

    this.#activeChannel = this.#channelsWrapper.find(".js-active")
    this.#activeItem = this.#itemsWrapper.find(".js-active")

    this.#scrollLink.on("click", this.#handleScrollLinkClick.bind(this))
    this.#markChannelsAsReadLink.on("click", this.#handleMarkChannelsAsReadClick.bind(this))
    this.#markChannelAsReadLink.on("click", this.#handleMarkChannelAsReadClick.bind(this))
    this.#channelsWrapper.on("click", ".js-link", this.#handleChannelClick.bind(this))
    this.#itemsWrapper.on("click", ".js-link", this.#handleItemClick.bind(this))
    this.#itemMarkAsRead.on("click", this.#handleMarkAsReadClick.bind(this))
    this.#itemMarkAsUnread.on("click", this.#handleMarkAsUnreadClick.bind(this))
  }

  #handleScrollLinkClick() {
    this.#scrollToAnchor()
  }

  #handleMarkChannelsAsReadClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)

    for (const channel of this.#channelsWrapper.find(".reader-item")) {
      const $counter = $(channel).find(".js-counter")

      if (!$counter.length) {
        continue
      }

      $counter.text(0)
      $counter.addClass("d-none")
    }

    for (const item of this.#itemsWrapper.find(".font-weight-bold")) {
      const $item = $(item)
      $item.removeClass("font-weight-bold")
      $item.find("a").removeClass("text-dark").addClass("text-secondary")
    }

    this.#itemMarkAsRead.addClass("d-none")
    this.#itemMarkAsUnread.removeClass("d-none")

    $.ajax({
      url: $link.attr("href"),
      method: "patch",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #handleMarkChannelAsReadClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)

    const $counter = this.#activeChannel.find(".js-counter")
    $counter.text(0)
    $counter.addClass("d-none")

    for (const item of this.#itemsWrapper.find(".font-weight-bold")) {
      const $item = $(item)
      $item.removeClass("font-weight-bold")
      $item.find("a").removeClass("text-dark").addClass("text-secondary")
    }

    this.#itemMarkAsRead.addClass("d-none")
    this.#itemMarkAsUnread.removeClass("d-none")

    $.ajax({
      url: $link.attr("href"),
      method: "patch",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #handleChannelClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)
    const $li = $link.parent()

    $.ajax({
      url: $link.attr("href"),
      dataType: "json",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      success: (data) => {
        this.#activeChannel.removeClass("js-active")
        this.#activeChannel.find("a").removeClass("bg-lighter")

        $li.addClass("js-active")
        $li.find("a").addClass("bg-lighter")

        this.#markChannelAsReadLink.attr("href", data.mark_channel_as_read_url)

        this.#renderItems(data.items)

        const itemData = data.item

        this.#itemTitle
          .text(itemData.title)
          .attr("href", itemData.link)

        this.#itemInfo.text(itemData.info)

        this.#itemMarkAsRead.attr("href", itemData.mark_as_read_url)
        this.#itemMarkAsUnread.attr("href", itemData.mark_as_unread_url)

        if (itemData.read) {
          this.#itemMarkAsRead.addClass("d-none")
          this.#itemMarkAsUnread.removeClass("d-none")
        } else {
          this.#itemMarkAsUnread.addClass("d-none")
          this.#itemMarkAsRead.removeClass("d-none")
        }

        this.#itemContent.html(itemData.description)
        if (!itemData.read) {
          this.#scrollToTop()
        }

        this.#activeChannel = $li
        this.#activeItem = this.#itemsWrapper.find(".js-active")
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #handleItemClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)
    const $li = $link.parent()

    $.ajax({
      url: $link.attr("href"),
      dataType: "json",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      success: (data) => {
        this.#activeItem.removeClass("js-active")
        this.#activeItem.find("a").removeClass("bg-lighter")

        $li.addClass("js-active")
        $li.find("a").addClass("bg-lighter")

        this.#itemTitle
          .text(data.title)
          .attr("href", data.link)

        this.#itemInfo.text(data.info)

        this.#itemMarkAsRead.attr("href", data.mark_as_read_url)
        this.#itemMarkAsUnread.attr("href", data.mark_as_unread_url)

        if (data.read) {
          this.#itemMarkAsRead.addClass("d-none")
          this.#itemMarkAsUnread.removeClass("d-none")
        } else {
          this.#itemMarkAsUnread.addClass("d-none")
          this.#itemMarkAsRead.removeClass("d-none")
        }

        this.#itemContent.html(data.description)
        this.#scrollToTop()

        this.#activeItem = $li
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #handleMarkAsReadClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)

    $.ajax({
      url: $link.attr("href"),
      method: "patch",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      success: (data) => {
        this.#itemMarkAsRead.addClass("d-none")
        this.#itemMarkAsUnread.removeClass("d-none")

        const $counter = this.#activeChannel.find(".js-counter")
        const count = Number($counter.text()) - 1
        $counter.text(count)
        if (count == 0) {
          $counter.addClass("d-none")
        }

        this.#activeItem.removeClass("font-weight-bold")
        this.#activeItem.find("a").removeClass("text-dark").addClass("text-secondary")
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #handleMarkAsUnreadClick(e) {
    e.preventDefault()
    const $link = $(e.currentTarget)

    $.ajax({
      url: $link.attr("href"),
      method: "patch",
      beforeSend: () => {
        this.#errorMessage.addClass("d-none")
      },
      success: (data) => {
        this.#itemMarkAsUnread.addClass("d-none")
        this.#itemMarkAsRead.removeClass("d-none")

        const $counter = this.#activeChannel.find(".js-counter")
        const count = Number($counter.text()) + 1
        $counter.text(count)
        if (count != 0) {
          $counter.removeClass("d-none")
        }

        this.#activeItem.addClass("font-weight-bold")
        this.#activeItem.find("a").removeClass("text-secondary").addClass("text-dark")
      },
      error: () => {
        this.#errorMessage.removeClass("d-none")
      }
    })
  }

  #renderItems(items) {
    let html = ""

    for (let index = 0; index < items.length; index++) {
      const item = items[index]
      html += this.#itemTemplate.render({
        active: index == 0,
        item_url: item.item_url,
        title: item.title,
        read: item.read
      })
      html += "\n"
    }

    this.#itemsWrapper.html(html)
  }

  #scrollToTop() {
    if (!this.#isSmallDevice()) {
      return
    }
    this.#htmlBody.animate({ scrollTop: 0 }, 250)
  }

  #scrollToAnchor() {
    const topOffset = this.#anchor.offset().top
    const windowHeight = $(window).height()
    const scrollTo = topOffset

    this.#htmlBody.animate({ scrollTop: scrollTo }, 250)
  }

  #isSmallDevice() {
    return this.#scrollLink.is(":visible")
  }
}

$(() => {
  new App()
})
