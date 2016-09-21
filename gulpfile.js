var gulp = require('gulp'),
    jshint = require('gulp-jshint'),
    uglify = require('gulp-uglify'),
    minifyCss = require('gulp-minify-css'),
    less = require('gulp-less'),
    concat = require('gulp-concat'),
    sourcemaps = require('gulp-sourcemaps');

gulp.task('js', ['jshint'], function () {
  return gulp.src([
    'src/project/static/bower_components/jquery/dist/jquery.js',
    'src/project/static/bower_components/bootstrap/dist/js/bootstrap.js',
    'src/project/static/project/js/**/*.js'
  ])
    .pipe(sourcemaps.init())
    .pipe(concat('project.min.js'))
    .pipe(uglify())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('src/project/static/project/dist/js/'));
});

gulp.task('less', function () {
  return gulp.src([
    'src/project/static/project/less/**/*.less'
  ])
    .pipe(sourcemaps.init())
    .pipe(less({
        paths: ['src/project/static/bower_components']
    }))
    .pipe(concat('project.min.css'))
    .pipe(minifyCss())
    .pipe(sourcemaps.write())
    .pipe(gulp.dest('src/project/static/project/dist/css/'));
});

gulp.task('jshint', function() {
  return gulp.src('src/project/static/project/js/**/*.js')
    .pipe(jshint())
    .pipe(jshint.reporter('default'));
});

gulp.task('watch', function () {
  gulp.watch(['src/project/static/project/js/**/*.js'], ['js']);
  gulp.watch(['src/project/static/project/less/**/*.less'], ['less']);
});

gulp.task('default', ['js', 'less']);
