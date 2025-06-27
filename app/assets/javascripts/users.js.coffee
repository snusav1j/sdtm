$ ->
  $(document).on 'click', '#popup-user-balance', (e) ->
    user_id = $(this).attr('data-user-id')
    $.ajax
      url: "/users/popup_balance_modal"
      dataType: "script"
      type: "GET"
      data:
        user_id: user_id

  $(document).on 'click', '.update-user-image', (e) ->
    user_id = $(this).attr('data-user-id')
    $.ajax
      url: "/users/user_image_modal"
      dataType: "script"
      type: "GET"
      data:
        user_id: user_id