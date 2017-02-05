SelectCommandView = require '../lib/select-command-view'

describe 'SelectCommandView', ->
  beforeEach ->
    atom.commands.add 'atom-workspace', 'global-shortcuts:valid-atom-workspace', ->
    atom.commands.add '.workspace', 'global-shortcuts:valid-workspace', ->
    atom.commands.add '.not-available', 'global-shortcuts:invalid', ->

    spyOn(atom.workspace, 'addModalPanel').andCallThrough()
    @confirmSpy = jasmine.createSpy('confirm')
    @view = new SelectCommandView(@confirmSpy)

  it 'adds the view as modal panel', ->
    panels = atom.workspace.getModalPanels()
    expect(panels.length).toEqual(1)
    expect(panels[0].getItem()).toBe(@view)
    expect(panels[0].isVisible()).toBe(true)

  it 'renders all the commands but only those with target set to the workspace', ->
    expect(@view.find('.list-group').text()).toContain('Valid Workspace')
    expect(@view.find('.list-group').text()).toContain('Valid Atom Workspace')
    expect(@view.find('.list-group').text()).not.toContain('Invalid')

  describe 'when confirmed a selected command', ->
    beforeEach ->
      expect(@confirmSpy).not.toHaveBeenCalled()
      @view.confirmSelection()

    it 'calls the confirm callback with the selected command', ->
      expect(@confirmSpy).toHaveBeenCalled()
      expect(@confirmSpy).toHaveBeenCalledWith('pane:show-next-recently-used-item')

    it 'cancels the view', ->
      expect(@view.isVisible()).toBe(false)
      expect(atom.workspace.getModalPanels()).toEqual []

  describe 'when cancelled', ->
    beforeEach ->
      @view.cancel()

    it 'destroys the panel', ->
      expect(atom.workspace.getModalPanels()).toEqual []
