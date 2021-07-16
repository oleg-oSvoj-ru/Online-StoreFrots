#!/usr/bin/coffee

PouchDB = require 'pouchdb'
express = require 'express'
app     = express()


#d ~/dbcouch/ -c ./dbcouch/config.json
app.use '/', require('express-pouchdb')(PouchDB)

app.listen 3000
