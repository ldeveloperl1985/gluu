const express = require('express');
const router = express.Router();
const userController = require('./user.controller');

router.route('/')
  .get(userController.getAll)
  .post(userController.add);

router.route('/registration')
  .post(userController.registration);

router.route('/:id')
  .get(userController.getById)
  .put(userController.update)
  .delete(userController.remove);

router.route('/search')
  .post(userController.search);

module.exports = router;
