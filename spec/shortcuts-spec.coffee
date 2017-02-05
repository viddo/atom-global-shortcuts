remote = require 'remote'
Shortcuts = require '../lib/shortcuts'

describe 'Shortcuts', ->
  beforeEach ->
    @shortcuts = new Shortcuts(remote.globalShortcut)

  afterEach ->
    remote.globalShortcut.unregisterAll()

  describe '.isRegistered', ->
    it 'returns null if given invalid input', ->
      expect(@shortcuts.isRegistered('')).toEqual(null)
      expect(@shortcuts.isRegistered('meh')).toEqual(null)
      expect(@shortcuts.isRegistered('ctrlOrCmdA')).toEqual(null)
      expect(@shortcuts.isRegistered('ctrl-AA')).toEqual(null)

    it 'returns if keystrokes is already taken', ->
      spyOn(remote.globalShortcut, 'isRegistered').andReturn(true)
      expect(@shortcuts.isRegistered('shift-cmd-M')).toEqual(true)
      expect(remote.globalShortcut.isRegistered).toHaveBeenCalledWith('shift+CmdOrCtrl+M')

    it 'returns if keystrokes is available', ->
      expect(@shortcuts.isRegistered('cmd-space')).toEqual(false)

  describe '.registerCommand', ->
    beforeEach ->
      @commandSpy = jasmine.createSpy('global-shortcuts:test')
      atom.commands.add('atom-workspace', 'global-shortcuts:test', @commandSpy)

    describe 'when given invalid input', ->
      beforeEach ->
        spyOn(console, 'warn')
        spyOn(remote.globalShortcut, 'register').andCallFake -> throw new Error()
        @result = @shortcuts.registerCommand('cmd-z', 'global-shortcuts:test')

      it 'does not register command', ->
        expect(@shortcuts.isRegistered('cmd-z')).toEqual(false)

      it 'result is false', ->
        expect(@result).toBe(false)

      it 'result is false', ->
        expect(console.warn).toHaveBeenCalled()
        expect(console.warn.calls[0].args[0]).toContain('CmdOrCtrl+z')
        expect(console.warn.calls[0].args[0]).toContain('cmd-z')

    describe 'when given valid input', ->
      beforeEach ->
        spyOn(remote.globalShortcut, 'register').andCallThrough()
        @result = @shortcuts.registerCommand('shift-cmd-M', 'global-shortcuts:test')

      it 'register the command', ->
        expect(@shortcuts.isRegistered('shift-cmd-M')).toEqual(true)

      it 'result is true', ->
        expect(@result).toBe(true)

      describe 'when shortcut is triggered', ->
        beforeEach ->
          # the callback when keystrokes is hit
          expect(@commandSpy).not.toHaveBeenCalled()
          remote.globalShortcut.register.calls[0].args[1]()

        it 'triggers the command', ->
          expect(@commandSpy).toHaveBeenCalled()

  describe '.unregister', ->
    beforeEach ->
      spyOn(remote.globalShortcut, 'register').andReturn(true)
      @shortcuts.registerCommand('shift-cmd-M', 'global-shortcuts:test')
      expect(@shortcuts.registered.length).not.toEqual(0)

      spyOn(remote.globalShortcut, 'unregister')
      @shortcuts.unregister(@shortcuts.registered[0])

    it 'calls unregister with accelerator', ->
      expect(remote.globalShortcut.unregister).toHaveBeenCalledWith('shift+CmdOrCtrl+M')

    it 'removes item from list', ->
      expect(@shortcuts.registered.length).toEqual(0)

  describe '.unregisterAll', ->
    beforeEach ->
      spyOn(remote.globalShortcut, 'unregisterAll')
      @shortcuts.unregisterAll()

    it 'calls unregisterAll', ->
      expect(remote.globalShortcut.unregisterAll).toHaveBeenCalled()

  describe '.dispose', ->
    beforeEach ->
      @shortcuts.registered.push {}
      spyOn(remote.globalShortcut, 'unregisterAll')
      @shortcuts.dispose()

    it 'calls unregisterAll', ->
      expect(remote.globalShortcut.unregisterAll).toHaveBeenCalled()

    it 'empties registered list', ->
      expect(@shortcuts.registered.length).toEqual(0)
