var GradeChange = require('../models/gradeChange')
var User = require('../models/user')
var request = require('request')
var CryptoJS = require('crypto-js');
var cheerio = require('cheerio');

module.exports = {
	checkForPush : function(currentGradeChange, cn, tchr){
		console.log(currentGradeChange);
		var check = false
		GradeChange.find({}, function (err,elements){
			elements.forEach(function (doc){
				if(!check){
					console.log(doc);
					if(new Date() - doc.timeStamp > 1000*60*60){
						GradeChange.remove(doc);
						doc.save()
					}else{
						if(doc.className == cn && doc.teacher == tchr && currentGradeChange.username != doc.username){
							console.log("match found")
							module.exports.checkForChanges(doc.className,doc.teacher)
							module.exports.resetStack(doc.className)
							check = true;
						}
					}
				}
			});
		});
	},
	resetStack : function(className){
		GradeChange.find({className : new RegExp(className)}, function (err, elements){
			if(err)
				console.log(err)
			for (var i in elements.length){
				var doc = elements[i]
				GradeChange.remove(doc)
				doc.save()
			}
		});
	},
	checkForChanges : function(className,teacher){
		console.log("checking for changes")
		var changed = 1
		var total = 1;
		var breakNeeded = false
		User.find({"grades.subject" : new RegExp(className), "grades.teacher" : new RegExp(teacher)}, function (err,elements){
			if(err)
				console.log(err)
			console.log(elements.length);
			var iterator = 0;
			module.exports.checkDocument(0, elements, changed, total);
			
		})
	},
	checkDocument: function(position, array, changed, total){
		if(position < array.length){
			var doc = array[position]
			console.log("checking doc" + doc.username)                         
			module.exports.retrieveData(doc, function (outcome){
				if(outcome)
					changed ++
				total ++
				if(changed / total < 0.2){
					console.log("threshold broken")
					return
				}else{
					module.exports.checkDocument(position + 1, array, changed, total)
				}
			});
			console.log(changed/total);
		}else{
			return;
		}
	},
	retrieveData : function(doc, callback){
		var pref = doc.preference,
			s = CryptoJS.AES.decrypt(pref.toString(),"LookDown"),
			a = s.toString(CryptoJS.enc.Utf8);
			gradesArray = doc.grades
		var u = doc.studId
		var cookie;
		var second = {method : 'GET',
				url : 'https://parents.mtsd.k12.nj.us/genesis/j_security_check', 
				'rejectUnauthorized' : false,
				headers : {'cache-control':'no-cache',
		          'User-Agent' : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.94 Safari/537.36',
		          "Accept-Language" : "en-US,en;q=0.8",
		          "Accept-Encoding" : "gzip, deflate, sdch"} 
		      	};
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
					form: { 'j_username':u, 'j_password': a} 
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
					form: { 'j_username':u, 'j_password': a} 
				};
				if(home == "https://parents.mtsd.k12.nj.us/genesis"){
					return
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
							'Cookie':cookie
						}
					};
					console.log(home);
						request(ptions, function(error, response,body){

						var gradebook = {method: 'GET',
						url: 'https://parents.mtsd.k12.nj.us/genesis/parents?tab1=studentdata&tab2=gradebook&tab3=weeklysummary&studentid=' + doc.username+ '&action=form',
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
								console.log("REQ 3")
								console.log(response.headers);
								var $ = cheerio.load(body);
								var afterArray = []
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
										num = num.trim();
										if(num.includes('%')){
											num = num.replace('%','');
											var a = Math.round(num);
											num = a + "%";
										}else{
											if(num == "No Grades"){
												num = "0%"
											}else{
												var a = Math.round(num);
												num += "%";
											}
										}
										num = num.trim();
										classroom = classroom.trim();
										teacher = teacher.trim();
										var a = {};
										a["class"] = classroom;
										a["grade"] = num;
										a["teacher"] = teacher;
										afterArray.push(a);
									}
								});
								var bool = false
								for(i in gradesArray.length){
									var before = gradesArray[i]
									var after = afterArray[i]
									if(after["class"] == before.subject && after["grade"] == before.grade){

									}else{
										bool = true
										User.update({username:doc.username, "grades.subject" : before.subject}, {"$set" : {"grades.$.grade" : after.grade}}, function (err, numberAffected, raw){
											if(err){
												console.log(err);
											}
											console.log(numberAffected)
										})
										if(doc.deviceToken && doc.deviceToken != ""){
											var a = {
												"app_id" : "83f615e3-1eab-4055-92ef-cb5f498968c9",
												"contents" : {"en" : "Your grade in " + gradesArray[i].subject + " has changed."},
												"include_player_ids" : [doc.deviceToken]
											}
											console.log(a);
											module.exports.sendNotificationToUser(a);
										}  
									}

								}
								callback(bool)
							});
						});
					});
				}
			})
		});

	},
	sendNotificationToUser : function(message){
		var send = {method: 'POST',
			url: 'https://onesignal.com/api/v1/notifications',
			headers:{'Content-Type' : 'application/json',
				'Authorization':"Basic M2M2NmQzNzUtM2M1My00NjQ3LWE1NzAtOTNlODQ5NTc0YjI2"
				},
			json : message
		};
		request(send, function(error,response,body){
			if(error){
			console.log(error);
			}
			console.log(body);
			console.log(response.headers);
		});
	}
}