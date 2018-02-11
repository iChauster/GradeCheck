var mongoose = require('mongoose'),
	Schema = mongoose.Schema

var GradeChange = new Schema({
	username : String,
	className: String,
	teacher : String,
	timeStamp : Date
})

module.exports = mongoose.model('GradeChange', GradeChange)