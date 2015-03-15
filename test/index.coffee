thora = require("../index.js")
memFs = require('mem-fs')
editor = require('mem-fs-editor')

describe "thora", ->

  context "insertIntoFile", ->
    context "with bad arguments", ->
      it "fails if no file is specified", ->
        fn = -> thora.insertIntoFile()
        expect(fn).to.throw(Error, /Please specify a file/)

      it "fails if file does not exist", ->
        fn = -> thora.insertIntoFile("fake_file.rb")
        expect(fn).to.throw(Error, /File fake_file.rb does not exist/)

      it "fails if nothing is specified to insert", ->
        fn = -> thora.insertIntoFile("./test/app/temp.rb")
        expect(fn).to.throw(Error, /Please specify something to insert into the file/)

      it "fails if a before or after string is not specified", ->
        fn = -> thora.insertIntoFile("./test/app/temp.rb", "Hello")
        expect(fn).to.throw(Error, /Please specify a before or after string/)

    context "with good, simple, arguments", ->

      beforeEach (done) ->
        store = memFs.create()
        fs = editor.create(store)

        file = "easy_temp"
        fs.copy("./test/app/#{file}.template.rb", "./test/app/#{file}.rb")
        fs.commit -> return done()

      afterEach -> fs = null

      it "inserts after regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)
        expected = fs.read("./test/app/easy_temp.after.rb")
        thora.insertIntoFile("./test/app/easy_temp.rb", "\nHello", after: "Second", ->
          result = fs.read("./test/app/easy_temp.rb")
          expect(expected).to.equal(result)
          fs.commit -> return done()
        )

      it "inserts before regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)
        expected = fs.read("./test/app/easy_temp.before.rb")
        thora.insertIntoFile("./test/app/easy_temp.rb", "Hello\n", before: "Second", ->
          result = fs.read("./test/app/easy_temp.rb")
          expect(expected).to.equal(result)
          fs.commit -> return done()
        )
