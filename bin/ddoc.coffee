#!/usr/bin/coffee
PouchDB  = require 'pouchdb'
fs       = require 'fs'
mime     = require 'mime'
md5      = require 'js-md5'
path     = require 'path'
conf     = require '../etc/config'

attach = []
ddoccP = []
ddocc  = {}

db = {}



jsonT = (src)->
    #console.dir src
    tmp = eval(src)
    #console.dir tmp
    return tmp
pathSearch = (subDir, attachT)->
    fs.readdirSync( doccPatch + "/" + subDir).forEach (file)->
        if file[0] != "." #and file !='couchapp.json'
            tmpP = subDir.split("/").join("']['")[0..-5]
            if fs.statSync( doccPatch + "/" + subDir + file ).isDirectory()
                #console.log ">>>>> "+subDir + file
                if file == '_attachments' or attachT
                    pathSearch subDir + file + "/", true
                else
                    if subDir == ""
                        eval("ddocc['"+file+"']={}")
                    else
                        eval("ddocc['"+tmpP+"']['"+file+"']={}")
                    pathSearch subDir + file + "/", false
            else
                if attachT
                    if !ddocc._attachments
                         ddocc._attachments = {}
                    ddocc._attachments[(subDir + file).split('_attachments/').join("")] =
                            content_type:   mime.getType( doccPatch + subDir + file )
                            data        :   fs.readFileSync( doccPatch + subDir + file)
                else
                    str = fs.readFileSync(doccPatch + subDir + file).toString()

                    type = mime.getType( doccPatch + subDir + file )

                    if type in ['application/json']
                        file = path.parse(file).name
                        if subDir == ""
                            eval("ddocc['" + file + "']=jsonT(str);")
                        else
                            eval("ddocc['" + tmpP + "']['" + file + "']=jsonT(str);")
                    else
                        if type in ['application/javascript']
                            file = path.parse(file).name
                        if subDir == ""
                            eval("ddocc['" + file + "']=str")
                        else
                            eval("ddocc['" + tmpP + "']['" + file + "']=str")

#console.dir {}
#ddocc['views']['session']['map'] = ddocc.views.session.map.toString()

func2str = (doc,patch)->
    tmp = []
    for own key, value of doc
        tmp = JSON.parse(patch)
        tmp.push key
        if typeof(value) == 'function'
            #console.dir value
            value = value.toString()
            #console.dir value
            #console.dir tmp
            #console.log "ddocc"+JSON.stringify(tmp).split(",").join("][").split('"').join("'")+'="'+value+'"'
            str = "ddocc"+JSON.stringify(tmp).split(",").join("][").split('"').join("'") + '=value'
            #str = str.split('\n').join('').split('  ').join('')
            console.log str
            eval str
        if typeof(value) == 'object'
            #console.dir typeof(value)
            #console.dir value
            #console.dir tmp
            func2str value, JSON.stringify(tmp)


uploadDD = (cal)->
    db = new PouchDB(basePatch);

    db.info().then (info)->
         console.log info

    pathSearch('', false)
    console.log "/////////////////////////////////////////////////////////////////////////////////////////////"
    func2str(ddocc,'[]')

    if !ddocc._id
        tmp = doccPatch.split("/")
        ddocc._id = '_design/' + tmp[tmp.length - 2]
    else
        ddocc._id = ddocc._id.split('\n')[0]

    db.get(ddocc._id, {attachments: false})
        .then (doc)->
            #console.dir doc
            ddocc._rev = doc._rev

            db.put(ddocc)
                .then (date)->
                    console.dir date
                    cal()
        .catch (err)->
            console.dir err
            db.put(ddocc)
                .then (date)->
                    console.dir date
                    cal()


doccPatch = path.normalize(__dirname + '/../build/site/')
basePatch  = 'http://'+conf.db+':'+conf.port+'/'+conf.base+'/'
console.dir doccPatch
uploadDD ()->
    doccPatch = path.normalize(__dirname + '/../build/admin/')
    uploadDD ()->
         console.log 'final'
