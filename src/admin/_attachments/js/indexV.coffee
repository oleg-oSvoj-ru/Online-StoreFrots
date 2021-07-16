startI = ()->
  window.slide = new Vue
    el: '#slide'
    created: ->
      @.fetchData()
    data: items: []
    methods: 
        fetchData: ->
            db.query ddoc.name+'/catalog',{key:'Слайдер'}
                .then (data)->
                    slide.items = data.rows
                    console.dir slide.items
        slideClick: (n)->
            if n == 'Right'
                slide.items.unshift slide.items.pop()
            else
                slide.items.push slide.items.shift()

window.addEventListener "load", (event)->
    initStart startI
