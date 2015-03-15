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
      file = "easy_temp"

      beforeEach (done) ->
        store = memFs.create()
        fs = editor.create(store)

        fs.copy("./test/app/#{file}.template.rb", "./test/app/#{file}.rb")
        fs.commit -> return done()

      afterEach -> fs = null

      it "inserts after regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)
        expected = fs.read("./test/app/#{file}.after.rb")
        thora.insertIntoFile("./test/app/#{file}.rb", "\nHello", after: "Second", ->
          result = fs.read("./test/app/#{file}.rb")
          expect(expected).to.equal(result)
          fs.commit -> return done()
        )

      it "inserts before regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)
        expected = fs.read("./test/app/#{file}.before.rb")
        thora.insertIntoFile("./test/app/#{file}.rb", "Hello\n", before: "Second", ->
          result = fs.read("./test/app/#{file}.rb")
          expect(expected).to.equal(result)
          fs.commit -> return done()
        )

    context "with good, complex, arguments", ->
      file = "temp"

      beforeEach (done) ->
        store = memFs.create()
        fs = editor.create(store)

        fs.copy("./test/app/#{file}.template.rb", "./test/app/#{file}.rb")
        fs.commit -> return done()

      afterEach -> fs = null

      it "inserts after regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)

        inputFile = fs.read("./test/app/input.txt")
        thora.insertIntoFile("./test/app/#{file}.rb", "\n#{inputFile}", after: "class Application \< Rails::Application", ->
          expected = fs.read("./test/app/#{file}.after.rb")
          result = fs.read("./test/app/#{file}.rb")

          expect(expected).to.equal(result)
          fs.commit -> return done()
        )

      it "inserts before regex", (done) ->
        store = memFs.create()
        fs = editor.create(store)

        inputFile = fs.read("./test/app/input.txt")
        thora.insertIntoFile("./test/app/#{file}.rb", "\n#{inputFile}\n", before: "^\\s{2}end", ->
          expected = fs.read("./test/app/#{file}.before.rb")
          result = fs.read("./test/app/#{file}.rb")

          expect(expected).to.equal(result)
          fs.commit -> return done()
        )
