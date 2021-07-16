window.app = {}
startP = ()->
  db.get(decodeURI(location.pathname).split("/")[3]).then (data)->
    window.app = new Vue
        el: '#produckt'
        data: 
            item : data
            plus : !!Session.Doc.session.basket.val[data._id]
        methods:
            orderClick: ()->
                if !(Session.Doc.session.basket.val[data._id] == undefined)
                    Session.Doc.session.basket.val[@item._id].count++
                else
                    app.plus = true
                    Session.Doc.session.basket.val[@item._id] = @item
                    Session.Doc.session.basket.val[@item._id].count = 1
                Basket.Save()
                Basket.app.count = Session.Doc.session.basket.count
                Basket.app.summ = Session.Doc.session.basket.summ

window.addEventListener "load", (event)->
    initStart startP
