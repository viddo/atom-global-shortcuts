remote = require 'remote'
Shortcuts = require '../lib/shortcuts'
RegisterKeystrokesView = require '../lib/register-keystrokes-view'

describe 'RegisterKeystrokesView', ->
  beforeEach ->
    # required for keydown events to trigger
    @workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(@workspaceElement)

    @shortcuts = new Shortcuts(remote.globalShortcut)
    spyOn(@shortcuts, 'registerCommand')

    @view = new RegisterKeystrokesView(
      commandName: 'global-shortcuts:test'
      shortcuts: @shortcuts
    )
    @element = @view[0]

    # should be ignored, is required to not trigger a enter keydown event from previous view
    @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('m', ctrl: true, shift: true, target: @element)

  it 'adds the view as modal panel', ->
    panels = atom.workspace.getModalPanels()
    expect(panels.length).toEqual(1)
    expect(panels[0].getItem()).toBe(@view)
    expect(panels[0].isVisible()).toBe(true)

  it 'displays hint message to press keys', ->
    expect(@view.keystrokes.text()).toContain('waiting')

  it 'it renders the last keycombo typed', ->
    @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('s', target: @element)
    expect(@view.keystrokes.text()).toContain('S')

    @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('a', target: @element)
    expect(@view.keystrokes.text()).toContain('A')

    @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('m', ctrl: true, shift: true, target: @element)
    expect(@view.keystrokes.text()).toContain('⌃⇧M')

  it 'cancels on <esc>', ->
    @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('escape', target: @element)
    expect(atom.workspace.getModalPanels()).toEqual []

  describe 'when have typed an available key combo', ->
    beforeEach ->
      @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('M', ctrl: true, shift: true, target: @element)

    describe 'when press enter', ->
      describe 'when registration worked', ->
        beforeEach ->
          @shortcuts.registerCommand.andReturn(true)
          @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('enter', target: @element)
          expect(@shortcuts.registerCommand).toHaveBeenCalled()
          expect(@shortcuts.registerCommand).toHaveBeenCalledWith('ctrl-shift-M', 'global-shortcuts:test')

        it 'cancels the view', ->
          expect(atom.workspace.getModalPanels()).toEqual []

      describe 'when registration fails for whatever reason', ->
        beforeEach ->
          @shortcuts.registerCommand.andReturn(false)
          @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('enter', target: @element)

        it 'inform that it failed', ->
          expect(@view.info.text()).toContain('could not save')

  describe 'when have typed already taken key combo', ->
    beforeEach ->
      @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('P', ctrl: true, shift: true, target: @element)

    it 'inform that it is taken', ->
      expect(@view.info.text()).toContain('sorry')

    it 'disables enter', ->
      @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent('enter', target: @element)
      expect(@shortcuts.registerCommand).not.toHaveBeenCalled()

  describe 'when typing a keycombo (i.e. not done)', ->
    beforeEach ->
      @element.dispatchEvent atom.keymaps.constructor.buildKeydownEvent([], ctrl: true, target: @element)

    it 'informs to keep going', ->
      expect(@view.info.text()).toContain('almost there')

  describe 'when blur view', ->
    beforeEach ->
      waitsFor =>
        document.activeElement is @view.input[0]
      runs ->
        document.body.focus()

    it 'destroys the panel', ->
      expect(atom.workspace.getModalPanels()).toEqual []

  describe 'when cancelled', ->
    beforeEach ->
      @view.cancel()

    it 'destroys the panel', ->
      expect(atom.workspace.getModalPanels()).toEqual []
