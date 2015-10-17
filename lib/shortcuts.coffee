_ = require 'underscore-plus'

module.exports =
class Shortcuts

  constructor: (@globalShortcut) ->
    @registered = []

  isRegistered: (keystrokes) =>
    try
      @globalShortcut.isRegistered(@accelerator(keystrokes))
    catch
      null #aka don't know

  registerCommand: (keystrokes, commandName) ->
    didRegister =
      try
        @globalShortcut.register @accelerator(keystrokes), ->
          atom.commands.dispatch(atom.views.getView(atom.workspace), commandName)
      catch
        false

    if didRegister
      @registered.push(
        commandName: commandName
        keystrokes: keystrokes
      )
      atom.notifications.addSuccess "Global shortcut set for command!", {
        detail: """
          #{_.humanizeKeystroke(keystrokes)} will trigger #{commandName}!
          Remove shortcuts using global-shortcuts:unregister-all command
        """
      }

    return didRegister

  unregisterAll: ->
    @globalShortcut.unregisterAll()
    @registered = []

  dispose: ->
    @unregisterAll()

  accelerator: (keystrokes) ->
    keystrokes.replace(/-/g, '+').replace('cmd', 'CmdOrCtrl')
