let mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */

// mix.js('resources/assets/js/app.js', 'public/js')
//    .sass('resources/assets/sass/app.scss', 'public/css');


mix.js('resources/assets/js/app.js', 'public/js')
   .sass('resources/assets/sass/app.scss', 'public/css')
   .js('public/js/app.js','public/js/min/app.min.js')
   .scripts(['./public/js/common_lib.js','./public/js/common.js'],'./public/js/min/app-bundle.min.js')
   .styles(
      ['public/css/common.css','public/css/emoji.css'],'public/css/min/app-bundle.min.css'
   )
   