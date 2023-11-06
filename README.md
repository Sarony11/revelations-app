# Revelations Q&A Web Application

Welcome to the repository of our social Revelations Q&A web application, designed for groups to engage in interactive question-and-answer sessions to create deep and insighful connections. Our app curates packs of questions categorized by themes to facilitate lively discussions and group activities.

## Features

- **User Profiles**: Users can create profiles, indicating the number of participants and their names.
- **Question Packs**: Select from a variety of question packs suited for different group dynamics and settings.
- **Category Selection**: Users can choose to receive random questions from the entire pack or from specific categories within the pack.
- **Interactive Gameplay**: After successfully responding to a question, the app proceeds to the next participant, ensuring everyone gets a turn.
- **Serverless Backend**: Utilizes managed serverless services for scalability and ease of maintenance.
- [**API for Content Management**](https://raw.githubusercontent.com/Sarony11/revelations-app/master/design/api_endpoints.md?token=GHSAT0AAAAAACJ5EMWAXQLB7KRCRU4S54LAZKISJEQ): Securely add new question packs via a JSON formatted API with token authentication.

## Data Structure
[**Data structure**](https://raw.githubusercontent.com/Sarony11/revelations-app/master/design/data_structure.md?token=GHSAT0AAAAAACJ5EMWATSEMPQ47PY2EJJ2KZKISKKQ)

## Web Structure
[**Web structure**](https://raw.githubusercontent.com/Sarony11/revelations-app/master/design/web_structure.md?token=GHSAT0AAAAAACJ5EMWBXNQRKS2UIEYX26I4ZKISLYA)

## DevOps and IaC

We adhere to DevOps best practices to streamline development, deployment, and operations. The entire infrastructure is codified using Terraform, enabling us to manage our cloud resources as code.

## Continuous Integration and Continuous Deployment (CI/CD)

Our CI/CD pipeline is orchestrated with GitHub Actions, automating our testing, building, and deployment processes.
