window.app = {}
startO = ()->
    Basket.app.show = true
    Basket.app.order = true
    window.app = new Vue
        el: '.formOrder'
        data: 
            order : false #!!Session.Doc.session.basket.order
            name  : ""
            phone : "" 
            red   : false
        methods:
            sendClick: ()->
                console.dir [@name, @phone]
                if @name == "" or @phone == ""
                    @red = true
                else
                    @order = true
                    Session.Doc.session.basket.order = true
                    if Session.Doc.session.orders == undefined
                          Session.Doc.session.orders = []
                    Session.Doc.session.basket.name  = @name
                    Session.Doc.session.basket.phone = @phone
                    Session.Doc.session.basket.close = false
                    Session.Doc.session.orders.push Session.Doc.session.basket
                    Session.Doc.session.basket = {}
                    Basket.Init()
                    Basket.Save()
                    location.replace "/"

window.addEventListener "load", (event)->
    initStart startO
