var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var routes = require('./routes/index');
var users = require('./routes/users');
var LocalStrategy = require('passport-local').Strategy
var passport = require('passport');
var CryptoJS = require('crypto-js');
var request = require('request');
var cheerio = require('cheerio');
var moment = require('moment-timezone');

var app = express();
app.use(passport.initialize());
app.use(passport.session());
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

var metrics = require('datadog-metrics');
metrics.init({ host: 'myhost', prefix: 'myapp.' });

function collectMemoryStats() {
    var memUsage = process.memoryUsage();
    metrics.gauge('memory.rss', memUsage.rss);
    metrics.gauge('memory.heapTotal', memUsage.heapTotal);
    metrics.gauge('memory.heapUsed', memUsage.heapUsed);
    metrics.increment('memory.statsReported');
}
setInterval(collectMemoryStats, 5000);
 
// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
app.use('/users', users);
var User = require('./models/user');
passport.use(new LocalStrategy(User.authenticate()));
passport.serializeUser(User.serializeUser());
passport.deserializeUser(User.deserializeUser());
console.log('running');
// catch 404 and forward to error handler
mongoose.connect('###');
var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function (callback) {
  console.log('connection success');
});

app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});

app.listen(process.env.PORT || 2800, function(){
  console.log("gradeCheck: port : %d in %s", this.address().port, app.settings.env);
});

var thirty = 30*60*1000;
setInterval(function(){
  console.log("Every Hour");
  var currentHour = moment().tz("America/New_York").get("hour");
  if(currentHour < 23 && currentHour > 5){
    var re = {method : 'GET',
        url : 'https://gradecheck.herokuapp.com/',
        headers:{
         'cache-control' : 'no-cache'
        }
    };
    request(re, function (error,response,body){
      if(error){
        console.log(error);
      }else{
        console.log('keep alive');
      }
    });
  }else{
    console.log('taking a break. Be back in 6 hours ~');
  }
}, thirty)

function restart(){
  User.find({}, function(err,doc){
    if(err)
      console.log(err);
    doc.forEach(function(doc){
      User.update({username:doc.username},{$set:{grades : [{"subject":"","grade" : ""}]}},function (err,numberAffected,raw){
        if(err){
          console.log(err);
        }
        console.log(numberAffected);
      });
    });
  });
}

function clean(){
  User.find({}, function(err,doc){
    if(err)
      console.log(err);
    doc.forEach(function(doc){
      if (doc['username'].match(/[a-z]/i)){
        console.log('removing ' + doc['username'])
        User.remove(doc, {justOne:true}, function(error, numberAffected, raw) {
          if(error) console.log(err);
        });
      }
    });
  });
}

module.exports = app;
