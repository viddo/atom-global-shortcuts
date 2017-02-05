remote = require 'remote'
SelectCommandView = require '../lib/select-command-view'
RegisterKeystrokesView = require '../lib/register-keystrokes-view'

# Includes integration test for the general happy case, to make sure things works when put together
# Details should be tested in individual objects
describe 'global-shortcuts', ->

  beforeEach ->
    spyOn(remote.globalShortcut, 'register').andReturn(true)
    spyOn(console, 'error')
    @workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(@workspaceElement)

  afterEach ->
    # expect(console.error).not.toHaveBeenCalled()
    if console.error.calls.length > 0
      throw console.error.calls[0].args

  it 'package is lazy-loaded', ->
    expect(atom.packages.isPackageLoaded('global-shortcuts')).toBe(false)
    expect(atom.packages.isPackageActive('global-shortcuts')).toBe(false)

  describe 'when register-command is dispatched', ->
    beforeEach ->
      promise = atom.packages.activatePackage('global-shortcuts')
      @workspaceElement.dispatchEvent(new CustomEvent('global-shortcuts:register-command', bubbles: true))
      waitsForPromise ->
        promise

    afterEach ->
      atom.packages.deactivatePackage('global-shortcuts')

    it 'shows a modal to select commands', ->
      panels = atom.workspace.getModalPanels()
      expect(panels.length).toEqual(1)
      view = panels[0].getItem()
      expect(view instanceof SelectCommandView).toBe(true)
      expect(view.isVisible()).toBe(true)

    describe 'when selects a command', ->
      beforeEach ->
        panel = atom.workspace.getModalPanels()[0]
        @view = panel.getItem()
        @view.filterEditorView.getModel().setText('show-atom-window')
        @view.populateList()
        @view.confirmSelection()

      it 'removes the commands modal', ->
        expect(@view.isVisible()).toBe(false)

      it 'shows a modal set a key combination for command', ->
        panels = atom.workspace.getModalPanels()
        expect(panels.length).toEqual(1)
        view = panels[0].getItem()
        expect(view instanceof RegisterKeystrokesView).toBe(true)
        expect(view.isVisible()).toBe(true)

      describe 'when pressed a valid key combo and finally press enter', ->
        beforeEach ->
          expect(remote.globalShortcut.register).not.toHaveBeenCalled()
          spyOn(atom.notifications, 'addSuccess')

          element = atom.workspace.getModalPanels()[0].getItem()[0]
          element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('alt', target: element)
          element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('shift', alt: true, target: element)
          element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('space', alt: true, shift: true, target: element)
          element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('enter', target: element)

        it 'registers the global shortcut', ->
          expect(remote.globalShortcut.register).toHaveBeenCalled()
          expect(typeof remote.globalShortcut.register.calls[0].args[0]).toEqual('string')
          expect(typeof remote.globalShortcut.register.calls[0].args[1]).toEqual('function')

        it 'shows a success notification', ->
          expect(atom.notifications.addSuccess).toHaveBeenCalled()

        it 'removes the modal', ->
          panels = atom.workspace.getModalPanels()
          expect(panels.length).toEqual(0)

        describe 'when registered keycombo is triggered', ->
          beforeEach ->
            spyOn(atom, 'show')
            remote.globalShortcut.register.calls[0].args[1]()

          it 'should call registered command', ->
            expect(atom.show).toHaveBeenCalled()

    describe 'when package is desactivated', ->
      beforeEach ->
        atom.packages.deactivatePackage('global-shortcuts')

      it 'removes the modal panels', ->
        expect(atom.workspace.getModalPanels()).toEqual([])
