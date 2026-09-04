// Packs @olk_ship_throttle/addons/ship_throttle/ into
// @olk_ship_throttle/addons/ship_throttle.pbo using gulp-armapbo, a
// pure-JS/Node Arma PBO packer - no Windows, Steam, or Arma 3 Tools
// needed. Run `npm install && node build.js` from this directory.

const path = require('path');
const vfs = require('vinyl-fs');
const pbo = require('gulp-armapbo');

const srcDir = path.resolve(__dirname, '..', '..', '@olk_ship_throttle', 'addons', 'ship_throttle');
const outDir = path.resolve(__dirname, '..', '..', '@olk_ship_throttle', 'addons');

vfs.src([`${srcDir}/**/*`, `!${srcDir}/$PBOPREFIX$`], { base: srcDir, dot: true, nodir: true })
    .pipe(pbo.pack({
        fileName: 'ship_throttle.pbo',
        extensions: [
            { name: 'prefix', value: 'olk_ship_throttle\\addons\\ship_throttle' },
            { name: 'author', value: 'Olaf' }
        ],
        compress: ['**/*.sqf', '**/*.hpp', '**/*.cpp']
    }))
    .pipe(vfs.dest(outDir))
    .on('data', (file) => console.log('Wrote', file.path, file.contents.length, 'bytes'))
    .on('end', () => console.log('PBO build complete'))
    .on('error', (e) => { console.error('PBO build failed:', e); process.exitCode = 1; });
