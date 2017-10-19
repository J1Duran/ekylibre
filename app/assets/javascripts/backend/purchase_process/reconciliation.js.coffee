((E, $) ->
  'use strict'

  $(document).on 'click', '#showReconciliationModal', (event) ->
    event.stopPropagation()
    E.reconciliation.displayReconciliationModal(event, {})

  $(document).on 'click', '#showItemReconciliationModal', (event) ->
    event.stopPropagation()
    itemFieldId = $(event.target).closest('.form-field').find('.purchase-item-attribute').attr('id')
    E.reconciliation.displayReconciliationModal(event, { reconciliate_item: true, item_field_id: itemFieldId })

  $(document).ready ->
    if $('#purchase_process_reconciliation').length > 0
      $('#main .heading-toolbar').addClass('purchase-process-reconciliation')

  $(document).on 'change', '#purchase_process_reconciliation .model-checkbox', (event) ->
    checked = $(event.target).is(':checked')
    $(event.target).closest('.model').find('.item-checkbox').prop('checked', checked)

  $(document).on 'click', '#purchase_process_reconciliation .valid-modal', (event) ->
    validButton = $(event.target)
    modal = $(event.target).closest('#purchase_process_reconciliation')

    if validButton.attr('data-item-reconciliation') != undefined
      E.reconciliation.reconciliateItems(modal)
    else
      E.reconciliation.createLinesWithSelectedItems(modal, event)
      #modelsCheckboxes = $(modal).find('.model-checkbox:checked')
      #itemsCheckboxes = $(modal).find('.item-checkbox:checked')

      #purchasesAttributesIds = []
      #$(modelsCheckboxes).map (index, checkbox) =>
      #  purchasesAttributesIds.push({id: $(checkbox).attr('data-id')})

      #purchasesItemsAttributesIds = []
      #$(itemsCheckboxes).map (index, checkbox) =>
      #  purchasesItemsAttributesIds.push({id: $(checkbox).attr('data-id')})

      #jsonPurchasesAttributes = JSON.stringify(purchasesAttributesIds)
      #jsonPurchasesItemsAttributes = JSON.stringify(purchasesItemsAttributesIds)

      #purchasesAttributes = $('<input type="hidden" class="purchases-attributes" name="reception[purchases_attributes]" value="' + jsonPurchasesAttributes + '"/>')
      #purchasesItemsAttributes = $('<input type="hidden" class="purchase-items-attributes" name="reception[purchase_items_attributes]" value="' + jsonPurchasesItemsAttributes + '"/>')

      #$('.simple_form').prepend(purchasesAttributes)
      #$('.simple_form').prepend(purchasesItemsAttributes)

      #if $(modelsCheckboxes).length > 0 || $(itemsCheckboxes).length > 0
      #  $('.purchase-process-reconciliation .no-reconciliate-title').addClass('hidden')
      #  $('.no-reconciliate-state').addClass('hidden')

      #  $('.purchase-process-reconciliation .reconcile-title').removeClass('hidden')
      #  $('.reconcile-state').removeClass('hidden')

      #  $('.reconciliate-state').addClass('hidden')


    @reconciliationModal= new ekylibre.modal('#purchase_process_reconciliation')
    @reconciliationModal.getModal().modal 'hide'


  E.reconciliation =
    displayReconciliationModal: (event, datas) ->
      isPurchaseInvoiceForm = $(event.target).closest('.simple_form').hasClass('new_purchase_invoice')

      url = "/backend/purchase_process/reconciliation/purchase_orders_to_reconciliate"
      if isPurchaseInvoiceForm
        url = "/backend/purchase_process/reconciliation/receptions_to_reconciliate"
        datas['supplier'] = $('input[name="purchase_invoice[supplier_id]').val()

      $.ajax
        url: url
        data: datas
        success: (data, status, request) ->

          @reconciliationModal= new ekylibre.modal('#purchase_process_reconciliation')
          @reconciliationModal.removeModalContent()
          @reconciliationModal.getModalContent().append(data)
          @reconciliationModal.getModal().modal 'show'

    reconciliateItems: (modal) ->
      checkedItemId = $(modal).find('.item-checkbox:checked').attr('data-id')
      itemFieldId = $('.item-checkbox:checked').attr('data-item-field-id')

      if $('#purchase-orders').val() == "false"
        $("##{itemFieldId}").val(JSON.stringify([checkedItemId]))
      else
        $("##{itemFieldId}").val(checkedItemId)

    createLinesWithSelectedItems: (modal, event) ->
      itemsCheckboxes = $(modal).find('.item-checkbox:checked')

      itemsCheckboxes.each (index, itemCheckbox) ->
        variantType = $(itemCheckbox).closest('.item').attr('data-variant-type')
        buttonToClickSelector = $('table.list #items-footer .add-merchandise')

        if variantType == "service"
          buttonToClickSelector = $('table.list #items-footer .add-service')
        else if variantType == "cost"
          buttonToClickSelector = $('table.list #items-footer .add-cost')

        $(buttonToClickSelector).find('.add_fields').trigger('click')
        E.reconciliation._fillNewLineForm(itemCheckbox)


    _fillNewLineForm:  (itemCheckbox) ->
      lastLineForm = $('table.list .nested-fields .nested-item-form:last:visible')

      checkboxLine = $(itemCheckbox).closest('.item')
      variantId = $(checkboxLine).find('.variant').attr('data-id')
      variantLabel = $(checkboxLine).find('.variant').text()
      itemQuantity = $(checkboxLine).find('.item-value.quantity').text()

      $(lastLineForm).find('.item-block.merchandise .parcel-item-variant').first().selector('value', variantId)
      #$(lastLineForm).find('.item-block.merchandise .selector-value').val(variantId)
      # $(itemCheckbox).closest('.item').find('.item-value.quantity').text()
      $(lastLineForm).find('.nested-fields.storing-fields:first .storing-quantifier .storing-quantity').val(itemQuantity)

    _getCheckedItems: (modal, event) ->
      itemsCheckboxes = $(modal).find('.item-checkbox:checked')

      checkedItemsIds = []
      $(itemsCheckboxes).map (index, checkbox) =>
        checkedItemsIds.push({id: $(checkbox).attr('data-id')})

      checkedItemsIds


) ekylibre, jQuery
