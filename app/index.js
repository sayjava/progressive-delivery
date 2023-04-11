const express = require("express");
const metrics = require('express-prometheus-middleware');
const winston = require('winston');
const expressWinston = require('express-winston');

const app = express();
const PORT = process.env.PORT || 3000;

const version = process.env.VERSION || 'v1'

const good = (req, res) => {

	if (req.headers["content-type"].includes('json')) {
		return res.json({
			...req.params,
			version
		})
	}

	res
		.status(200)
		.setHeader('content-type', 'text/html')
		.send(
			`<html>
				<head>
					<title>Progressive App ${version}</title>
				</head>
				<body style="background: grey; color: white">
					<main>
						<h1>
							Welcome to progressive APP  <span style="color: blue">${version}</span>
						</h2>
						<div>
							<ul>
								<li>HOST: ${req.headers.host}</li>
								<li>User Agent: ${req.headers["user-agent"]}</li>
								<li>: ${req.headers["user-agent"]}</li>
							</ul>
						</div>
					</main>
				</body>
			</html>`
		)
}

const error = (_, res) => {
	res
		.status(500)
		.setHeader('content-type', 'text/html')
		.send(
			`
			<html>
				<head>
					<title>Server Error</title>
				</head>
				<body>
					<div>
						Server Blew UP
					</div>
				</body>
			</html>
		`
		)
}

const quit = (_, res) => {
	console.error('Server Exited')
	process.exit(-1)
}

const slow = (_, res) => {
	setTimeout(() => good(_, res), 3000)
}

app.get('/status', (_, res) => {
	res
		.setHeader('content-type', 'application/json')
		.json({ ok: true })
})

app.use(expressWinston.logger({
	transports: [
		new winston.transports.Console()
	]
}))

app.use(metrics({
	metricsPath: '/metrics',
	collectDefaultMetrics: false,
	requestDurationBuckets: [0.1, 0.5, 1, 1.5],
	requestLengthBuckets: [512, 1024, 5120, 10240, 51200, 102400],
	responseLengthBuckets: [512, 1024, 5120, 10240, 51200, 102400],
	customLabels: ['version'],
	transformLabels: (labels) => {
		labels.version = version
	}
}))

switch (version) {
	case 'error':
		app.get('/', error)
		break;
	case 'quit':
		app.get('/', quit)
		break;
	case 'slow':
		app.get('/', slow)
		break;
	default:
		app.get('/', good)
}


app.listen(PORT, () => console.log(`App listening at port ${PORT} with version ${version}`));