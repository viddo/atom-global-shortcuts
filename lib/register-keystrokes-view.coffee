{View} = require 'space-pen'
_ = require 'underscore-plus'
R = require 'ramda'
Bacon = require 'baconjs'
atomStream = require './atom-stream'

module.exports =
class RegisterKeystrokesView extends View

  @content: ({commandName}) ->
    @div =>
      @div class: 'block', =>
        @input class: 'inline-block global-shortcuts-input', outlet: 'input'
        @span class: 'inline-block icon icon-zap text-subtle', "Choose key combo for"
        @span class: 'inline-block', "#{_.humanizeEventName(commandName)}"
      @div class: 'block', =>
        @span class: 'inline-block icon icon-keyboard text-subtle'
        @span class: 'inline-block', outlet: 'keystrokes', '<waiting for keys>'
      @div class: 'block', =>
        @span class: 'inline-block icon icon-question text-subtle'
        @span class: 'inline-block text-highlight', outlet: 'info', "press the key combo you'd like as shortcut ☜(ﾟヮﾟ☜)"

  initialize: ({@commandName, @shortcuts}) ->
    @sideEffects = []
    @panel = atom.workspace.addModalPanel(item: this)

    matchStream = atomStream(atom.keymaps, 'onDidMatchBinding')
    partiallyMatchStream = atomStream(atom.keymaps, 'onDidPartiallyMatchBindings')
    availableStream = atomStream(atom.keymaps, 'onDidFailToMatchBinding')

    allKeystrokesStream = Bacon.mergeAll(matchStream, partiallyMatchStream, availableStream).map('.keystrokes')
      .skip(1) # skip first due to enter key from previous view being triggered otherwise
    escapeStream = allKeystrokesStream.filter(R.equals('escape'))
    keystrokesStream = allKeystrokesStream.filter (keystrokes) ->
      switch keystrokes 
        when 'enter' then false
        when 'escape' then false
        else true

    alreadyRegisteredProp = keystrokesStream.map(@shortcuts.isRegistered).toProperty(false)
    incompleteProp = alreadyRegisteredProp.map(R.equals(null))

    rejectEnter = ({keystrokes}) -> keystrokes isnt 'enter'
    takenProp = Bacon.update false,
      [matchStream.filter(rejectEnter)], -> true
      [availableStream.filter(rejectEnter), alreadyRegisteredProp], (..., registered) -> registered is true

    validProp = Bacon.combineWith incompleteProp, takenProp, (incomplete, taken) -> !incomplete and !taken

    @sideEffects.push Bacon.onValues keystrokesStream, validProp, incompleteProp, takenProp,
      (keystrokes, valid, incomplete, taken) =>
        @keystrokes.text("#{_.humanizeKeystroke(keystrokes)}")
        switch
          when valid
            @setKeystrokesClass('highlight-success')
            @setInfo('OK! hit <ENTER> to save! ヽ(^。^)ノ', 'text-highlight')
          when incomplete
            @setKeystrokesClass('highlight-warning')
            @setInfo("almost there, keep typing! (^_^)", 'text-highlight')
          when taken
            @setKeystrokesClass('highlight-error')
            @setInfo("sorry, but it's already used… try another (╯°□°）╯︵ ┻━┻", 'text-warning')

    enterStream = allKeystrokesStream.filter(R.equals('enter')).filter(validProp)
    @sideEffects.push keystrokesStream.sampledBy(enterStream).onValue (keystrokes) =>
      if @shortcuts.registerCommand(keystrokes, @commandName)
        @cancel()
      else
        @setKeystrokesClass('highlight-error')
        @setInfo("could not save the shortcut for some reason ┐('～`；)┌", 'text-error')

    @sideEffects.push escapeStream.onValue =>
      @cancel()

    @input.on 'blur', => @cancel()
    @input.focus()

  setInfo: (str, className='') ->
    @info.text(" #{str}")
    @info.attr('class', "inline-block #{className}")

  setKeystrokesClass: (className) ->
    @keystrokes.attr('class', "inline-block #{className}")

  cancel: ->
    @input.off('blur')
    @sideEffects.forEach (unsub) -> unsub()
    @panel.destroy()
