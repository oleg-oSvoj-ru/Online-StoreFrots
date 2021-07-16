
#initOk ()->

startB = ()->
        nameV = decodeURI(location.pathname).split("/")[1]
        db.query 'site/blog',{ group: false; reduce: false; include_docs: true;}
            .then (data)->
                console.log "_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+"
                console.dir Window.app
                console.log "_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+_+"
                
                Window.app = new Vue
                    el: '#blog'
                    created: ->
                        @fetchData()
                        #@getAction()
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
    initStart startB
