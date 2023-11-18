(Done) GET /users: Returns users DynamoDB table structure.
(ToDo) POST /users/{UserData}: Create a new user.
(Done) GET /users/{UserID}: Get information about the specific users from table users.
(Done) DELETE /users/{UserID}: Delete a specific user giving the UserID.

(Done) GET /packs: Returns all question packs
(Done) GET /packs/{PackID}: Return question pack data.
(ToDo) POST /question_pack: Create a question_pack.
(ToDo) GET /packs/{PackID}/{Number}: Get the specific question number from the question pack.

GET /question/{PackID}/random_category/{QuestionNumber}: Get the numbered question from question_pack.
GET /question/{PackID}/random_category/random_question: Get a random question from the question_pack.
GET /question/{PackID}/{CategoryName}/{QuestionNumber}: Get the numbered question from the specific CategoryName from the question_pack.
GET /question/{PackID}/{CategoryName}/random_question: Get a random question from the specific CategoryName from the question_pack.