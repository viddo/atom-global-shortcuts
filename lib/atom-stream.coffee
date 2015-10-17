Bacon = require 'baconjs'

module.exports = (obj, funcName, args...) ->
  return Bacon.fromBinder (sink) ->
    args.push(sink)
    disposable = obj[funcName].apply(obj, args)
    return () -> disposable.dispose()
