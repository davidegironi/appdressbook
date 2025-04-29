RESTful API AppDressBook

The aim of the API server is to guarantee the syncronization and authentication of the user.
Each company/association should build it's own server.
The authentication can be used to prevent undesired access, but it can also be skipped, in this case AppDressBook will not ask for a login.
Server side it would be easy to build contact list based on the user permissions. 
The API server could be implemented in several languages, it just must meets the specification above.
Authorization token is in JWT format.
Find the openapi yaml file