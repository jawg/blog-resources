import serve from 'rollup-plugin-serve';
import dotenvPlugin from 'rollup-plugin-dotenv';
import { emptyDirectories } from 'rollup-plugin-app-utils';
import { copy } from '@web/rollup-plugin-copy';
const output = '.serve';

export default [
  {
    input: 'empty.js',
    output: { dir: output },
    plugins: [
      emptyDirectories(output),
      dotenvPlugin.default(),
      copy({ patterns: ['hellowatt/**', 'hillshade-and-dem/**', 'map-request-counter/**'], exclude: 'node_modules/**' }),
      {
        name: 'replace-access-token',
        async generateBundle(_, bundle) {
          Object.keys(bundle)
            .filter((file) => /\.(html|json)$/.test(file))
            .forEach((file) => {
              console.log(file)
              const source = bundle[file].source.toString().replace(/YOUR_ACCESS_TOKEN/g, process.env.JAWG_ACCESS_TOKEN);
              bundle[file].source = Buffer.from(source);
            });
        },
      },
      serve({ host: 'localhost', port: 8000, contentBase: [output, './'] }),
    ],
  },
];
