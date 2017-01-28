var express = require('express');
var request = require('request');
var cheerio = require('cheerio');
var passport = require('passport');
var User = require('../models/user');
var CryptoJS = require('crypto-js');
var ObjectID = require('mongodb').ObjectID;
var app = express.Router();

/*

  spaghetti

*/
var markingPeriod = "MP2";
/* GET home page. */
app.get('/', function(req, res, next) {
  console.log(req.headers);
  res.render('info');
});
app.post('/register', function(req, res) {
	var actual = CryptoJS.AES.encrypt(req.body.password,"LookDown"); //should switch to process.env for higher security reasons
  isValid(req.body.username,req.body.password, function(bool){
    if(bool){
        console.log("GOOD TO PROCEED");

        User.register(new User({ username : req.body.username, grades:[{subject:"", grade:""}], deviceToken: req.body.deviceToken, preference : actual, studId: ""}), req.body.password, function(err, account) {
            if (err) {
             console.log(err);
              return res.writeHead(400)
              res.end("username taken");
            }else{
             res.writeHead(200)
             res.end("RegistrationSuccessful");
            }
        });
      }else{
        console.log(result);
        console.log("DOESN'T WORK");
        res.writeHead(912);
        res.end("RegistrationFailed");
      }
  });
});
function isValid(username,pass,callback){
    var bool  = false;
    if(typeof username !== undefined && typeof pass !== undefined && username != "" && pass != ""){
      var second = {method : 'GET',
          url : 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
          'rejectUnauthorized' : false,
          headers : {'cache-control':'no-cache',
        'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36'} };
      request(second,function(error,response,body){
        if (error) throw new Error(error);

        cookie = response.headers['set-cookie'];
        console.log(cookie);
        var options = { method: 'POST',
          url: 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
          'rejectUnauthorized' : false,
            headers: 
            { 'content-type': 'application/x-www-form-urlencoded',
            'Cookie' : cookie,
            'cache-control': 'no-cache' ,
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36'},
            form: { 'j_username':username, 'j_password': pass} 
          };

        request(options, function (error, response, body) {
            if (error) throw new Error(error);
            console.log(response.headers);
            console.log(response.statusCode);
            var home = response.headers['location'];
            console.log(home);
            if(home == "/genesis/parents?gohome=true"){
              bool = true;
            }else if(home == "https://parents.mtsd.k12.nj.us/genesis"){
              bool = false;
            }else{
              bool = false;
            }
            callback(bool);
            return bool;
        });
    });
  }
}
app.post('/update', function(req,res){
		console.log("user in");
		console.log(req.body.id);
		User.findById(ObjectID(req.body.id), function(err, user) {
			if(err){console.log(err)}
        	if (user) {
            	    if(req.body.username){
                    console.log(req.body.username);
                    var a = {};
                    a["username"] = req.body.username;
                    User.find(a,function(err,users){
                      if(err){
                        console.log(err);
                      }
                      if(users.length != 0){
                        console.log(users.id);
                        console.log("TAKEN");
                        User.remove({_id : ObjectID(req.body.id)}, function (err){
                          if(err){
                            console.log(err);
                          }else{
                            console.log("removal of user without name, attempting to replicate :" + users.id);
                          }
                        })
                        return res.status(1738).end("you ain't brendon, ho");
                      }else{
                        user.username = req.body.username ? req.body.username : user.username;
                        user.save();
                      }
                    });
                  } 
                	user.email = req.body.email ? req.body.email : user.email;
                	user.phoneNumber = req.body.phoneNumber ? req.body.phoneNumber : user.phoneNumber;
                	user.deviceToken = req.body.deviceToken ? req.body.deviceToken : user.deviceToken;
                	user.studId = req.body.studId ? req.body.studId : user.studId;
                  if(req.body.preference){
                    isValid(user.studId,req.body.preference, function (bool){
                      if(bool){
                        console.log("GOOD");
                        var encrypts = CryptoJS.AES.encrypt(req.body.preference, "LookDown");
                        user.preference = encrypts;
                        user.setPassword(req.body.preference);
                      }else{
                        console.log("BAD AUTH");
                      }
                    })
                  }
                	user.save();
                	return res.status(200).end("Process successful");
         
        	} else {
            	return res.status(400).end('User not found');
        	}
    	});
	
});
app.post('/relogin', passport.authenticate('local'), function (req,res){
  if(req.body.username && req.body.password && req.body.cookie){
    var js = [];
    var username, password;
    var cookie = req.body.cookie;
    if(req.body.email){
      username = req.body.email;
      console.log('refresh going through EMAIL');
    } else if (req.user && req.user.studId != ""){
      username = req.user.studId;
      console.log('refresh going through dataBase Email');
    } else{
      username = req.body.username;
      console.log(username + " no email, refresh with username ");
    }
    var poster = { method: "POST",
        url : 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
        'rejectUnauthorized' : false,
        headers : {'content-type':'application/x-www-form-urlencoded',
          'Cookie' : cookie,
          'cache-control' : 'no-cache',
        'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36'},
          form : { 'j_username' : username, 'j_password' : req.body.password}
    };
    request(poster, function (error, response, body){
      if (error) throw new Error(error);
      console.log(response.headers);
      console.log(response.statusCode);
      var home = response.headers['location'];
      var se = {method : "POST",
        url : "https://parents.mtsd.k12.nj.us" + home,
        'rejectUnauthorized' : false,
        headers : {
          'cache-control' : 'no-cache',
          'content-type' : 'application/x-www-form-urlencoded',
          'Cookie' : cookie,
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36'
        },
        form : {'j_username' : username, 'j_password' : req.body.password}
      }
      request(se, function (error,response,body){
        if(error)throw new Error(error);
        console.log(response.statusCode);
        console.log(response.headers);
        cookie = response.headers['set-cookie'];
        var cookieObject = {};
        cookieObject["cookie"] = cookie;
        js.push(cookieObject);
        console.log(js);
        res.send(JSON.stringify(js));
      });
    });
  }
})
app.post('/login', passport.authenticate('local'),function (req,res){

	if(req.body.username && req.body.password){
		var cookie;
		var json = [];
    var update = [];
    var username;
    var password;
    if(req.body.email){
      username = req.body.email;
      console.log(username + "email found");
    }else if (req.user && req.user.studId != ""){
      console.log(req.user);
      username = req.user.studId;
      console.log('dataBase EMAIL');
    }else{
      username = req.body.username;
      console.log(username + "no email, go to username");
    }
    console.log(username);
    console.log(req.body.password);
		var second = {method : 'GET',
				url : 'https://parents.mtsd.k12.nj.us/genesis/j_security_check', 
				'rejectUnauthorized' : false,
				headers : {'cache-control':'no-cache',
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
          "Accept-Language" : "en-US,en;q=0.8",
          "Accept-Encoding" : "gzip, deflate, sdch"} };
		request(second,function(error,response,body){
			if (error) throw new Error(error);
      console.log(response.headers);
			cookie = response.headers['set-cookie'];
      console.log(cookie);
			var options = { method: 'POST',
 	 			url: 'https://parents.mtsd.k12.nj.us/genesis/j_security_check',
 	 			'rejectUnauthorized' : false,
  				headers: 
   				{ 'content-type': 'application/x-www-form-urlencoded',
   				'Cookie' : cookie,
    	 		'cache-control': 'no-cache',
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
          "Accept-Language" : "en-US,en;q=0.8" },
  				form: { 'j_username':username, 'j_password': req.body.password} 
  			};

			request(options, function (error, response, body) {
  				if (error) throw new Error(error);
          console.log("FIRST REQUEST");
  				console.log(response.headers);
  				console.log(response.statusCode);
  				var home = response.headers['location'];
  				console.log(home);
  				var hoptions = {method : 'POST',
  					url : "https://parents.mtsd.k12.nj.us" + home,
  					'rejectUnauthorized' : false,
  					headers : {'cache-control' : 'no-cache',
  					'content-type': 'application/x-www-form-urlencoded',
  					'Cookie':cookie,
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
          "Accept-Language" : "en-US,en;q=0.8",
          "Accept-Encoding" : "gzip, deflate, sdch"},
  					form: { 'j_username':username, 'j_password': req.body.password} 
  				};
          if(home == "https://parents.mtsd.k12.nj.us/genesis"){
            res.writeHead(400);
            res.end("Password incorrect");
          }else{
	  			request(hoptions, function(error, response,body){
  					if(error) throw new Error(error);
            console.log("SEC REQUEST");
  					console.log(response.statusCode);
  					console.log(response.headers);
  					cookie = response.headers['set-cookie'];
            console.log(cookie);
            home = response.headers["location"];
  					console.log("https://parents.mtsd.k12.nj.us/genesis/"+home);
  					var ptions = {method : 'GET',
  						url : 'https://parents.mtsd.k12.nj.us/genesis/'+home,
  						'rejectUnauthorized' : false,
  						headers : {'cache-control' : 'no-cache',
  						'content-type': 'application/x-www-form-urlencoded',
              'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
              "Accept-Language" : "en-US,en;q=0.8",
              "Accept-Encoding" : "gzip, deflate, sdch",
  						'Cookie':cookie}
  					};
  					console.log(home);
	  				request(ptions, function(error, response,body){
	  					  					
						if(error)throw new Error(error);
            console.log(response.headers);

						if(!req.body.id){
							var returnArray = [req.user];
							var $ = cheerio.load(body);
							console.log('no id');
							var students = $('select.headerStudentSelectorInput').children().each(function(i,elem){
								var a = $(this);
								var b = {};
								b["id"] = a.val();
								b["name"] = a.text();
								console.log(a.val());
								console.log(a.text());
								returnArray.push(b);
							});
							console.log(returnArray);
							res.status(679).send(JSON.stringify(returnArray))

						}else{
	  					var url = response.request.uri.query;
	  					console.log(response.request.uri.query);
	  					/*var name = "studentid";
	  					name = name.replace(/[\[\]]/g, "\\$&");
    					var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
       					results = regex.exec(url);
    					var student = decodeURIComponent(results[2].replace(/\+/g, " "));
    					console.log(student);*/
    					var s = {};
    					s["cookie"] = cookie;
              s["objectID"] = [req.user["_id"]]; 
    					json.push(s);
  						var gradebook = {method: 'GET',
  							url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + req.body.id + '&action=form',
  							'rejectUnauthorized' : false,
  							headers:{'cache-control' : 'no-cache',
  							'content-type': 'application/x-www-form-urlencoded',
  							'Cookie':cookie,
                'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
                "Accept-Language" : "en-US,en;q=0.8",
                "Accept-Encoding" : "gzip, deflate, sdch"
  							}
  						};

  						request(gradebook,function(error,response,body){
  							console.log(response.headers);
  							var $ = cheerio.load(body);
  							$('td.cellRight').each(function(i,element){
  								var grade = $(this);
  								if(grade.attr('style') == "cursor:pointer;"){
  									var teacherCell = grade.prev()
                    if(grade.prev().hasClass('cellCenter')){
                      teacherCell = grade.prev().prev()
                    }
                    var classroom = teacherCell.prev().text();
  									var teacher = teacherCell.text().replace("Email:","");
  									var num = grade.text();
                    if(num.includes('%')){
                      num = num.replace('%','');
                      var a = Math.round(num);
                      num = a + "%";
                    }else{
                      var a = Math.round(num);
                      num += "%";
                    }
  									num = num.trim();
  									classroom = classroom.trim();
  									teacher = teacher.trim();
  									var a = {};
                    var c = {};
                    var classcodes = getParamNames(teacherCell.prev().children().attr('onclick'))[1];
                    classcodes = classcodes.replace(/'/g,"");
                    console.log(classcodes);
  									a["class"] = classroom;
                    c["subject"] = classroom;
                    c["grade"] = num;
  									a["grade"] = num;
  									a["teacher"] = teacher;
                    a["classCodes"] = classcodes;
  									json.push(a);
                    update.push(c);
  								}
  							});
  							console.log(json);
                updateOnDatabase(update,req.user);
							res.send(JSON.stringify(json));
  						});
  						}
  					});
  				});
        }
			});
		});
	}
});
function updateOnDatabase(art,user){
  console.log('called')
  console.log(art);
  if(user && user.grades[0].subject != ""){
    var gradesArray = user.grades;
    var bool = true;
    for (var i = 0; i < gradesArray.length; i ++){
      var obj = gradesArray[i];
      if(art[i].subject == gradesArray[i].subject && art[i].grade == gradesArray[i].grade){
                      
      }else{
        bool = false;
        var ol = gradesArray[i]
        var ne = art[i]
        console.log("Something changed : ============================================");
        console.log(gradesArray[i].subject+ " " + gradesArray[i].grade + " to new grade of " + art[i].subject + " " + art[i].grade);
        User.update({username:user.username, "grades.subject" : ol.subject},{"$set" : {"grades.$.grade" : ne.grade}},function (err, numberAffected, raw){
          if(err){
            console.log(err);
          }
            console.log(numberAffected);
          });
      }
    }
  }else{
    console.log('updating for the first time');
    User.update({username : user.username},{$set:{grades : art}},function (err,numberAffected,raw){
      if(err){
        console.log(err);
      }
      console.log(numberAffected);
    });
  }
}
var STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;
var ARGUMENT_NAMES = /([^\s,]+)/g;
function getParamNames(func) {
  var fnStr = func.toString().replace(STRIP_COMMENTS, '');
  var result = fnStr.slice(fnStr.indexOf('(')+1, fnStr.indexOf(')')).match(ARGUMENT_NAMES);
  if(result === null)
     result = [];
  return result;
}
app.post('/searchForSiblings', function (req,res){
  if(req.body.email){
    var email = req.body.email;
    console.log(email);

  }
});
app.post('/gradebook', function(req,res){
	if(req.body.cookie && req.body.id){
		console.log(req.body.cookie);
		console.log(req.body.id);
		var rep = [];
    var url = 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + req.body.id + '&action=form';
    if(req.body.mp){
      url += "&mpToView=" + req.body.mp;
      console.log(url);
    }
		var go = {method:'GET',
			url : url,
			'rejectUnauthorized' : false,
			headers:{'cache-control' : 'no-cache',
			'content-type' : 'application/x-www-form-urlencoded',
      'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
      "Accept-Language" : "en-US,en;q=0.8",
      "Accept-Encoding" : "gzip, deflate, sdch",
			'Cookie' : req.body.cookie}
		};
		request(go,function(error,response,body){
			if(response.headers["set-cookie"]){
				console.log('needs login');
				var b = {};
				b["set-cookie"] = response.headers["set-cookie"];
				rep.push(b);
				console.log(response.headers)
				res.status(440).send(JSON.stringify(rep));
			}else{
				var $ = cheerio.load(body);
				var cookID = {};
				cookID["cookie"] = [req.body.cookie, "SAFE"];
				cookID["id"] = req.body.id;
				rep.push(cookID);
  				$('td.cellRight').each(function(i,element){
  					var grade = $(this);
  					if(grade.attr('style') == "cursor:pointer;"){
  						var teacherCell = grade.prev();
              if(grade.prev().hasClass('cellCenter')){
                teacherCell = grade.prev().prev()
              }
              var classroom = teacherCell.prev().text();
              var teacher = teacherCell.text().replace("Email:","");
  						var num = grade.text();
  						num = num.trim();
              if(num.includes('%')){
                num = num.replace('%','');
                var a = Math.round(num);
                num = a + "%";
              }else{
                var a = Math.round(num);
                num += "%";
              }
              console.log(num);
  						classroom = classroom.trim();
  						teacher = teacher.trim();
              var classcodes = getParamNames(teacherCell.prev().children().attr('onclick'))[1];
              classcodes = classcodes.replace(/'/g,"");
  						var a = {};
  						a["class"] = classroom;
  						a["grade"] = num;
  						a["teacher"] = teacher;
              a["classCodes"] = classcodes
  						rep.push(a);
  					}
  				});
  				console.log(rep);
				res.send(JSON.stringify(rep));
  			}
		});
	}
});

app.post('/getClassWeighting', function (req,res){
  //https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=coursesummary&studentid=000958&action=form&courseCode=33500&courseSection=1&mp=MP4
  if(req.body.cookie && req.body.id && req.body.courseCode && req.body.courseSection){
    var result = [];
    var re = {method:'GET',
      url : 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=coursesummary&studentid=' + req.body.id + 
      '&action=form&courseCode=' + req.body.courseCode + '&courseSection=' + req.body.courseSection + '&mp=' + markingPeriod,
      'rejectUnauthorized' : false,
      headers :{'cache-control' : 'no-cache',
      'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
      "Accept-Language" : "en-US,en;q=0.8",
      "Accept-Encoding" : "gzip, deflate, sdch",
      'Cookie' : req.body.cookie}
    }
    request(re, function (error, response, body){
      if(response.headers["set-cookie"]){
        console.log('needs login');
        var b ={};
        b["set-cookie"] = response.headers["set-cookie"];
        result.push(b);
        res.status(440).send(JSON.stringify(result));
      }else{
        var weighted = [];
        var $ = cheerio.load(body);
        var results = $('div').attr('style','text-align: left;font-size:14pt;padding-bottom:3px;').children('b').each(function (i,elem){
          if($(this).text() == "Grading Information"){
            var methodOfGrade = $(this).parent().next('b').text()
            var method = $(this).parent();
            if(methodOfGrade == "Total Points"){
              weighted.push(methodOfGrade);
            }else{
              weighted.push(methodOfGrade);
              var weightedArray = [];
              method.nextAll('.list').first().children().each(function (i,elem){
                if($(this).attr('class') != "listheading"){
                  var weightedObject = {};
                  weightedObject["category"] = $(this).children('.cellLeft').children('b').text();
                  weightedObject["weight"] = $(this).children('.cellRight').first().text();
                  weightedArray.push(weightedObject);
                }
              });
              weighted.push(weightedArray);
            }
          }
        });
        console.log(weighted);
        res.send(JSON.stringify(weighted));
      }
    })
  }
});
app.post('/listassignments',function(req,res){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth() + 1;
	var yyyy = today.getFullYear();
  var mp;
  if(req.body.mp){
    mp = req.body.mp;
  }else{
    mp = markingPeriod
  }
	if(dd < 10){
		dd = "0" + dd;
	}
	if(mm < 10){
		mm = "0" + mm;
	}
	var dateString = mm +"/"+dd+"/"+yyyy;
	if(req.body.cookie && req.body.id){
		var results = [];
		var adj = {method:'GET',
			url : 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=listassignments&studentid=' + req.body.id + 
			'&action=form&dateRange=' + mp + '&date=' + dateString + "&courseAndSection=" + req.body.course +":"+ req.body.section,
			'rejectUnauthorized' : false,
			headers:{'cache-control' : 'no-cache',
      'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.27 Safari/536.11',
      "Accept-Encoding" : "gzip, deflate, sdch",
      "Accept-Language" : "en-US,en;q=0.8",
			'Cookie' : req.body.cookie}
		}
    console.log('https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=listassignments&studentid=' + req.body.id + 
      '&action=form&dateRange=' + mp + '&date=' + dateString + "&courseAndSection=" + req.body.course +":"+ req.body.section);
		request(adj,function(error,response,body){
			if(response.headers["set-cookie"]){
				console.log('needs login');
				var b = {};
				b["set-cookie"] = response.headers["set-cookie"];
				results.push(b);
				res.status(440).send(JSON.stringify(results));
			}else{
				console.log(response.headers);
				var $ = cheerio.load(body);
				$('td.cellRight').each(function(i,element){
  					var assignment = $(this);
  					if(assignment.prev().attr('class') == "cellCenter"){
  						var value = {};
  						value["gradeMax"] = assignment.text().trim();
  						var percent = assignment.next().text();
  						value["percent"] = percent;
  						var grade = assignment.prev().prev();
  						var perc = grade.text();
  						perc = perc.trim();
  						value["grade"] = perc;
  						var title = {};
  						var first = grade.prev().children('b');
  						var fir = first.text().trim();
  						title["title"] = fir;
  						var details = first.next().filter(function(i,el){
  							return $(this).attr('style') === "font-style:italic;padding-left:5px;"
  						});
  						details = details.text().trim()
  						title["details"] = details;
  						value["assignment"] = title;
  						var cat = grade.prev().prev();
  						var actual = cat.contents().filter(function(i,el){
  							if( $(this).attr('class') == "boxShadow"){
  								return "";
  							}else{
  								return $(this).text().trim();
  							}
  						});
  					
  						value["category"] = actual.text().trim();
              var teachr = cat.prev();
              var courseCell = teachr.children().first();
              var courseName = courseCell.text().trim();
              var teacherName = courseCell.next().filter(function (i,el){
                return $(this).attr('style') == "padding: 0 0 0 2px;font-size: 8pt;"
              });
              teacherName = teacherName.text().trim();
              value["teacher"] = teacherName;
              value["course"] = courseName;
              var due = teachr.prev();
              var dueDate = due.text().trim();
              var res = dueDate.split("\n");
              var day = res[0];
              var stringDate = res[1];
              value["dueDate"] = day;
              var another = due.prev();
              var str = another.text().trim();
              if(stringDate){
                value["stringDate"] = stringDate.trim() + "/2017";
              }else{
                value["stringDate"] = "";
              }
              value["mp"] = str;
  						results.push(value);
  					}
  				}); 
          console.log(results);
  				res.send(JSON.stringify(results));

			}
		});
	}
});
app.post('/assignments', function(req, res){
	if(req.body.cookie && req.body.id){
		console.log(req.body.cookie);
		console.log(req.body.id);
		var total = [];
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1;
    var yyyy = today.getFullYear();
    var mp;
    if(req.body.mp){
      mp = req.body.mp;
    }else{
      mp = markingPeriod
    }
    if(dd < 10){
      dd = "0" + dd;
    }
    if(mm < 10){
      mm = "0" + mm;
    }
    var dateString = mm +"/"+dd+"/"+yyyy;
		var gradebook = {method: 'GET',
  				url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=listassignments&studentid=' + req.body.id + '&action=form',
  				'rejectUnauthorized' : false,
  				headers:{'cache-control' : 'no-cache',
  				'content-type': 'application/x-www-form-urlencoded',
          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.27 Safari/536.11',
          "Accept-Encoding" : "gzip, deflate, sdch",
          "Accept-Language" : "en-US,en;q=0.8",
  				'Cookie':req.body.cookie
  				}
  	};
  		request(gradebook,function(error,response,body){
  			if(response.headers["set-cookie"]){
  				console.log('needs login');
  				var b ={};
  				b["set-cookie"] = response.headers["set-cookie"];
  				total.push(b);
  				res.status(440).send(JSON.stringify(total));
  			}else{
  				console.log(response.headers);
  				var $ = cheerio.load(body);
  				$('td.cellRight').each(function(i,element){
  					var assignment = $(this);
  					if(assignment.prev().attr('class') == "cellCenter"){
  						var value = {};
  						value["gradeMax"] = assignment.text().trim();
  						var percent = assignment.next().text();
  						value["percent"] = percent;
  						var grade = assignment.prev().prev();
  						var perc = grade.text();
  						perc = perc.trim();
  						value["grade"] = perc;
  						var title = {};
  						var first = grade.prev().children('b');
  						var fir = first.text().trim();
  						title["title"] = fir;
  						var details = first.next().filter(function(i,el){
  							return $(this).attr('style') === "font-style:italic;padding-left:5px;"
  						});
  						details = details.text().trim()
  						title["details"] = details;
  						value["assignment"] = title;
  						var cat = grade.prev().prev();
  						var actual = cat.contents().filter(function(i,el){
  							if( $(this).attr('class') == "boxShadow"){
  								return "";
  							}else{
  								return $(this).text().trim();
  							}
  						});
  					
  						value["category"] = actual.text().trim();
              var teachr = cat.prev();
              var courseCell = teachr.children().first();
              var courseName = courseCell.text().trim();
              var teacherName = courseCell.next().filter(function (i,el){
                return $(this).attr('style') == "padding: 0 0 0 2px;font-size: 8pt;"
              });
              teacherName = teacherName.text().trim();
              value["teacher"] = teacherName;
              value["course"] = courseName;
  						var due = teachr.prev();
  						var dueDate = due.text().trim();
              var res = dueDate.split("\n");
              var day = res[0];
              var stringDate = res[1];
  						value["dueDate"] = day;
  						var another = due.prev();
  						var str = another.text().trim();
  						value["stringDate"] = stringDate.trim() + "/2017";
              value["mp"] = str;

  						total.push(value);
  					}

  				}); 
          total = total.reverse();
          console.log(total);
  				res.send(JSON.stringify(total));			

  			}
  		
  		});
	}
});
app.post('/classdata', function(req,res){
  if(req.body.className){
    console.log(req.body.className);
    var a = {};
    a["subject"] = req.body.className;
    var b = {};
    b["$elemMatch"] = a;
    var c = {};
    c["grades"] = b;
    var split = req.body.className.split("-")[0].split("/");
    console.log(split)
    var occurences = [];
    var counts = {};
    var last = [];
    console.log(c)
    User.find({"grades.subject": new RegExp(split[0])}, function (err, doc){
      for (var i = 0; i < doc.length; i ++){
        for (obj in doc[i].grades) {
          var item = doc[i].grades[obj]
          if(item["subject"].split("-")[0].split("/")[0] == split[0]){
            console.log(item["grade"]);
            if(item["grade"] == "No Grades"){

            }else{
              occurences.push(item["grade"].slice(0,-1));
            } 
            console.log("We found something");
            }
        }
      }
      console.log(occurences)
      occurences.forEach(function(x){
      /*switch (x){
        case (x > 96) :
          counts["A+"] = (counts["A+"] || 0) + 1
          break;
        case (x > 93) :
          counts["A"] = (counts["A"] || 0) + 1
          break;
        case (x > 89) :
          counts["A-"] = (counts["A-"] || 0) + 1
          break;
        case (x > 86) :
          counts["B+"] = (counts["B+"] || 0) + 1
          break;
        case (x > 83) :
          counts["B"] = (counts["B"] || 0) + 1
          break;
        case (x > 79) :
          counts["B-"] = (counts["B-"] || 0) + 1
          break;
        case (x > 76) :
          counts["C+"] = (counts["C+"] || 0) + 1
          break;
        case (x > 73) :
          counts["C"] = (counts["C"] || 0) + 1
          break;
        case (x > 69) : 
          counts["C-"] = (counts["C-"] || 0) + 1
          break;
        case (x > 66) :
          counts["D+"] = (counts["D+"] || 0) + 1
          break;
        case (x > 63) :
          counts["D"] = (counts["D"] || 0) + 1
          break;
        case (x > 59) :
          counts["D-"] = (counts["D-"] || 0) + 1
          break;
        default : 
          counts["F"] = (counts["F"] || 0) + 1
          break;
        } */
      counts[x]= (counts[x] || 0) + 1;        
      })
      occurences.forEach(function(x){
        var b = {};
        b["grade"] = x;
        b["occurences"] = counts[x];
        last.push(b);
      });

      last.sort(function (a,b){
        if(a.grade == "No Grades"){
          return -1;
        }
        if(b.grade == "No Grades"){
          return 1;
        }
        if(parseInt(a.grade) > parseInt(b.grade)){
          console.log(a.grade +">" + b.grade);
          return 1;
        }else if(parseInt(a.grade) < parseInt(b.grade)){
          console.log(a.grade +"<" + b.grade);
          return -1;
        }else{
          console.log(a.grade +"=" + b.grade);
          return 0;
        }
      });
      console.log(last);
      res.status(200).send(JSON.stringify(last));
  

    })
    /*User.find({},c,function(err,doc){
      for (var i = 0; i < doc.length; i ++){
        console.log(doc.length);
        console.log(doc[i]);
        if(doc[i].grades.length > 0){
          console.log(doc[i].grades[0].grade);
          occurences.push(doc[i].grades[0].grade.slice(0, -1));
          console.log('We found something');
        }
      }
      console.log(occurences)
      occurences.forEach(function(x){
        counts[x]= (counts[x] || 0) + 1;        
      })
      occurences.forEach(function(x){
        var b = {};
        b["grade"] = x;
        b["occurences"] = counts[x];
        last.push(b);
      });
      console.log(last);
      //res.status(200).send(JSON.stringify(last));
    });*/
  }
});
//https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=coursesummary&studentid=000958&action=form&courseCode=33500&courseSection=1&mp=MP3
app.post('/classAverages', function(req,res){
  console.log('classAverages requested for className :' + req.body.className)
  if(req.body.cookie && req.body.id){
    var markingP;
    if(req.body.markingPeriod !== undefined){
      markingP= req.body.markingPeriod
    }else{
      markingP = markingPeriod
    }
    console.log(req.body.cookie + " " + req.body.id);
    var gradebook = {method: 'GET',
        url:'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=coursesummary&studentid=' + req.body.id + 
      '&action=form&courseCode=' + req.body.course +"&courseSection="+ req.body.section + "&mp=" + markingP,
        'rejectUnauthorized' : false,
        headers:{'cache-control' : 'no-cache',
        'content-type': 'application/x-www-form-urlencoded',
        'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.11 (KHTML, like Gecko) Chrome/20.0.1132.27 Safari/536.11',
        "Accept-Encoding" : "gzip, deflate, sdch",
        "Accept-Language" : "en-US,en;q=0.8",
        'Cookie':req.body.cookie          
        }
    };
    request(gradebook,function(error,response,body){
      var results = [];
      if(response.headers["set-cookie"]){
        console.log('needs login');
        var b ={};
        b["set-cookie"] = response.headers["set-cookie"];
        results.push(b);
        res.status(440).send(JSON.stringify(results));
      }else{
        var $ = cheerio.load(body);
        $('td.cellRight').each(function(i,element){
          var assignment = $(this);
          if(assignment.prev().attr('class') == "cellCenter"){
            var value = {};
            value["gradeMax"] = assignment.text().trim();
            var percent = assignment.next().text();
            value["percent"] = percent;
            var grade = assignment.prev().prev();
            var perc = grade.text();
            perc = perc.trim();
            value["grade"] = perc;
            var cat = grade.prev().prev();
            var actual = cat.contents().filter(function(i,el){
              if( $(this).attr('class') == "boxShadow"){
                return "";
              }else{
                return $(this).text().trim();
              }
            });
          
            value["category"] = actual.text().trim();
            results.push(value);
          }
        });
        var container = {};
        results.forEach(function(item){
          console.log(item);
          if(!(item.category in container)){
            if(item.percent != '' && !(isNaN(parseFloat(item.grade)))){
              container[item.category] = {};
              container[item.category].grades = [];
              var lessPercent = item.percent.slice(0,-1)
              container[item.category].grades.push(parseFloat(lessPercent));
              container[item.category].gradeMax = parseFloat(item.gradeMax);
              container[item.category].gradeAchieved = parseFloat(item.grade);
            }
          }else{
            if(item.percent != '' && !(isNaN(parseFloat(item.grade)))){
              var lessPercent = item.percent.slice(0,-1)
              container[item.category].grades.push(parseFloat(lessPercent));
              container[item.category].gradeMax += parseFloat(item.gradeMax);
              container[item.category].gradeAchieved += parseFloat(item.grade);
            }
          }
        });
        console.log(container);
        var finalGrades = [];
        if(container.length != 0){
          for (var k in container) {
            var b = {};
            b["category"] = k;
            b["grades"] = container[k];
            finalGrades.push(b)
          } 
        }
        console.log(finalGrades);
        res.send(JSON.stringify(finalGrades));
      }
    });
  }
});

module.exports = app;
