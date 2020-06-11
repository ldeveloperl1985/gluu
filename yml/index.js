const jsyaml = require('js-yaml');
const fs = require('fs');
const SwaggerParser = require("@apidevtools/swagger-parser");
const yaml = require("node-yaml");

try {
    const file = yaml.readSync('swagger.yaml');
    console.log(file.paths['/fido2/attestation/result'])
    // const paths = yaml.readSync(file.paths);
    // console.log(paths);
} catch(e) {
    console.log(e);
}

// SwaggerParser.parse('https://raw.githubusercontent.com/GluuFederation/oxd/version_4.0/oxd-server/src/main/resources/swagger.yaml', {circular: true}, (err, api) => {
//     if (err) {
//         console.error(err);
//     }
//     else {

//         console.log(api);
//         console.log("API name: %s, Version: %s", api.info.title, api.info.version);

//     }
// });

// Get document, or throw exception on error
// try {
//     var SexyYamlType = new jsyaml.Type('!sexy', {
//         kind: 'sequence',
//         construct: function (data) {
//             return data.map(function (string) { return 'sexy ' + string; });
//         }
//     });

//     var SEXY_SCHEMA = jsyaml.Schema.create([SexyYamlType]);

//     const doc = jsyaml.load(fs.readFileSync('swagger.yaml'), { schema: SEXY_SCHEMA, flowLevel: 4});
//     console.log(doc);
// } catch (e) {
//     console.log(e);
// }