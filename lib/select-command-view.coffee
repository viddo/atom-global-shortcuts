{SelectListView, $$} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

module.exports =
class SelectCommandView extends SelectListView

  initialize: (@confirm) ->
    super

    commandNames = []
    for commandName, listeners of atom.commands.getSnapshot()
      valid = switch listeners[0]?.selector
        when 'atom-workspace' then true
        when '.workspace' then true
        else false
      if valid
        commandNames.push(commandName)

    @setItems(commandNames)
    @setLoading('First, select a command to register you want to assign a global shortcut for')
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  viewForItem: (commandName) ->
    return $$ ->
      @li =>
        @span _.humanizeEventName(commandName)

  confirmed: (commandName) ->
    @confirm(commandName)
    @cancel()

  cancelled: ->
    @panel.destroy()
