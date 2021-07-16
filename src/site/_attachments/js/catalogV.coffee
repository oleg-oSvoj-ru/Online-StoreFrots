
#initOk ()->

startC = ()->
        nameV = decodeURI(location.pathname).split("/")[1]
        db.query 'site/catalog',{'key': nameV; group: false; reduce: false; include_docs: true;}
            .then (data)->
                console.log "_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+"
                console.dir Window.app
                console.log "_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+"
                
                Window.app = new Vue
                    el: '#catalog.catalog'
                    created: ->
                        @fetchData()
                    data: 
                        items: data.rows
                        nameV : nameV
                    methods: 
                        fetchData: ->
                            console.log "_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+"
            .catch (err)->
                console.dir err
                startC
                
window.addEventListener "load", (event)->
    initStart startC
