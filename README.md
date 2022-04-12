# Camille

## Getting Started

### Set up the project

- Clone the project.
- Double click Package.swift.
-  [Create a Slack app](https://api.slack.com/apps). Click "Add features and functionality," and add the "Bots" feature.
- Set up [ngrok](https://ngrok.com) for development. Run `ngrok http http://0.0.0.0:8080` to expose your local server to the internet.
- Copy the URL ngrok gives you (it'll be something like `http://abc123.ngrok.io`). 
- Go back to your Slack app's settings and add the ngrok URL in the Slack app permissions page under "Redirect URIs" with `/oauth` at the end of it (so, in our example, `http://abc123.ngrok.io/oauth`)
- If you're developing against the production version of Camille setup [redis](https://redis.io). [Docker](https://docs.docker.com/docker-for-mac/install/) is an easy way to do this. If you have docker installed, run `docker run --name redis -p 6379:6379 -d redis`. Otherwise you can use `MemoryStorage` in place of redis.
- Set the project's environment variables. Click the scheme dropdown, and hit "edit scheme."
- Set the `STORAGE_URL` environment variable to the redis URL (`redis://127.0.0.1:6379` by default)
- Set `CLIENT_ID` and `CLIENT_SECRET` to the IDs that Slack shows on your App page. (Alternatively message @mergesort for some development credentials you can use for testing an integration.)
- Set `REDIRECT_URI` to the redirect URL we set earlier ( `http://abc123.ngrok.io/oauth`, in our example)
- Run the project
- Visit `http://0.0.0.0:8080/login` and authorize the app.
- You should be online now!
