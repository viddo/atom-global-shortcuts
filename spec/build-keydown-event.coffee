# copied from https://github.com/atom/atom-keymap/blob/master/src/helpers.coffee
LowerCaseLetterRegex = /^[a-z]$/
buildKeydownEvent = (key, {ctrl, shift, alt, cmd, keyCode, target, location}={}) ->
  event = document.createEvent('KeyboardEvent')
  bubbles = true
  cancelable = true
  view = null

  key = key.toUpperCase() if LowerCaseLetterRegex.test(key)
  if key.length is 1
    keyIdentifier = "U+#{key.charCodeAt(0).toString(16)}"
  else
    switch key
      when 'ctrl'
        keyIdentifier = 'Control'
        ctrl = true
      when 'alt'
        keyIdentifier = 'Alt'
        alt = true
      when 'shift'
        keyIdentifier = 'Shift'
        shift = true
      when 'cmd'
        keyIdentifier = 'Meta'
        cmd = true
      else
        if key.length > 0
          keyIdentifier = key[0].toUpperCase() + key[1..]

  location ?= KeyboardEvent.DOM_KEY_LOCATION_STANDARD
  event.initKeyboardEvent('keydown', bubbles, cancelable, view, keyIdentifier, location, ctrl, alt, shift, cmd)
  if target?
    Object.defineProperty(event, 'target', get: -> target)
    Object.defineProperty(event, 'path', get: -> [target])
  Object.defineProperty(event, 'keyCode', get: -> keyCode)
  Object.defineProperty(event, 'which', get: -> keyCode)
  event

module.exports = buildKeydownEvent
