memFs = require('mem-fs')
editor = require('mem-fs-editor')


module.exports =
  insertIntoFile: (file, content, opts = {before: null, after: null}, callback) ->
    store = memFs.create()
    fs = editor.create(store)
    throw new Error "Please specify a file" unless file?
    throw new Error "File #{file} does not exist" unless fs.exists(file)
    throw new Error "Please specify something to insert into the file" unless content?
    throw new Error "Please specify a before or after string" unless opts.before? || opts.after?

    inputContents = fs.read(file)
    insert = if opts.before then "#{content}$&" else "$&#{content}"
    inputContents = inputContents.replace(new RegExp("(#{(opts.after || opts.before)})"), insert)
    fs.write(file, inputContents)
    fs.commit -> return callback()
