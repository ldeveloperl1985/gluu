const user = require('./user.model');

/**
 * Get all active users
 * @return {users} - return all users
 * @return {err} - return error
 */
let getUserBySearch = (params) => {
  return user
    .search(params)
    .then((users) => Promise.resolve(users))
    .catch((err) => Promise.reject(err));
};

/**
 * Get all active users
 * @return {users} - return all users
 * @return {err} - return error
 */
let getAllUsers = () => {
  return user
    .find({})
    .sort({name: 1})
    .exec()
    .then((users) => Promise.resolve(users))
    .catch((err) => Promise.reject(err));
};

/**
 * Get user by Id
 * @param {ObjectId} id - user id
 * @return {user} - return user
 * @return {err} - return error
 */
let getUserById = (id) => {
  return user
    .findById(id)
    .exec()
    .then((user) => Promise.resolve(user))
    .catch((err) => Promise.reject(err));
};

/**
 * Register user
 * If already exist then update
 * @param {object} req - Request json object
 * @return {user} - return user
 * @return {err} - return error
 */
let registration = (req, id) => {
  return user
    .findOne({ metrics_host: req.metrics_host })
    .exec()
    .then((oUser) => {
      if (oUser) {
        oUser.email = req.email || oUser.email;
        oUser.metrics_host = req.metrics_host || oUser.metrics_host;
        oUser.organization = req.organization || oUser.organization;
      } else {
        oUser = new user();
        oUser.email = req.email;
        oUser.metrics_host = req.metrics_host;
        oUser.organization = req.organization;
      }

      return oUser.save()
        .then(updatedUser => Promise.resolve(updatedUser))
        .catch(err => Promise.reject(err));
    })
    .catch(err => Promise.reject(err));
};

/**
 * Add user
 * @param {object} req - Request json object
 * @return {user} - return user
 * @return {err} - return error
 */
let addUser = (req) => {
  let oUser = new user();
  oUser.email = req.email;
  oUser.metrics_host = req.metrics_host;
  oUser.organization = req.organization;

  return oUser.save()
    .then(user => Promise.resolve(user))
    .catch(err => Promise.reject(err));
};

/**
 * Update user
 * @param {object} req - Request json object
 * @return {user} - return user
 * @return {err} - return error
 */
let updateUser = (req, id) => {
  return user
    .findById(id)
    .exec()
    .then((oUser) => {
      oUser.email = req.email || oUser.email;
      oUser.metrics_host = req.metrics_host || oUser.metrics_host;
      oUser.organization = req.organization || oUser.organization;

      return oUser.save()
        .then(updatedUser => Promise.resolve(updatedUser))
        .catch(err => Promise.reject(err));
    })
    .catch(err => Promise.reject(err));
};

/**
 * Remove user by Id
 * @param {ObjectId} id - user id
 * @return {user} - return user
 * @return {err} - return error
 */
let removeUser = (id) => {
  return user
    .findById(id)
    .exec()
    .then((oUser) => {
      return oUser
        .remove()
        .then((rUser) => Promise.resolve(rUser))
        .catch(err => Promise.reject(err));
    })
    .catch(err => Promise.reject(err));
};

module.exports = {
  getAllUsers,
  getUserById,
  addUser,
  updateUser,
  removeUser,
  getUserBySearch,
  registration
};
