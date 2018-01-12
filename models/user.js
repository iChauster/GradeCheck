var mongoose = require('mongoose'),
	Schema = mongoose.Schema,
	passportLocalMongoose = require('passport-local-mongoose');

var User = new Schema({
	username : String,
	password : String,
	phoneNumber : String,
	grades : [{subject:String,grade:String,teacher:String}],
	deviceToken : String,
	studId : String,
	preference : String
});

var options = ({usernameUnique:false})
User.plugin(passportLocalMongoose ,  options);

module.exports = mongoose.model('User', User);

