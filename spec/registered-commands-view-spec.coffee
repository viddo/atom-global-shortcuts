remote = require 'remote'
Shortcuts = require '../lib/shortcuts'
RegisteredCommandsView = require '../lib/registered-commands-view'

globalShortcut = remote.require('global-shortcut')

describe 'RegisteredCommandsView', ->
  beforeEach ->
    @workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(@workspaceElement)

    @shortcuts = new Shortcuts(globalShortcut)

  describe 'when there are no shortcuts registered', ->
    beforeEach ->
      @view = new RegisteredCommandsView(@shortcuts)

    it 'adds the view as modal panel', ->
      panels = atom.workspace.getModalPanels()
      expect(panels.length).toEqual(1)
      expect(panels[0].getItem()).toBe(@view)
      expect(panels[0].isVisible()).toBe(true)

    it 'renders the empty message', ->
      expect(@view.text()).toContain('No shortcuts registered')

  describe 'when there is at least one registered command', ->
    beforeEach ->
      expect(@shortcuts.registerCommand('ctrl-shift-M', 'global-shortcuts:show-atom-window')).toBe(true)
      # need to re-instantiate
      @view = new RegisteredCommandsView(@shortcuts)

    afterEach ->
      @shortcuts.unregisterAll()

    it 'renders all the registered shortcuts', ->
      expect(@view.find('.list-group').text()).toContain('Show Atom Window')

    describe 'when confirmed a selected item', ->
      beforeEach ->
        spyOn(@shortcuts, 'unregister')
        @view.confirmSelection()

      it 'calls the confirm callback with the selected command', ->
        expect(@shortcuts.unregister).toHaveBeenCalled()
        expect(@shortcuts.unregister).toHaveBeenCalledWith(@shortcuts.registered[0])

      it 'cancels the view', ->
        expect(@view.isVisible()).toBe(false)
        expect(atom.workspace.getModalPanels()).toEqual []

    describe 'when cancelled', ->
      beforeEach ->
        @view.cancel()

      it 'destroys the panel', ->
        expect(atom.workspace.getModalPanels()).toEqual []
