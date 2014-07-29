# TomDoc parser

Parse [tomdoc][tomdoc] with JavaScript / CoffeeScript.

## Usage

```coffee
TomDoc = require 'tomdoc'

docString = """
  Public: My awesome method that does stuff.

  It does things and stuff and even more things, this is the description.

  count - an {Int} representing count
  callback - a {Function} that will be called when finished

  Returns a {Bool}; true when it does the thing
"""
doc = TomDoc.parse(docString)
```

`doc` will be an object:

```coffee
{
  status: 'Public',
  summary: 'My awesome method that does stuff.'
  description: 'My awesome method that does stuff.\nIt does things and stuff and even more things, this is the description.',
  arguments: [{
    name: 'count',
    description: 'an {Int} representing count',
    type: 'Int'
  }, {
    name: 'callback',
    description: 'a {Function} that will be called when finished',
    type: 'Function'
  }],
  returnValue: [{
    type: 'Bool',
    description: 'Returns a {Bool}; true when it does the thing'
  }],
  originalText: """
    Public: My awesome method that does stuff.

    It does things and stuff and even more things, this is the description.

    count - an {Int} representing count
    callback - a {Function} that will be called when finished

    Returns a {Bool}; true when it does the thing
  """
}
```

The parser was pulled out of [biscotto][biscotto]


[tomdoc]:http://tomdoc.org
[biscotto]:https://github.com/atom/biscotto/tree/master/src/nodes
