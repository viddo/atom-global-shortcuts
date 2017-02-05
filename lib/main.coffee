{CompositeDisposable} = require 'atom'
remote = require 'remote'
Shortcuts = require './shortcuts'
SelectCommandView = require './select-command-view'
RegisterKeystrokesView = require './register-keystrokes-view'
RegisteredCommandsView = require './registered-commands-view'

module.exports =

  activate: (state) ->
    @shortcuts = new Shortcuts(remote.globalShortcut)
    @disposables = new CompositeDisposable
    @disposables.add @shortcuts

    @disposables.add atom.commands.add 'atom-workspace', 'global-shortcuts:register-command', =>
      @view = new SelectCommandView (commandName) =>
        @view = new RegisterKeystrokesView({
          commandName: commandName
          shortcuts: @shortcuts
        })

    @disposables.add atom.commands.add 'atom-workspace', 'global-shortcuts:registered-commands', =>
      @view = new RegisteredCommandsView(@shortcuts)
    @disposables.add atom.commands.add 'atom-workspace', 'global-shortcuts:unregister-command', =>
      @view = new RegisteredCommandsView(@shortcuts)

    @disposables.add atom.commands.add 'atom-workspace', 'global-shortcuts:unregister-all', =>
      @shortcuts.unregisterAll()

    @disposables.add atom.commands.add 'atom-workspace', 'global-shortcuts:show-atom-window', ->
      atom.show()

  deactivate: ->
    @view?.cancel()
    @disposables.dispose()
    @disposables = null
