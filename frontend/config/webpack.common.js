var webpack = require('webpack');

module.exports = {
  entry: {
    'polyfills': './src/polyfills.ts',
    'vendor': './src/vendor.ts',
    'app': './src/index.ts'
  },

  output: {
    path: '../public',
    filename: '[name].js'
  },

  resolve: {
    extensions: ['', '.js', '.ts', '.css', '.scss']
  },

  module: {
    loaders: [
      { test: /\.ts$/, loader: 'ts' },
      { test: /\.s?css$/, loaders: ["style-loader", "css-loader", "sass-loader"] }
    ]
  },

  plugins: [
    new webpack.optimize.CommonsChunkPlugin({ name: ['app', 'vendor', 'polyfills'] })
  ]
};
