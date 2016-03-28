var express = require('express');
var request = require('request');
var cheerio = require('cheerio');
var passport = require('passport');
var User = require('../models/user');
var CryptoJS = require('crypto-js');
var ObjectID = require('mongodb').ObjectID;
var app = express.Router();


var markingPeriod = "MP3";
/* GET home page. */
app.get('/', function(req, res, next) {
  
});
app.post('/register', function(req, res) {
	var actual = CryptoJS.AES.encrypt(req.body.password,"LookDown"); //should switch to process.env for higher security reasons
      User.register(new User({ username : req.body.username, phoneNumber : "",grades:[{subject:"", grade:""}], deviceToken: req.body.deviceToken, preference : actual, studId: ""}), req.body.password, function(err, account) {
          if (err) {
          	console.log(err);
            return res.writeHead(400)
            res.end("username taken");
          }else{
          	res.writeHead(200)
          	res.end("RegistrationSuccessful");
          }
  });

});
app.post('/update', function(req,res){
		console.log("user in");
		console.log(req.body.id);
		User.findById(ObjectID(req.body.id), function(err, user) {
			if(err){console.log(err)}
        	if (user) {
            	     
                	user.email = req.body.email ? req.body.email : user.email;
                	user.phoneNumber = req.body.phoneNumber ? req.body.phoneNumber : user.phoneNumber;
                	user.deviceToken = req.body.deviceToken ? req.body.deviceToken : user.deviceToken;
                	user.studId = req.body.studId ? req.body.studId : user.studId;
                  user.username = req.body.username ? req.body.username : user.username;

                	user.save();
                	return res.status(200).end("Process successful");
         
        	} else {
            	return res.status(400).end('User not found');
        	}
    	});
	
});

