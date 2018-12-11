class App
  constructor: ->
    @htmlBody              = $('html, body')
    @scrollLink            = $('#scroll-link')
    @anchor                = $('#anchor')
    @channelsWrapper       = $('#channels-wrapper')
    @itemsWrapper          = $('#items-wrapper')
    @markChannelAsReadLink = $('#mark-channel-as-read-link')
    @syncChannelLink       = $('#sync-channel-link')
    @itemTitle             = $('#item-title')
    @itemInfo              = $('#item-info')
    @itemContent           = $('#item-content')
    @itemMarkAsRead        = $('.js-item-mark-as-read')
    @itemMarkAsUnread      = $('.js-item-mark-as-unread')
    $itemTemplate          = $('#item-template')
    @itemTemplate          = Hogan.compile($itemTemplate.html())

    @activeChannel = @channelsWrapper.find('.js-active')
    @activeItem    = @itemsWrapper.find('.js-active')

    @scrollLink.on('click',                  this._handleScrollLinkClick)
    @channelsWrapper.on('click', '.js-link', this._handleChannelClick)
    @itemsWrapper.on('click',    '.js-link', this._handleItemClick)
    @itemMarkAsRead.on('click',              this._handleMarkAsReadClick)
    @itemMarkAsUnread.on('click',            this._handleMarkAsUnreadClick)

  _handleScrollLinkClick: =>
    this._scrollToAnchor()

  _handleChannelClick: (e) =>
    e.preventDefault()
    $link = $(e.currentTarget)
    $li   = $link.parent()

    $.ajax
      url: $link.attr('href')
      dataType: 'json'
      success: (data) =>
        @activeChannel.removeClass('js-active')
        @activeChannel.find('a').removeClass('bg-lighter')

        $li.addClass('js-active')
        $li.find('a').addClass('bg-lighter')

        @markChannelAsReadLink.attr('href', data.mark_channel_as_read_url)
        @syncChannelLink.attr('href', data.sync_channel_url)

        this._renderItems(data.items)

        itemData = data.item

        @itemTitle
          .text(itemData.title)
          .attr('href', itemData.link)

        @itemInfo.text(itemData.info)

        @itemMarkAsRead.attr('href', itemData.mark_as_read_url)
        @itemMarkAsUnread.attr('href', itemData.mark_as_unread_url)

        if itemData.read
          @itemMarkAsRead.addClass('d-none')
          @itemMarkAsUnread.removeClass('d-none')
        else
          @itemMarkAsUnread.addClass('d-none')
          @itemMarkAsRead.removeClass('d-none')

        @itemContent.html(itemData.description)
        this._scrollToTop() unless itemData.read

        @activeChannel = $li
        @activeItem    = @itemsWrapper.find('.js-active')

  _handleItemClick: (e) =>
    e.preventDefault()
    $link = $(e.currentTarget)
    $li   = $link.parent()

    $.ajax
      url: $link.attr('href')
      dataType: 'json'
      success: (data) =>
        @activeItem.removeClass('js-active')
        @activeItem.find('a').removeClass('bg-lighter')

        $li.addClass('js-active')
        $li.find('a').addClass('bg-lighter')

        @itemTitle
          .text(data.title)
          .attr('href', data.link)

        @itemInfo.text(data.info)

        @itemMarkAsRead.attr('href', data.mark_as_read_url)
        @itemMarkAsUnread.attr('href', data.mark_as_unread_url)

        if data.read
          @itemMarkAsRead.addClass('d-none')
          @itemMarkAsUnread.removeClass('d-none')
        else
          @itemMarkAsUnread.addClass('d-none')
          @itemMarkAsRead.removeClass('d-none')

        @itemContent.html(data.description)
        this._scrollToTop()

        @activeItem = $li

  _handleMarkAsReadClick: (e) =>
    e.preventDefault()
    $link = $(e.currentTarget)

    $.ajax
      url: $link.attr('href')
      method: 'patch'
      success: (data) =>
        @itemMarkAsRead.addClass('d-none')
        @itemMarkAsUnread.removeClass('d-none')

        $counter = @activeChannel.find('.js-counter')
        count    = Number($counter.text()) - 1
        $counter.text(count)
        $counter.addClass('d-none') if count == 0

        @activeItem.removeClass('font-weight-bold')
        @activeItem.find('a').removeClass('text-dark').addClass('text-secondary')

  _handleMarkAsUnreadClick: (e) =>
    e.preventDefault()
    $link = $(e.currentTarget)

    $.ajax
      url: $link.attr('href')
      method: 'patch'
      success: (data) =>
        @itemMarkAsUnread.addClass('d-none')
        @itemMarkAsRead.removeClass('d-none')

        $counter = @activeChannel.find('.js-counter')
        count    = Number($counter.text()) + 1
        $counter.text(count)
        $counter.removeClass('d-none') unless count == 0

        @activeItem.addClass('font-weight-bold')
        @activeItem.find('a').removeClass('text-secondary').addClass('text-dark')

  _renderItems: (items) ->
    html = ''

    for item, index in items
      html += @itemTemplate.render(
        active:   index == 0,
        item_url: item.item_url
        title:    item.title,
        read:     item.read
      )
      html += '\n'

    @itemsWrapper.html(html)

  _scrollToTop: ->
    return unless this._isSmallDevice()
    @htmlBody.animate(scrollTop: 0, 250)

  _scrollToAnchor: ->
    topOffset    = @anchor.offset().top
    windowHeight = $(window).height()
    scrollTo     = topOffset

    @htmlBody.animate(scrollTop: scrollTo, 250)

  _isSmallDevice: ->
    @scrollLink.is(':visible')



$ ->
  new App
