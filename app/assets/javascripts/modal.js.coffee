window.modalShow = (htmlContent, title='title', form_id='', class_name='', width='') ->

  swalWithBootstrapButtons = Swal.mixin
    customClass:
      confirmButton: "btn btn-primary #{class_name}"
      cancelButton: "btn btn-default"
      popup: "offset-top"
    buttonsStyling: false

  swalWithBootstrapButtons.fire
    title: title
    html: htmlContent
    showCloseButton: true
    showCancelButton: true
    confirmButtonText: "Подтвердить"
    cancelButtonText: "Закрыть"
    reverseButtons: true
    width: width
    allowOutsideClick: false
    preConfirm: ->
      false
    preDeny: ->
      false
    didOpen: (popup) ->
      confirmBtn = popup.querySelector(".swal2-confirm")
      if confirmBtn?
        if form_id?
          confirmBtn.setAttribute("form", form_id)
        confirmBtn.setAttribute("type", "submit")


window.modalShowByResult = (result) ->
  swalWithBootstrapButtons = Swal.mixin
    customClass:
      popup: "offset-top"
    #   confirmButton: "btn btn-primary"
    #   cancelButton: "btn btn-default"
    buttonsStyling: false
    showCloseButton: true

  if result
    swalWithBootstrapButtons.fire
      title: "Успешно!"
      # text: "Операция выполнена."
      icon: "success"
      # confirmButtonText: "Ок"
      showConfirmButton: false
  else
    swalWithBootstrapButtons.fire
      title: "Ошибка"
      # text: "Операция отменена."
      icon: "error"
      # confirmButtonText: "Ок"
      showConfirmButton: false

  setTimeout ->
    Swal.close()
  , 850
