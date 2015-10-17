{SelectListView, $$} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

module.exports =
class RegisteredCommandsView extends SelectListView

  initialize: (@shortcuts) ->
    super

    @setItems(@shortcuts.registered)
    if @shortcuts.registered.length isnt 0
      @setLoading('Press <enter> to unregister a selected command')

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  getFilterKey: ->
    'commandName'

  viewForItem: ({commandName, keystrokes}) ->
    return $$ ->
      @li =>
        @div class: 'pull-right', =>
          @kbd class: 'key-binding pull-right', _.humanizeKeystroke(keystrokes)
        @span _.humanizeEventName(commandName)

  getEmptyMessage: (itemCount, filteredItemCount) ->
    if itemCount is 0
      'No shortcuts registered yet, use global-shortcuts:register-shortcut command!'
    else
      'No registered commands found with current filter'

  confirmed: (item) ->
    @shortcuts.unregister(item)
    @cancel()

  cancelled: ->
    @panel.destroy()
