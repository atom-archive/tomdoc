_ = require 'underscore'
_.str = require 'underscore.string'
{deindent, getLinkMatch, leftTrimBlock} = require './utils'

Doc = require './doc'

# Public: Parses a comment
#
# Returns a {Doc}
parse = (comment) ->
  lines = leftTrimBlock(comment.replace(/\u0091/gm, '').split('\n'))
  doc = new Doc(lines.join("\n"))

  return doc unless lines?

  sections = lines.join("\n").split "\n\n"

  infoBlock = parseDescription(sections.shift())

  doc.status = infoBlock.status
  doc.description = description = infoBlock.description

  delegationMatch =  description.match(/\{Delegates to: (.+?)\}/)
  return doc if delegationMatch && doc.delegation = delegationMatch[1]

  current = sections.shift()

  while current
    if /^\w+\s+\-/.test(current)
      doc.arguments ?= []
      doc.arguments = parseArguments(current)

    else if /^\s*Examples/.test(current)
      doc.examples ?= []
      doc.examples = parseExamples(current, sections)

    else if /^\s*Returns/.test(current)
      doc.returnValue ?= []
      doc.returnValue = parseReturns(current)

    else
      description = description.concat "\n\n#{current}"

    current = sections.shift()

  summary = /((?:.|\n)*?[.#][\s$])/.exec(description)
  summary = summary[1].replace(/\s*#\s*$/, '') if summary
  doc.summary = _.str.clean(summary || description)
  doc.description = description
  doc

parseDescription = (section) ->
  if md = /([A-Z]\w+)\:((.|[\r\n])*)/g.exec(section)
    status: md[1]
    description: _.str.strip(md[2]).replace(/\r?\n/g, ' ')
  else
    status: 'Private'
    description: _.str.strip(section).replace(/\r?\n/g, ' ')

parseExamples = (section, sections) ->
  examples = []
  section = _.str.strip(section.replace(/Examples/, ''))
  examples.push(section) unless _.isEmpty(section)
  while _.first(sections)
    lines = sections.shift().split("\n")
    examples.push(deindent(lines).join("\n"))
  examples

parseReturns = (section) ->
  returns = []
  current = []
  in_hash = false

  lines = section.split("\n")
  _.each lines, (line) ->
    line = _.str.trim(line)

    if /^Returns/.test(line)
      in_hash = false
      returns.push
        type: getLinkMatch(line)
        description: line
      current = returns
    else if _.last(returns) and hash_match = line.match(/^:(\w+)\s*-\s*(.*)/)
      in_hash = true
      _.last(returns).options ?= []
      name = hash_match[1]
      description = hash_match[2]
      _.last(returns).options.push({name, description, type: getLinkMatch(line)})
    else if /^\S+/.test(line)
      if in_hash
        _.last(_.last(returns).options).description += " #{line}"
      else
        _.last(returns).description += "\n#{line}"

  returns

parseArguments = (section) ->
  args = []
  last_indent = null
  in_hash = false

  _.each section.split("\n"), (line) ->
    unless _.isEmpty(line)
      indent = line.match(/^(\s*)/)[0].length

      stripped_line = _.str.strip(line)

      if last_indent != null && indent >= last_indent && (indent != 0) && stripped_line.match(/^:\w+/) == null
        description = " " + stripped_line
        if in_hash
          _.last(_.last(args).options).description += description
        else
          _.last(args).description += description
      else
        arg = line.split(" - ")
        param = _.str.strip(arg[0])
        description = _.str.strip(arg[1])

        # it's a hash description
        param_match = param.match(/^:(\w+)$/)

        if param_match and _.last(args)?
          in_hash = true
          _.last(args).options ?= []
          name = param_match[1]
          _.last(args).options.push(name, description, type: getLinkMatch(line))
        else
          in_hash = false
          args.push(name: param, description: description, type: getLinkMatch(line))

      last_indent = indent

  args

module.exports = {parse}
