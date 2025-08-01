import * as dotenv from 'dotenv';
import fastify from 'fastify';
import fastifyStatic from '@fastify/static';
import * as path from 'path';

const dotenvResult = dotenv.config({
  encoding: 'UTF-8',
  path: __dirname + '/../.env',
  quiet: true,
});

type ENOENT = Error & {code?: 'ENOENT'};

const dotenvError = <Error | ENOENT>dotenvResult.error;

// Do not throw an error if the .env file cannot be opened.
if (dotenvError && 'code' in dotenvError && dotenvError.code !== 'ENOENT')
  throw dotenvError;

const host = process.env.HOST || 'localhost';
const port = process.env.PORT ? parseInt(process.env.PORT) : 8080;

const app = fastify();

void app.register(fastifyStatic, {
  root: path.join(__dirname, '../public'),
});

app
  .listen({host, port})
  .then(address => console.log(`Listening on ${address}...`))
  .catch(console.error);
