window.uuid =()=>([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g,c=()->(c^crypto.getRandomValues(new Uint8Array(1))[0]&15 >> c/4).toString(16))
window.probel = (a)->
    return (a+"").replace(/(\d{1,3})(?=((\d{3})*)$)/g, " $1")
window.init = false

window.ddoc = {}
window.ddoc.name = 'siteP'
window.ddoc.db = 'https://couch.osvoj.ru/germandesign'

defSess = 
     _id       : ''
     type      : "session"
     dateCreate: Date.now()
     refer     : document.referrer
     session   : {}
     yaId      : ""
     goId      : ""

window.Session = {}
window.Session.Init = (cal)->
    if !Cookies.get('uuid')
        Cookies.set('uuid',uuid(),{ expires: 365 })
        window.Session.Doc     = defSess
        window.Session.Doc._id = Cookies.get('uuid')
        db.post(window.Session.Doc)
            .then (data)->
                console.dir data
                cal()
            .catch (err)->
                console.dir err
                cal()
    else
        db.get Cookies.get('uuid')
            .then (data)->
                window.Session.Doc     = data
                cal()
            .catch (err)->
                console.dir err
                window.Session.Doc     = defSess
                window.Session.Doc._id = Cookies.get('uuid')
                db.post window.Session.Doc
                    .then (data)->
                        console.dir data
                        cal()
                    .catch (err)->
                        console.dir err
                        cal()

window.Session.Save = ()->
    db.put window.Session.Doc
        .then (data)->
            window.Session.Doc._rev = data.rev
        .catch (err)->
            console.dir err
        .finally ()->
            console.dir ""

window.Basket = {}
window.Basket.Init = ()->
    if !window.Session.Doc.session
        window.Session.Doc.session = {}
    if !window.Session.Doc.session.basket
        window.Session.Doc.session.basket = {}
    if !window.Session.Doc.session.basket.val
        window.Session.Doc.session.basket.val = {}
    Basket.Count()
    window.init = true
    Basket.Save()

window.Basket.Count = ()->
    window.Session.Doc.session.basket.count = 0
    window.Session.Doc.session.basket.summ  = 0
    console.dir window.Session.Doc.session.basket.val
    for ind,item of window.Session.Doc.session.basket.val
        console.dir item
        if item.count is NaN
            item.count = 1
            window.Session.Doc.session.basket.val[ind].count = 1
        window.Session.Doc.session.basket.count = window.Session.Doc.session.basket.count*1 + item.count*1
        window.Session.Doc.session.basket.summ  =  window.Session.Doc.session.basket.summ*1 + item.count * item.price
    
window.Basket.Save = ()->
    Basket.Count()
    Session.Save()

VueInit = ()->
    Basket.app = new Vue
        el: '#basket'
        data:
            items: window.Session.Doc.session.basket.val
            summ : window.Session.Doc.session.basket.summ
            count: window.Session.Doc.session.basket.count
            show: false
            order: false
        methods:
            probel: probel
            CreateBastet: ()->
                Basket.Count()
                @summ = window.Session.Doc.session.basket.summ
                @count = window.Session.Doc.session.basket.count
            ClickPlus: (id)->
                if Session.Doc.session.basket.val[id]
                    Session.Doc.session.basket.val[id].count++
                Basket.Save()
                @summ = window.Session.Doc.session.basket.summ
                @count = window.Session.Doc.session.basket.count

            ClickMinus: (id)->
                if Session.Doc.session.basket.val[id].count > 1
                    Session.Doc.session.basket.val[id].count--
                else
                    delete Session.Doc.session.basket.val[id]
                Basket.Save()
                @summ = window.Session.Doc.session.basket.summ
                @count = window.Session.Doc.session.basket.count

initStart = (cal)->
    if !window.init
        setTimeout ()-> 
            initStart cal
         , 0.2
    else
       cal()
initStart VueInit

window.addEventListener "load", (event)->
    window.db = new PouchDB(location['origin'] + '/id');
    window.db = new PouchDB(ddoc.db)
    Session.Init ()->
        Basket.Init()
     
