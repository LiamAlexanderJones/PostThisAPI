# PostThisAPI
Vapor API for PostThis app

This API uses server side Swift with Vapor to connect to the PostThis app. To run it, you will need to set up a PostgreSQL database with a database name "postthis", a username "postgres" and a password "vapor_password". You can find and change these dtails in the configure file.

The API is set up to save images in the resources folder. To make this work, you need to use a custom working directory. Go to Produce > Scheme > Edit Scheme. Select Run, and the Options Tab. Check the Custom Working Directory box, and put the directory where you're hold the API in the text box.
