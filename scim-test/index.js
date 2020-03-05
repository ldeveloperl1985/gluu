var express = require('express');

var config = {
  keyAlg: 'RS384',
  domain: 'https://gluu.local.org',
  privateKey: 'final-private-key.key',
  clientId: '1202.6149e3be-23f3-4fd9-8dc6-026dfa4954f7',
  keyId: '4df5feb7-2546-44dd-825a-2ca4901933ec_sig_rs384'
};
var scim2 = require('scim-node')(config).scim2;
var app = express();

app.get('/users', function (req, res) {
  scim2.getUsers(0, 5)
    .then(function(data) {
      return res.send(data);
    })
    .catch(function(error) {
      return res.send(error);
    })
});

// For self-signed certificate.
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

app.listen(3000, function () {
  console.log('Server running on port 3000');
});
