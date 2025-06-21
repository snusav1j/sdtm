  # .multi-selector-block{ data: { type: "number", form_name: 'parfum_recipe', show_items_block: 'true', select_name: 'drops_count' } }
  #   = select_tag :fruit, options_for_select([['Апельсин', 'orange'], ['Лимон', 'lemon'], ['Яблоко', 'apple']], 'lemon'), class: 'form-control', multiple: true

# Глобальное объявление плагина
(($) ->

  $.fn.multipleSelect = ->
    select = $('select[multiple]')
    options = select.find('option')
    show_items_block = select.parents('div.multi-selector-block').attr('data-show-items-block') == 'true'
    form_name = select.parents('div.multi-selector-block').attr('data-form-name')
    select_name = select.parents('div.multi-selector-block').attr('data-select-name')

    div = $('<div />').addClass('selectMultiple')
    active = $('<div />').addClass('active-list')
    list = $('<ul />')
    placeholder = select.data('placeholder')
    span = $('<span />').text(placeholder).appendTo(active)
    
    options.each ->
      text = $(this).text()
      if $(this).is(':selected')
        active.append($('<a />').attr('data-value', $(this).val()).html('<em class="selected-item" >' + text + '</em><i class="remove-selected-item"></i>'))
        span.addClass('hide')
      else
        list.append($("<li />").html(text).addClass('active-list-item').attr('data-value', $(this).val()))
    
    active.append($('<div />').addClass('arrow'))
    div.append(active).append(list)
    select.wrap(div)

)(jQuery)

# События вне плагина, тоже глобальные — оставляем без изменений
$(document).on 'click', '.selectMultiple ul li', (e) ->

  select = $(this).parent().parent()
  show_items_block = select.parents('div.multi-selector-block').attr('data-show-items-block') == 'true'
  form_name = select.parents('div.multi-selector-block').attr('data-form-name')
  select_name = select.parents('div.multi-selector-block').attr('data-select-name')
  type = select.parents('div.multi-selector-block').attr('data-type')
  li = $(this)
  if not select.hasClass('clicked')
    select.addClass('clicked')
    li.prev().addClass('beforeRemove')
    li.next().addClass('afterRemove')
    li.addClass('remove')
    a = $('<a />').addClass('notShown').html('<em class="selected-item">' + li.text() + '</em><i class="remove-selected-item" ></i>').attr('data-value', li.attr('data-value')).hide().appendTo(select.children('div'))

    if show_items_block
      multi_select_item_block = $('<div />').addClass('multi-select-item').attr('data-value', li.attr('data-value')).html($("<div data-label-name='#{li.text()}'/>").html(li.text()))
      input_for_multi_select_block = "<input type='#{type}' step='0.01' class='#{form_name}_input' name='#{form_name}[#{select_name}][#{li.attr('data-value')}]' type='' value='' autocomplete='off'>"
      multi_select_item_block.append(input_for_multi_select_block)
      $('.multi-select-items').append(multi_select_item_block)

    a.slideDown(200, ->
      setTimeout( ->
        a.addClass('shown')
        select.children('div').children('span').addClass('hide')
        select.find("option[value=" + li.attr('data-value') + "]").prop('selected', true)
      , 250)
    )
    setTimeout( ->
      if li.prev().is(':last-child')
        li.prev().removeClass('beforeRemove')
      if li.next().is(':first-child')
        li.next().removeClass('afterRemove')
      setTimeout( ->
        li.prev().removeClass('beforeRemove')
        li.next().removeClass('afterRemove')
      , 100)
      li.slideUp(400, ->
        li.remove()
        select.removeClass('clicked')
      )
    , 300)

$(document).on 'click', '.selectMultiple > div a', (e) ->
  select = $(this).parent().parent()
  show_items_block = select.parents('div.multi-selector-block').attr('data-show-items-block') == 'true'
  form_name = select.parents('div.multi-selector-block').attr('data-form-name')
  select_name = select.parents('div.multi-selector-block').attr('data-select-name')

  self = $(this)
  self.removeClass().addClass('remove')
  select.addClass('open')
  setTimeout( ->
    self.addClass('disappear')
    setTimeout( ->
      self.animate
        width: 0
        height: 0
        padding: 0
        margin: 0
      , 150, ->
        li = $('<li />').attr('data-value', self.attr('data-value')).text(self.children('em').text()).addClass('notShown').appendTo(select.find('ul'))

        if show_items_block
          $("input[name='#{form_name}[#{select_name}][#{self.attr('data-value')}]']").parents('.multi-select-item').remove()

        li.slideDown(400, ->
          li.addClass('show')
          setTimeout( ->
            select.find("option[value=" + self.attr('data-value') + "]").prop('selected', false)
            if not select.find('option:selected').length
              select.children('div').children('span').removeClass('hide')
            li.removeClass().addClass('active-list-item')
          , 350)
        )
        self.remove()
    , 150)
  , 150)

$(document).on 'click', '.selectMultiple > .active-list > .arrow', (e) ->
  if !e.target.classList.contains('active-list')
    $('.selectMultiple').toggleClass('open')

$(document).on 'click', '.selectMultiple > .active-list', (e) ->
  if e.target.classList.contains('active-list')
    $('.selectMultiple').toggleClass('open')

$(window).on 'click', (e) ->
  if !(e.target.classList.contains('active-list') || e.target.classList.contains('arrow') || e.target.classList.contains('selected-item') || e.target.classList.contains('remove-selected-item') || e.target.classList.contains('active-list-item'))
    $('.selectMultiple').removeClass('open')
