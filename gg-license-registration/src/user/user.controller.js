const httpStatus = require('http-status');
const user = require('./user.helper');

function search(req, res) {
  user.getUserBySearch(req.body)
    .then(users => {
      return res.send(users);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
};

function getAll(req, res) {
  user.getAllUsers()
    .then(users => {
      return res.send(users);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

function getById(req, res) {
  user.getUserById(req.params.id)
    .then(users => {
      return res.send(users);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

function registration(req, res) {
  user.registration(req.body)
    .then(user => {
      return res.send(user);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

function add(req, res) {
  user.addUser(req.body)
    .then(user => {
      return res.send(user);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

function update(req, res) {
  user.updateUser(req.body, req.params.id)
    .then(user => {
      return res.send(user);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

function remove(req, res) {
  user.removeUser(req.params.id)
    .then(user => {
      return res.send(user);
    })
    .catch(error => {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(error);
    });
}

module.exports = {
  search,
  getAll,
  getById,
  add,
  registration,
  update,
  remove,
};
