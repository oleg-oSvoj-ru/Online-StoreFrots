{ src, dest, parallel, watch, series } = require 'gulp'
pug        = require 'gulp-pug'
styl       = require 'gulp-stylus'
csso       = require 'gulp-csso'
coffee     = require 'gulp-coffee'
uglify     = require 'gulp-uglify'
livereload = require 'gulp-livereload'
lzmajs     = require 'gulp-lzmajs'
imagemin   = require 'gulp-imagemin'
read       = require('fs').readFileSync
hash       = require 'gulp-hash'
jsonfile   = require 'jsonfile'
concat     = require 'gulp-concat'
download   = require 'gulp-download-files'
gxml       = require('gulp-xml2js')
remoteSrc  = require('gulp-remote-src')
webp       = require 'gulp-webp'
rsync      = require 'gulp-rsync'
nano       = require('nano')('http://localhost:5984')
market     = nano.use 'germandesign'
rename     = require 'gulp-rename'
Eval       = require 'gulp-eval'
browserify = require 'gulp-browserify'

#market.get(doc._id, { revs_info: true }).then (body)->
#                     doc._rev = body._rev

xml = ->
  remoteSrc(['catalog.xml'],{base:'https://www.mebel-moskva.ru/include/create_xml/'})
    .pipe(gxml())
    .pipe(dest('./json/'))


img = ->
    src( './src/**/*.{webp,svg,ico}')
        .pipe(imagemin())
        #.pipe hash()
        .pipe dest( './build/' )
        #.pipe hash.manifest('assets.json')
        #.pipe dest('./build/')
        #.pipe livereload()

webp = ->
    src( './src/**/*.{jpg,png,gif}')
       .pipe(webp())
       .pipe dest( './build/' )

js  = ->
    #download([''])
    #	.pipe(gulp.dest("downloads/"))
    src( './src/**/*.coffee', sourcemaps: 'dev' )
        .pipe coffee({bare: true, sourcemaps: 'dev', compress: true})
#        .pipe browserify
#                         insertGlobals : true
#                         debug : !gulp.env.production
        #.pipe uglify()
        #.pipe lzmajs(9)
        #.pipe hash()
        .pipe dest( './build/')
        #.pipe hash.manifest('assets.json')
        #.pipe dest('./build/')
        #.pipe livereload()

json = ->
    src('./src/**/*.coffson')
        .pipe coffee({bare: true})
#        .pipe browserify
#                         insertGlobals : true
#                         debug : !gulp.env.production
        .pipe rename( {extname: '.json'})
        .pipe dest('./build')



css = ->
    src( './src/**/*.styl', sourcemaps: dev )
        .pipe styl()
        .pipe csso()
        #.pipe hash()
        .pipe dest( './build/', sourcemaps: dev )
        #.pipe hash.manifest('assets.json')
        #.pipe dest('./build/')
        #.pipe livereload()

html = ->
    src( './src/**/*.pug', sourcemaps: dev )
        .pipe pug({'locals': {'req': require, 'path': './src/'} })
        #.pipe hash()
        .pipe dest( './build', sourcemaps: dev )
        #.pipe hash.manifest('assets.json')
        #.pipe dest('./build/')
        #.pipe livereload()

lib = ->
    src( './src/**/lib/*.coffee', sourcemaps: dev )
        .pipe coffee
                         bare: true
        .pipe browserify
                         insertGlobals : true
        #.pipe uglify()
        #.pipe lzmajs(9)
        .pipe dest( './build/', sourcemaps: dev )


copy = ->
   src(['./node_modules/transliteration/dist/browser/bundle.esm.min.js'])
      .pipe dest('./build/site/lib/')

   src('./src/**/*.vue')
      .pipe dest('./build/')
# './node_modules/pouchdb/dist/pouchdb.js'
#         './node_modules/pouchdb/dist/pouchdb.find.js'
#         './node_modules/pouchdb/dist/pouchdb.localstorage.js'
#'./node_modules/jquery/dist/jquery.js'
   src([ './src/**/normalize.css '
         './src/**/*.json'
         './src/**/_id'
         './src/**/*.js'
       ])
   .pipe dest('./build/')

   src([
         './node_modules/vue/dist/vue.js'
         './node_modules/axios/dist/axios.js'
         './node_modules/http-vue-loader/src/httpVueLoader.js'
         './node_modules/js-cookie/src/js.cookie.js'
       ])
      .pipe concat('libVjs.js')
      #.pipe uglify()
      .pipe lzmajs(9)
      .pipe dest('./build/site/_attachments/js/')


rsync = ->
    src('src/**')
        .pipe rsync({
           root: './'
           hostname: 'osvoj.ru'
           destination: '~/Domens/germandesign.osvoj.ru/'
           archive: true
           silent: false
           compress: true
           })

watchs = ->
    #livereload.listen
    #    host: '0.0.0.0'
    #    port: 35729
    #    key: read '/etc/letsencrypt/live/www.spr.osvoj.ru/privkey.pem'
    #    cert: read '/etc/letsencrypt/live/www.spr.osvoj.ru/fullchain.pem'

    watch './src/**/*.pug', html
    watch './src/**/*.styl', css
    watch './src/**/*.coffee', js
    watch './src/**/*.coffson', json
    watch './src/**/*.{jpg,png,svg,gif,ico}', img


dev = 1

exports.js      = js
exports.json    = json
exports.css     = css
exports.html    = html
exports.img     = img
exports.webp	= webp
exports.rsync   = rsync
exports.copy    = copy
exports.xml     = xml
exports.watchs  = watchs
exports.default = series parallel(js,json,copy,lib), css, html

dev = 1

exports.build = parallel html,css,js,watchs
