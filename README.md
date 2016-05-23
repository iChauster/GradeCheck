# GradeCheck
Gradecheck is a school project I created to help students get important information quicker, easier, and more efficiently than using existing services. It is built with a NodeJS-Express Backend, MongoDB, Swift,and Jade.

The project is based on using Genesis, a grade system that many schools in New Jersey use. My [server](/app.js) [and routes](/routes/index.js) can even be configured for other schools using Genesis as well. However, Genesis is isolated from its students - its website is slow and hard to use, and is hard to access important information for students. My app aims to fix this.

While Genesis provides grades and assignments, my application aims to go deeper. Instead of reading a grade or an assignment, the student can see the impact behind each grade and assignment, and is given the chance to plan ahead and devote focus.

This application is used in conjunction with the iOS calendar and can project future grades, automate GPA, get statistics like grade averages, grade curves, and even your averages on different types of assignments. This is all so the student can plan ahead and see where they stand to focus and work on certain areas academically.

The Push Notification service was also working to check for changes, but we are working with the school itself to develop a better, more efficient way to be run. 

# Screenshots
<img src="/screenshots/GradeTable.PNG" width="285">
<img src="/screenshots/Projections.PNG" width="285">
<img src="/screenshots/Stats.PNG" width="285">

### future
Ultimately, I want to impact the students, many of which are my peers, as much as possible. Creating this platform has already allowed many students to plan ahead and see where they need to focus and improve. 
###### Here are some things I plan to implement in the forseeable future:
-- A better push notification service
-- Safer authentication between iOS and Server, and Server and Genesis
-- Study plans for a large assignment coming up.
-- Integration with School Events, clubs, etc.
-- Wearable Applications, Android Application
-- Integration amongst other schools, and attachments with other services, like Google Classroom, etc.
