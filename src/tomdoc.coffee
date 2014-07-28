{ArgumentParser} = require 'argparse'

main = ->
  argParser = new ArgumentParser
    version: require('../package.json').version
    addHelp: true
    description: 'Generate TomDoc'

  # options like this:
  # argParser.addArgument([ '-d', '--dryReplace' ], action: 'storeTrue')
  # argParser.addArgument([ '-r', '--replace' ])
  argParser.addArgument(['path'])

  options = argParser.parseArgs()

  console.log options

module.exports = {main, search, replace, PathSearcher, PathScanner, PathReplacer}
