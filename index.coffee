memFs = require('mem-fs')
editor = require('mem-fs-editor')

store = memFs.create()
fs = editor.create(store)

module.exports = (file, opts = {before: null, after: null, content: null}) ->
  throw "Please specify a file" unless file?

  if typeof file == "object"
    opts = file
    file = null

  throw "File #{file} does not exist" unless fs.exists(file)
  throw "Please specify a before or after string" unless opts.before? || opts.after?
  throw "Please specify something to insert into the file" unless opts.content?

  inputContents = fs.read(file)
  insert = if opts.before then "#{opts.content}\n$&" else "$&\n#{opts.content}"
  inputContents = inputContents.replace(new RegExp("(#{(opts.after || opts.before)})"), insert)
  fs.write(file, inputContents)
  fs.commit -> return
