GET /users: Returns users DynamoDB table structure.
POST /users: Create a new user.
GET /users/{UserID}: Get information about the specific users from table users.

GET /question_pack: Returns users DynamoDB question_pack structure.
POST /question_pack: Create a question_pack.
GET /question_pack/{PackID}: Get information about the specific pack from table question_packs.

GET /question/{PackID}/random_category/{QuestionNumber}: Get the numbered question from question_pack.
GET /question/{PackID}/random_category/random_question: Get a random question from the question_pack.
GET /question/{PackID}/{CategoryName}/{QuestionNumber}: Get the numbered question from the specific CategoryName from the question_pack.
GET /question/{PackID}/{CategoryName}/random_question: Get a random question from the specific CategoryName from the question_pack.