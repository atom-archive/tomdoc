module.exports =
class Doc
  constructor: (@originalText) ->

  isPublic: ->
    /public|essential|extended/i.test(@status)

  isInternal: ->
    /internal/i.test(@status)

  isPrivate: ->
    not @isPublic() and not @isInternal()

  toJSON: ->
    {
      @summary
      @description
      @examples
      @status
      @arguments
      @delegation
      @returnValue
    }
