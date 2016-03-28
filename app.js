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

var app = express();
app.use(passport.initialize());
app.use(passport.session());
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
// Twilio Credentials 
var accountSid = 'AC8c54936619b5bd504963509d5d745dff'; 
var authToken = '4510695a59ef9ea2ed60dfd4969a9036'; 
 
//require the Twilio module and create a REST client 
var client = require('twilio')(accountSid, authToken); 
 
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
mongoose.connect('mongodb://genesisboys:gradecheck@ds019048.mlab.com:19048/gradecheck');
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

app.listen(process.env.PORT || 3000, function(){
  console.log("gradeCheck: port : %d in %s", this.address().port, app.settings.env);
});
var hour = 10*60*1000;
setInterval(function(){
  console.log("Every Hour");
  User.find({},function(err,doc){
    if(err){
      console.log(err)
    }else{
    doc.forEach(function(doc){
      console.log(doc.username);
                                  
      var pref = doc.preference;
      var s = CryptoJS.AES.decrypt(pref.toString(),"LookDown");
      var a = s.toString(CryptoJS.enc.Utf8);
      console.log(a);
      var cookie;
      var art = [];
      var gradesArray = doc.grades;
      var username;
      if(doc.studId){
        username = doc.studId;
        console.log('using studentID');
      }else{
        username = doc.username
        console.log('using Username');
      }
      var second = {method : 'GET',
          url : 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
          'rejectUnauthorized' : false,
          headers : {'cache-control':'no-cache'} };
      request(second,function(error,response,body){
        if (error) throw new Error(error);
        cookie = response.headers['set-cookie'];
        var options = { method: 'POST',
          url: 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
          'rejectUnauthorized' : false,
          headers: 
          { 'content-type': 'application/x-www-form-urlencoded',
          'Cookie' : cookie,
          'cache-control': 'no-cache' },
          form: { 'j_username':username, 'j_password': a} 
        };

        request(options, function (error, response, body) {
          if (error) throw new Error(error);
          var home = response.headers['location'];
          console.log("https://parents.mtsd.k12.nj.us"+home);
          var hoptions = {method : 'POST',
            url : 'https://parents.mtsd.k12.nj.us' + home,
            'rejectUnauthorized' : false,
            headers : {'cache-control' : 'no-cache',
            'content-type': 'application/x-www-form-urlencoded',
            'Cookie':cookie},
            form: { 'j_username':username, 'j_password': a} 
          };
          request(hoptions, function(error, response,body){
            if(error) throw new Error(error);
            cookie = response.headers['set-cookie'];
            home = response.headers['location'];
            console.log("https://parents.mtsd.k12.nj.us/genesis/"+home);
            var ptions = {method : 'GET',
              url : 'https://parents.mtsd.k12.nj.us/genesis/'+home,
              'rejectUnauthorized' : false,
              headers : {'cache-control' : 'no-cache',
              'Cookie':cookie}
            };
            request(ptions, function(error, response,body){
              if(error)throw new Error(error);
              var url = response.request.uri.query;
              var name = "studentid";
              name = name.replace(/[\[\]]/g, "\\$&");
              var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
              var student = decodeURIComponent(results[2].replace(/\+/g, " "));
              var gradebook = {method: 'GET',
                url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + doc.username + '&action=form',
                'rejectUnauthorized' : false,
                headers:{'cache-control' : 'no-cache',
                'Cookie':cookie
                }
              };
              request(gradebook,function(error,response,body){
                var $ = cheerio.load(body);
                $('td.cellRight').each(function(i,element){
                  var grade = $(this);
                  if (grade.attr('style') == "cursor:pointer;"){
                    var classroom = grade.prev().prev().text();
                    var teacher = grade.prev().text();
                    teacher = teacher.replace("Email:","");
                    var num = grade.text();
                    num = num.trim();
                    var p = {};
                    classroom = classroom.trim();
                    p["subject"] = classroom;
                    teacher = teacher.trim();
                    p["grade"] = num;
                    art.push(p);
                  }
                });
                if(gradesArray[0].subject == ""){
                  console.log("First Update: ===================");
                  console.log("Pushing Array:");
                  console.log(art);
                  User.update({username : doc.username},{$set:{grades : art}},function (err,numberAffected,raw){
                    if(err){
                      console.log(err);
                    }
                    console.log(numberAffected);
                  });
                }else{
                  var bool = true;
                  for(var i = 0; i < gradesArray.length; i ++){
                    var obj = gradesArray[i];
                    if(art[i].subject == gradesArray[i].subject && art[i].grade == gradesArray[i].grade){
                      
                    }else{
                      var ol = gradesArray[i]
                      var ne = art[i]
                      console.log("Something changed : ============================================");
                      console.log(gradesArray[i].subject+ " " + gradesArray[i].grade + " to new grade of " + art[i].subject + " " + art[i].grade);
                      User.update({username:doc.username, "grades.subject" : ol.subject},{"$set" : {"grades.$.grade" : ne.grade}},function (err, numberAffected, raw){
                        if(err){
                          console.log(err);
                        }
                        console.log(numberAffected);
                      });
                      client.messages.create({ 
                        to: doc.phoneNumber, 
                        from: "+16466797855", 
                        body: "Your grade in " + gradesArray[i].subject + " has changed from " + gradesArray[i].grade + " to " + art[i].grade,   
                      }, function(err, message) { 
                        console.log(message.sid); 
                      });
                      console.log("texted " + doc.username);
                      
                    }
                  }
                  if(bool = true){
                    console.log("all the same");
                  }
                }
              });
            });
          });
        });
      });
    });
    }
  });
},hour);

module.exports = app;
