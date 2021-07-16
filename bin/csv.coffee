#!/usr/bin/coffee

PouchDB  = require 'pouchdb'
csv      = require 'csv-parser'
fs       = require 'fs'
path     = require 'path'
mime     = require 'mime'
{ exec } = require "child_process"
{ slugify } = require 'transliteration'
results  = {}
conf     = require '../etc/config'

docPatch = path.normalize(__dirname + '/../src/docs/_csv/')
imgParch = path.normalize(__dirname + '/../build/docs/_img/')
basePatch  = 'http://'+conf.db+':'+conf.port+'/'+conf.base+'/'
console.dir docPatch
imgG = {}
uploadTmp = []

db = new PouchDB(basePatch);

db.info().then (info)->
         console.log info

imgP = ()->
    console.log '///////////////////////////////////////////////////////////////////////'
    for own key, value of results
        results[value.id]._attachments     = {}
        results[value.id].images           = {}
        #console.dir key
        for item in value.artikul

            #console.log item
            i = 0
            if imgG[item]
                results[value.id].images[item] = []
                for img in imgG[item]
                    if img
                        #console.dir img
                        n = ''+i
                        for k  in [1..3-(''+i).length]
                            n = '0'+n
                        results[value.id].images[item].push n + '.webp'
                        results[value.id]._attachments[item + "/" + n + '.webp'] =
                                    content_type:   mime.getType    img
                                    data        :   fs.readFileSync(img)
                        i = i+1
        uploadTmp.push results[value.id]
    tttt()

tttt = ()->
        value = uploadTmp.shift()
        #value._attachments = {}
        console.dir value
        if !value
           console.dir uploadTmp
        else
            db.get( value.id, {attachments: false})
                .then (doc)->
                    #console.dir doc
                    value._rev = doc._rev
                    db.put(value)
                        .then (date)->
                            #console.dir date
                            tttt()
                .catch (err)->
                    console.dir err
                    value._id =  value.id
                    #console.dir value
                    db.put(value)
                        .then (date)->
                            #console.dir date
                            tttt()
                        .catch (err)->
                            console.dir err


    console.dir results
imgSearch = (art)->
    exec "find " + imgParch + " -name *" + art.toLowerCase() + "*", (error, stdout, stderr)->
        if error
            console.dir error
        if stdout
            #console.dir stdout
            imgG[art] = stdout.split("\n")
        if stderr
            console.dir stderr
        #console.dir imgG


fs.readdirSync( docPatch ).forEach (file)->
    if file[0] != "."
        fs.createReadStream(docPatch + file)
            .pipe csv({ separator: '\t' })
            .on 'data', (data) ->
                if data.property
                    data.property = data.property.split("|")
                else
                    data.property = []
                tmp = {}
                for item in data.property
                    item = item.split(":")
                    console.dir item
                    if item[0] and item[1] and item[0].trim().toLowerCase() not in ["кол-во мест","гарантийный срок","отв. д/монтажа","склад","старый артикул","color","интернет магазин","тип упаковки","логистика","ставка ндс"]
                        tmp[item[0].trim()] = item[1].trim()
                data.property = tmp
                data.group = data.group
                if data.options
                    data.options = data.options.split("|")
                else
                    data.options = []
                tmp = {}
                for item in data.options
                    console.dir item
                    item = item.trim()
                    if item
                        item = item.split(":")

                        if item[0] and item[1] and item[0].trim().toLowerCase() not in ["кол-во мест","гарантийный срок","отв. д/монтажа","склад","старый артикул","color","интернет магазин","тип упаковки","логистика","ставка ндс"]
                           a = item[0].trim()
                           #a[0] = a[0].toUpperCase()
                           tmp[a.toLowerCase()] = item[1].trim()
                           console.dir item
                #console.dir results[data.name]
                #console.dir data
                data.options = tmp
                data.defaultPosition = 0
                imgSearch data.artikul

                if data.artikul
                    if  results[data.id]
                        results[data.id].name.push         data.name
                        results[data.id].description.push  data.description
                        results[data.id].property.push     data.property
                        results[data.id].options.push      data.options
                        results[data.id].artikul.push      data.artikul
                        results[data.id].realPrice.push    data.realPrice
                        results[data.id].price.push        data.price
                        results[data.id].complekt.push     data.complekt
                    else
                        #console.dir data
                        results[data.id] = data

                        tmp = JSON.stringify data.name
                        results[data.id].name     = []
                        results[data.id].name.push  JSON.parse tmp.split('/').join('-')

                        tmp = JSON.stringify data.description
                        results[data.id].description     = []
                        results[data.id].description.push  JSON.parse tmp.split('/').join('-')

                        tmp = JSON.stringify data.property
                        results[data.id].property     = []
                        results[data.id].property.push  JSON.parse tmp.split('/').join('-')

                        tmp = JSON.stringify data.options
                        results[data.id].options     = []
                        results[data.id].options.push  JSON.parse tmp.split('/').join('-')

                        tmp =  JSON.stringify data.artikul
                        results[data.id].artikul      = []
                        results[data.id].artikul.push  JSON.parse  tmp

                        tmp =  JSON.stringify data.realPrice
                        results[data.id].realPrice    = []
                        results[data.id].realPrice.push JSON.parse  tmp

                        tmp =  JSON.stringify data.price
                        results[data.id].price        = []
                        results[data.id].price.push     JSON.parse  tmp

                        if not data.complekt
                            data.complekt = ''
                        tmp =  JSON.stringify data.complekt
                        results[data.id].complekt        = []
                        results[data.id].complekt.push     JSON.parse  tmp

                        if not data.barcode
                            data.barcode = ''
                        tmp =  JSON.stringify data.barcode
                        results[data.id].barcode        = []
                        results[data.id].barcode.push     JSON.parse  tmp

                        if not data.baseid
                            data.baseid = ''
                        tmp =  JSON.stringify data.baseid
                        results[data.id].baseid        = []
                        results[data.id].baseid.push     JSON.parse  tmp


            .on 'end', ->
                #console.log results

#console.dir results
setTimeout imgP, 10000
