const httpStatus = require('http-status');
const user = require('./user.helper');
const yaml = require('js-yaml');
const fs = require('fs');
const exec = require('child_process').exec;

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
      // Read the prometheus configuration
      const doc = yaml.safeLoad(fs.readFileSync(process.env.PROMETHEUS_YML, 'utf8'));
      let targets = doc.scrape_configs[1].static_configs[0].targets;

      if (targets.indexOf(user.metrics_host) > -1) {
        return res.send(user);
      }

      targets.push(user.metrics_host);
      console.log('----- scrape_configs targets ------', targets, '-----------');
      const updatedYaml = yaml.safeDump(doc);
      console.log('----- Update yml ---------', updatedYaml);

      fs.writeFile(process.env.PROMETHEUS_YML, updatedYaml, function (err) {
        if (err) {
          console.log(err);
          return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(err);
        }
        console.log('----- Prometheus yml file updated successfully ---------');
        console.log('----- Restarting prometheus server -------');
        exec('pm2 stop ' + process.env.PROMETHEUS_PM2_PROCESS, (err, stdout, stderr) => {
          if (err) {
            console.log('Failed to restart server')
          }

          console.log(`stdout: ${stdout}`);
          console.log(`stderr: ${stderr}`);
        });
      });
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
