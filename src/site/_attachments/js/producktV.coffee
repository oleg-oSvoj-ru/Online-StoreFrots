window.app = {}
startP = ()->
  nameV = decodeURI(location.pathname).split("/")[1]
  #db.get(decodeURI(location.pathname).split("/")[2]).then (data)->
  db.query 'site/patch', {"key" : decodeURI(location.pathname).split("/")[2],reduce: false,include_docs: true }
   .then (data)->
      prop={}
      for key,val of data.rows[0].doc.options
        console.log '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
        console.dir val
        for k,v of val
            console.log v
            console.log k
            if !prop[k]
               prop[k] = {}
            if !prop[k][v]
               prop[k][v] = []
            prop[k][v].push key
            #prop.push = v

      window.app = new Vue
        el: '#produckt'
        data: 
            item      : data.rows[0].doc
            plus       : !!Session.Doc.session.basket.val[data._id + '__' + @position]
            position: if data.rows[0]['value'] then data.rows[0]['value'] else data.rows[0].doc['defaultPosition']
            prop    : prop
            lastC   : {}
            nameV   : nameV
            lastB   : ""
            ignore  : ["кол-во мест","гарантийный срок","отв. д/монтажа","склад","старый артикул","color","интернет магазин","тип упаковки","логистика","ставка ндс"]
            collection: ""
            showP   : false
            showImg : false
            img     : '000.webp'
            collectionData : {}
            actionData: {}
            ratingData: {}
        created: ->
            @collection = @item.options[@position]['коллекция']
            @getCollection()
            @getAction()
            @getRating()
        methods:
            getCollection: ()->
                db.query 'site/options', {"key" : ["коллекция",decodeURI(@.collection)],reduce: false,include_docs: true}
                   .then (data)->
                        console.dir data
                        a = {}
                        for k,v of data.rows
                            if v.doc.name[v.value.i] != window.app.item.name[window.app.position]
                                a[v.value.url] = v
                        window.app.collectionData = a
            getAction: ()->
                keysTemp = [["*","Акция"],[@item.artikul[@position],"Акция"]]
                if +@item.realPrice[@position] > +@item.price[@position]
                    keysTemp.push ["скидка " + ((1 - @item.price[@position]/@item.realPrice[@position])*100).toFixed(0),"Акция"]
                db.query 'site/artikulBlog',{ keys: keysTemp, group: false; reduce: false; include_docs: true;}
                    .then (data)->
                        console.dir data
                        a = {}
                        for i,item of data.rows
                            a[item.doc.name[0]] = {"doc": item.doc, "i": 0}
                        window.app.actionData = a
                        console.dir window.app.actionData
            getRating: ()->
                db.query 'site/artikulBlog',{ keys:[["*","Отзывы"],[@item.artikul[@position],"Отзывы"]], group: false; reduce: false; include_docs: true;}
                    .then (data)->
                        console.dir data
                        a = {}
                        for i,item of data.rows
                            a[item.value._id] = {"doc": item.doc, "i": i}
                        window.app.ratingData = a
                        console.dir window.app.ratingData
            number_format: number_format
            cheked: (a,b,c)->
                if ""+a in b
                    @lastC[c] = b
                    return true
                else
                    return false
                @collection = @item.options[@position]['коллекция']

            checkedlast: (a)->
                b = []
                c = []
                for k,v of @lastC
                    if !(k == a)
                        if b.length > 0
                            c = b.filter (x)->
                                return v.includes x
                            b = c
                            c = []
                        else
                           b =  @lastC[k]
                @collection = @item.options[@position]['коллекция']
                return b

            chekedClick: (a,c)->
                b = []
                for n,i of @checkedlast c
                    if i in a
                        b.push i
                if b.length > 0
                   @position = b[0]
                else
                   @position = a[0]
                
                if c != @lastB
                    @lastB = c
                @collection = @item.options[@position]['коллекция']
                @._render()
                @getCollection()
                @getAction()
                @getRating()
            noValue: (a,b,c)->
                e = @cheked a,b,c
                d = @checkedlast c
                for f in b
                    if ""+f in d
                        return "Value"
                return "noValue"
            optionClick: (a)->
                @position = a
                @plus   = !!Session.Doc.session.basket.val[@item._id + '__' + @position]
                @showP = !@showP
                @img='000.webp'

            orderClick: (a)->
                if !(Session.Doc.session.basket.val[@item._id + '__' + @position] == undefined)
                     Session.Doc.session.basket.val[@item._id + '__' + @position].count++
                else
                    app.plus = true
                    Session.Doc.session.basket.val[@item._id + '__' + @position] = JSON.parse(JSON.stringify(@item))
                    Session.Doc.session.basket.val[@item._id + '__' + @position].count = 1
                    Session.Doc.session.basket.val[@item._id + '__' + @position].position = @position
                Basket.Save()
                Basket.app.count = Session.Doc.session.basket.count
                Basket.app.summ = Session.Doc.session.basket.summ


window.addEventListener "load", (event)->
    initStart startP
