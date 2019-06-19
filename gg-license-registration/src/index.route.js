const express = require('express');
const router = express.Router();
const user = require('./user/user.route');

/**
 * Default route.
 */
router.get('/health-check', (req, res) => res.status(200).send({
  message: 'Cool'
}));

router.use('/user', user);

module.exports = router;
