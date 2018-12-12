// Generated by CoffeeScript 1.10.0
(function() {
  var App,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  App = (function() {
    function App() {
      this._handleMarkAsUnreadClick = bind(this._handleMarkAsUnreadClick, this);
      this._handleMarkAsReadClick = bind(this._handleMarkAsReadClick, this);
      this._handleItemClick = bind(this._handleItemClick, this);
      this._handleChannelClick = bind(this._handleChannelClick, this);
      this._handleMarkChannelAsReadClick = bind(this._handleMarkChannelAsReadClick, this);
      this._handleMarkChannelsAsReadClick = bind(this._handleMarkChannelsAsReadClick, this);
      this._handleScrollLinkClick = bind(this._handleScrollLinkClick, this);
      var $itemTemplate;
      this.htmlBody = $('html, body');
      this.scrollLink = $('#scroll-link');
      this.anchor = $('#anchor');
      this.channelsWrapper = $('#channels-wrapper');
      this.itemsWrapper = $('#items-wrapper');
      this.markChannelsAsReadLink = $('#mark-channels-as-read-link');
      this.markChannelAsReadLink = $('#mark-channel-as-read-link');
      this.syncChannelLink = $('#sync-channel-link');
      this.itemTitle = $('#item-title');
      this.itemInfo = $('#item-info');
      this.itemContent = $('#item-content');
      this.itemMarkAsRead = $('.js-item-mark-as-read');
      this.itemMarkAsUnread = $('.js-item-mark-as-unread');
      $itemTemplate = $('#item-template');
      this.itemTemplate = Hogan.compile($itemTemplate.html());
      this.activeChannel = this.channelsWrapper.find('.js-active');
      this.activeItem = this.itemsWrapper.find('.js-active');
      this.scrollLink.on('click', this._handleScrollLinkClick);
      this.markChannelsAsReadLink.on('click', this._handleMarkChannelsAsReadClick);
      this.markChannelAsReadLink.on('click', this._handleMarkChannelAsReadClick);
      this.channelsWrapper.on('click', '.js-link', this._handleChannelClick);
      this.itemsWrapper.on('click', '.js-link', this._handleItemClick);
      this.itemMarkAsRead.on('click', this._handleMarkAsReadClick);
      this.itemMarkAsUnread.on('click', this._handleMarkAsUnreadClick);
    }

    App.prototype._handleScrollLinkClick = function() {
      return this._scrollToAnchor();
    };

    App.prototype._handleMarkChannelsAsReadClick = function(e) {
      var $counter, $item, $link, channel, i, item, j, len, len1, ref, ref1;
      e.preventDefault();
      $link = $(e.currentTarget);
      ref = this.channelsWrapper.find('.reader-item');
      for (i = 0, len = ref.length; i < len; i++) {
        channel = ref[i];
        $counter = $(channel).find('.js-counter');
        if (!$counter.length) {
          continue;
        }
        $counter.text(0);
        $counter.addClass('d-none');
      }
      ref1 = this.itemsWrapper.find('.font-weight-bold');
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        item = ref1[j];
        $item = $(item);
        $item.removeClass('font-weight-bold');
        $item.find('a').removeClass('text-dark').addClass('text-secondary');
      }
      this.itemMarkAsRead.addClass('d-none');
      this.itemMarkAsUnread.removeClass('d-none');
      return $.ajax({
        url: $link.attr('href'),
        method: 'patch'
      });
    };

    App.prototype._handleMarkChannelAsReadClick = function(e) {
      var $counter, $item, $link, i, item, len, ref;
      e.preventDefault();
      $link = $(e.currentTarget);
      $counter = this.activeChannel.find('.js-counter');
      $counter.text(0);
      $counter.addClass('d-none');
      ref = this.itemsWrapper.find('.font-weight-bold');
      for (i = 0, len = ref.length; i < len; i++) {
        item = ref[i];
        $item = $(item);
        $item.removeClass('font-weight-bold');
        $item.find('a').removeClass('text-dark').addClass('text-secondary');
      }
      this.itemMarkAsRead.addClass('d-none');
      this.itemMarkAsUnread.removeClass('d-none');
      return $.ajax({
        url: $link.attr('href'),
        method: 'patch'
      });
    };

    App.prototype._handleChannelClick = function(e) {
      var $li, $link;
      e.preventDefault();
      $link = $(e.currentTarget);
      $li = $link.parent();
      return $.ajax({
        url: $link.attr('href'),
        dataType: 'json',
        success: (function(_this) {
          return function(data) {
            var itemData;
            _this.activeChannel.removeClass('js-active');
            _this.activeChannel.find('a').removeClass('bg-lighter');
            $li.addClass('js-active');
            $li.find('a').addClass('bg-lighter');
            _this.markChannelAsReadLink.attr('href', data.mark_channel_as_read_url);
            _this.syncChannelLink.attr('href', data.sync_channel_url);
            _this._renderItems(data.items);
            itemData = data.item;
            _this.itemTitle.text(itemData.title).attr('href', itemData.link);
            _this.itemInfo.text(itemData.info);
            _this.itemMarkAsRead.attr('href', itemData.mark_as_read_url);
            _this.itemMarkAsUnread.attr('href', itemData.mark_as_unread_url);
            if (itemData.read) {
              _this.itemMarkAsRead.addClass('d-none');
              _this.itemMarkAsUnread.removeClass('d-none');
            } else {
              _this.itemMarkAsUnread.addClass('d-none');
              _this.itemMarkAsRead.removeClass('d-none');
            }
            _this.itemContent.html(itemData.description);
            if (!itemData.read) {
              _this._scrollToTop();
            }
            _this.activeChannel = $li;
            return _this.activeItem = _this.itemsWrapper.find('.js-active');
          };
        })(this)
      });
    };

    App.prototype._handleItemClick = function(e) {
      var $li, $link;
      e.preventDefault();
      $link = $(e.currentTarget);
      $li = $link.parent();
      return $.ajax({
        url: $link.attr('href'),
        dataType: 'json',
        success: (function(_this) {
          return function(data) {
            _this.activeItem.removeClass('js-active');
            _this.activeItem.find('a').removeClass('bg-lighter');
            $li.addClass('js-active');
            $li.find('a').addClass('bg-lighter');
            _this.itemTitle.text(data.title).attr('href', data.link);
            _this.itemInfo.text(data.info);
            _this.itemMarkAsRead.attr('href', data.mark_as_read_url);
            _this.itemMarkAsUnread.attr('href', data.mark_as_unread_url);
            if (data.read) {
              _this.itemMarkAsRead.addClass('d-none');
              _this.itemMarkAsUnread.removeClass('d-none');
            } else {
              _this.itemMarkAsUnread.addClass('d-none');
              _this.itemMarkAsRead.removeClass('d-none');
            }
            _this.itemContent.html(data.description);
            _this._scrollToTop();
            return _this.activeItem = $li;
          };
        })(this)
      });
    };

    App.prototype._handleMarkAsReadClick = function(e) {
      var $link;
      e.preventDefault();
      $link = $(e.currentTarget);
      return $.ajax({
        url: $link.attr('href'),
        method: 'patch',
        success: (function(_this) {
          return function(data) {
            var $counter, count;
            _this.itemMarkAsRead.addClass('d-none');
            _this.itemMarkAsUnread.removeClass('d-none');
            $counter = _this.activeChannel.find('.js-counter');
            count = Number($counter.text()) - 1;
            $counter.text(count);
            if (count === 0) {
              $counter.addClass('d-none');
            }
            _this.activeItem.removeClass('font-weight-bold');
            return _this.activeItem.find('a').removeClass('text-dark').addClass('text-secondary');
          };
        })(this)
      });
    };

    App.prototype._handleMarkAsUnreadClick = function(e) {
      var $link;
      e.preventDefault();
      $link = $(e.currentTarget);
      return $.ajax({
        url: $link.attr('href'),
        method: 'patch',
        success: (function(_this) {
          return function(data) {
            var $counter, count;
            _this.itemMarkAsUnread.addClass('d-none');
            _this.itemMarkAsRead.removeClass('d-none');
            $counter = _this.activeChannel.find('.js-counter');
            count = Number($counter.text()) + 1;
            $counter.text(count);
            if (count !== 0) {
              $counter.removeClass('d-none');
            }
            _this.activeItem.addClass('font-weight-bold');
            return _this.activeItem.find('a').removeClass('text-secondary').addClass('text-dark');
          };
        })(this)
      });
    };

    App.prototype._renderItems = function(items) {
      var html, i, index, item, len;
      html = '';
      for (index = i = 0, len = items.length; i < len; index = ++i) {
        item = items[index];
        html += this.itemTemplate.render({
          active: index === 0,
          item_url: item.item_url,
          title: item.title,
          read: item.read
        });
        html += '\n';
      }
      return this.itemsWrapper.html(html);
    };

    App.prototype._scrollToTop = function() {
      if (!this._isSmallDevice()) {
        return;
      }
      return this.htmlBody.animate({
        scrollTop: 0
      }, 250);
    };

    App.prototype._scrollToAnchor = function() {
      var scrollTo, topOffset, windowHeight;
      topOffset = this.anchor.offset().top;
      windowHeight = $(window).height();
      scrollTo = topOffset;
      return this.htmlBody.animate({
        scrollTop: scrollTo
      }, 250);
    };

    App.prototype._isSmallDevice = function() {
      return this.scrollLink.is(':visible');
    };

    return App;

  })();

  $(function() {
    return new App;
  });

}).call(this);
