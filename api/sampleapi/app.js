// Copyright (c) 2020 Davide Gironi
// Please refer to LICENSE file for licensing information.

const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const cors = require('cors');

const app = express();

app.use(bodyParser.json(), cors());

// get port from command line as the first parameter
const port = process.env.PORT || 9000;

// sample server message
app.get('/', (req, res) => {
  res.send('AppDressBook RESTful sample server');
});

// get the config
app.get('/api/appdressbookconfig', (req, res) => {
  console.log('-- GET CONFIG --');
  fs.readFile('sampleconfig.json', 'utf8', (err, data) => {
    const obj = JSON.parse(data);
    res.setHeader('Content-Type', 'application/json');
    res.send(obj);
  });
});


// return the login token
app.post('/api/appdressbookauth', (req, res) => {
  console.log('-- LOGIN --');
  console.log(`username: ${req.body.username}`);
  console.log(`password: ${req.body.password}`);
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify({
    token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfdXNlcm5hbWUiOiJ0ZXN0LnVzZXIiLCJfZGlzcGxheW5hbWUiOiJUZXN0IFVzZXIiLCJuYmYiOjk0NjY4NDgwMCwiZXhwIjo0MDY4MTQ0MDAwLCJpYXQiOjk0NjY4NDgwMCwiaXNzIjoiQWRkRHJlc3NCb29rU2VydmVyU2FtcGxlIiwiYXVkIjoiQWRkRHJlc3NCb29rU2VydmVyU2FtcGxlIn0.S8tUudaR2c4u_O2YsuM5WCaaNg-cFu4Xqx1ACPd9M58'
  }));
});

// refresh the login token expires days
app.put('/api/appdressbookauth', (req, res) => {
  console.log('-- REFRESH LOGIN TOKEN --');
  console.log(`token: ${req.headers.authtoken}`);
  console.log(`expiresdays: ${req.body.expiresdays}`);
  res.setHeader('Content-Type', 'application/json');
  res.send(JSON.stringify({
    token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfdXNlcm5hbWUiOiJ0ZXN0LnVzZXIiLCJfZGlzcGxheW5hbWUiOiJUZXN0IFVzZXIiLCJuYmYiOjk0NjY4NDgwMCwiZXhwIjo0MDY4MTQ0MDAwLCJpYXQiOjk0NjY4NDgwMCwiaXNzIjoiQWRkRHJlc3NCb29rU2VydmVyU2FtcGxlIiwiYXVkIjoiQWRkRHJlc3NCb29rU2VydmVyU2FtcGxlIn0.S8tUudaR2c4u_O2YsuM5WCaaNg-cFu4Xqx1ACPd9M58'
  }));
});

// get the contacts list
app.get('/api/appdressbookcontacts', (req, res) => {
  const { mode } = req.query;
  console.log('-- GET CONTACTS --');
  console.log(`token: ${req.headers.authtoken}`);
  console.log(`mode: ${mode}`);
  fs.readFile('samplecontacts.json', 'utf8', (err, data) => {
    const obj = JSON.parse(data);
    if (mode === 'h') {
      console.log('-- GET CONTACTS HASH --');
      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.stringify({
        hash: obj.hash
      }));
    } else if (mode === 'l') {
      console.log('-- GET CONTACTS LIST --');
      res.setHeader('Content-Type', 'application/json');
      res.send(obj);
    } else {
      res.send({});
    }
  });
});

app.listen(port, () => console.log(`AppDressBook sample server is listening on port.${port}`));
