atomStream = require '../lib/atom-stream'

describe 'atomStream', ->
  describe 'when setting does not have any initial value', ->
    beforeEach ->
      @spy = jasmine.createSpy('onValue')
      atomStream(atom.config, 'observe', 'atom-stream-test.foobar').onValue(@spy);

      waitsFor =>
        @spy.calls.length is 1

    it 'returns a stream with no initial event', ->
      expect(@spy).toHaveBeenCalled()
      expect(@spy.calls[0].args[0]).toBeUndefined()

    it 'returned stream gets new values when config is updated', ->
      atom.config.set('atom-stream-test.foobar', 123)

      waitsFor =>
        @spy.calls.length is 2
      runs =>
        expect(@spy.calls[1].args[0]).toEqual(123)
        atom.config.set('atom-stream-test.foobar', 456)

      waitsFor =>
        @spy.calls.length is 3
      runs =>
        expect(@spy.calls[2].args[0]).toEqual(456)

  describe 'when setting has an value already', ->
    beforeEach ->
      atom.config.set('atom-stream-test.foobar', 123)
      @spy = jasmine.createSpy('onValue')
      atomStream(atom.config, 'observe', 'atom-stream-test.foobar').onValue(@spy);

      waitsFor =>
        @spy.calls.length is 1

    it 'creates a stream with the initial value as 1st event', ->
      expect(@spy).toHaveBeenCalled()
      expect(@spy.calls[0].args[0]).toEqual(123)
