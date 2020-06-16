const jsyaml = require('js-yaml');
const fs = require('fs');

// Get document, or throw exception on error
try {
    const doc = jsyaml.load(fs.readFileSync('swagger.yaml'));
    console.log(doc.paths['/services'].post);
} catch (e) {
    console.log(e);
}