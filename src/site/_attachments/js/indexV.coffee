startI = ()->
    db.query('site/catalog', {'group': true}).then (data)->
        data.rows.push {key: "Блог"}
        window.app = new Vue
            el: '#index'
            data:
                items: data.rows
            methods: {}




window.addEventListener "load", (event)->
    initStart startI


