var express = require('express');
var basicAuth = require('basic-auth-connect');
var app = express();
require('coffee-script/register');
var sync = require('./sync').sync;
app.use(basicAuth('getup', process.env.PASSWORD || 'password'));
app.use(express.static(__dirname + '/public'))
app.post('/sync', function(req, res) {
    sync(function(err){
        if (err){
            res.statusCode = 500;
            res.end(err);
        }else{
            res.end('ok');
        }
    });
});
app.listen(process.env.PORT || 8080);