app.post('/login', passport.authenticate('local'),function (req,res){

	if(req.body.username && req.body.password){
		var cookie;
		var json = [];
    var username;
    var password;
    if(req.body.email){
      username = req.body.email;
      console.log(username + "email found");
    }else{
      username = req.body.username;
      console.log(username + "no email, go to username");
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
  				form: { 'j_username':username, 'j_password': req.body.password} 
  			};

			request(options, function (error, response, body) {
  				if (error) throw new Error(error);
  				console.log(response.headers);
  				console.log(response.statusCode);
  				var home = response.headers['location'];
  				console.log("https://parents.mtsd.k12.nj.us"+home);
  				var hoptions = {method : 'POST',
  					url : 'https://parents.mtsd.k12.nj.us' + home,
  					'rejectUnauthorized' : false,
  					headers : {'cache-control' : 'no-cache',
  					'content-type': 'application/x-www-form-urlencoded',
  					'Cookie':cookie},
  					form: { 'j_username':username, 'j_password': req.body.password} 
  				};
	  			request(hoptions, function(error, response,body){
  					if(error) throw new Error(error);
  					console.log(response.statusCode);
  					console.log(response.headers);
  					cookie = response.headers['set-cookie'];
			
  					home = response.headers['location'];
  					console.log("https://parents.mtsd.k12.nj.us/genesis/"+home);
  					var ptions = {method : 'GET',
  						url : 'https://parents.mtsd.k12.nj.us/genesis/'+home,
  						'rejectUnauthorized' : false,
  						headers : {'cache-control' : 'no-cache',
  						'content-type': 'application/x-www-form-urlencoded',
  						'Cookie':cookie},
  						form: { 'j_username':username, 'j_password': req.body.password} 
  					};
  					console.log(home);
	  				request(ptions, function(error, response,body){
	  					  					
						if(error)throw new Error(error);
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
	  					var name = "studentid";
	  					name = name.replace(/[\[\]]/g, "\\$&");
    					var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
       					results = regex.exec(url);
    					var student = decodeURIComponent(results[2].replace(/\+/g, " "));
    					console.log(student);
    					var s = {};
    					s["id"] = student;
    					s["cookie"] = cookie;
    					json.push(s);
  						var gradebook = {method: 'GET',
  							url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + req.body.id + '&action=form',
  							'rejectUnauthorized' : false,
  							headers:{'cache-control' : 'no-cache',
  							'content-type': 'application/x-www-form-urlencoded',
  							'Cookie':cookie
  							}
  						};

  						request(gradebook,function(error,response,body){
  							
  							var $ = cheerio.load(body);
  							$('td.cellRight').each(function(i,element){
  								var grade = $(this);
  								if(grade.attr('style') == "cursor:pointer;"){
  									var classroom = grade.prev().prev().text();
  									var teacher = grade.prev().text();
  									teacher = teacher.replace("Email:","");
  									var num = grade.text();
  									num = num.trim();
  									classroom = classroom.trim();
  									teacher = teacher.trim();
  									var a = {};
  									a["class"] = classroom;
  									a["grade"] = num;
  									a["teacher"] = teacher;
  									json.push(a);
  								}
  							});
  							console.log(json);
							res.send(JSON.stringify(json));
  						});
  						}
  					});
  				});
			});
		});
	}
});
app.post('/gradebook', function(req,res){
	if(req.body.cookie && req.body.id){
		console.log(req.body.cookie);
		console.log(req.body.id);
		var rep = [];
		var go = {method:'GET',
			url : 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + req.body.id + '&action=form',
			'rejectUnauthorized' : false,
			headers:{'cache-control' : 'no-cache',
			'content-type' : 'application/x-www-form-urlencoded',
			'Cookie' : req.body.cookie}
		};
		request(go,function(error,response,body){
			if(response.headers["set-cookie"]){
				console.log('needs login');
				var b = {};
				b["set-cookie"] = response.headers["set-cookie"];
				rep.push(b);
				
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
  						var classroom = grade.prev().prev().text();
  						var teacher = grade.prev().text();
  						teacher = teacher.replace("Email:","");
  						var num = grade.text();
  						num = num.trim();
  						classroom = classroom.trim();
  						teacher = teacher.trim();
  						var a = {};
  						a["class"] = classroom;
  						a["grade"] = num;
  						a["teacher"] = teacher;
  						rep.push(a);
  					}
  				});
  				console.log(rep);
				res.send(JSON.stringify(rep));
  			}
  			
			

		});
	}
});
app.post('/listassignments',function(req,res){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth() + 1;
	var yyyy = today.getFullYear();
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
			'&action=form&dateRange=' + markingPeriod + '&date=' + dateString + "&courseAndSection=" + req.body.course +":"+ req.body.section,
			'rejectUnauthorized' : false,
			headers:{'cache-control' : 'no-cache',
			'Cookie' : req.body.cookie}
		}
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
  						var teacherName = teachr.text().trim();
  						value["teacher"] = teacherName;
  						var course = teachr.prev();
  						var courseName = course.text().trim();
  						value["course"] = courseName;
  						var due = course.prev();
  						var dueDate = due.text().trim();
  						value["dueDate"] = dueDate;
  						var another = due.prev();
  						var str = another.text().trim();
  						value["stringDate"] = str;
  						results.push(value);
  					}
  				}); 
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
		var gradebook = {method: 'GET',
  				url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=listassignments&studentid=' + req.body.id + '&action=form',
  				'rejectUnauthorized' : false,
  				headers:{'cache-control' : 'no-cache',
  				'content-type': 'application/x-www-form-urlencoded',
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
  						var teacherName = teachr.text().trim();
  						value["teacher"] = teacherName;
  						var course = teachr.prev();
  						var courseName = course.text().trim();
  						value["course"] = courseName;
  						var due = course.prev();
  						var dueDate = due.text().trim();
  						value["dueDate"] = dueDate;
  						var another = due.prev();
  						var str = another.text().trim();
  						value["stringDate"] = str;
  						total.push(value);
  					}

  				}); 
  				res.send(JSON.stringify(total));			

  			}
  		
  		});
	}
});
app.post('/classdata', function(req,res){
  if(req.body.className){
    console.log(req.body.cookie + " " + req.body.id + " " + req.body.className);
    var a = {};
    a["subject"] = req.body.className;
    var b = {};
    b["$elemMatch"] = a;
    var c = {};
    c["grades"] = b;
    var occurences = [];
    var counts = {};
    var last = [];
    User.find({},c,function(err,doc){
      for (var i = 0; i < doc.length; i ++){
        console.log(doc.length);
        console.log(doc[i].grades[0].grade);
        occurences.push(doc[i].grades[0].grade.slice(0, -1));
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
    });
    
    res.status(200).end('Process "classdata" completed');

  }
});

module.exports = app;
