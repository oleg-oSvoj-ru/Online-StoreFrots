window.app = {}
startP = ()->
  nameV = decodeURI(location.pathname).split("/")[2]
  db.get(decodeURI(location.pathname).split("/")[2]).then (data)->
    window.app = new Vue
        el: '#produckt'
        data: 
            item    : data
            nameV   : nameV
            showImg : false
            img     : '001.webp'
            articulData: {}
        created: ->
            #@collection = @item.options[@position]['коллекция']
            #@getCollection()
            @getAction()
        methods:
            getAction: ()->
                db.query 'site/artikul',{ keys: @.item.produckt[0], group: false; reduce: false; include_docs: true;}
                    .then (data)->
                        console.dir data
                        a = {}
                        for item in data.rows
                            a[item.value.url] = item.doc
                            a[item.value.url].p = item.value.i
                        app.articulData = a


window.addEventListener "load", (event)->
    initStart startP
