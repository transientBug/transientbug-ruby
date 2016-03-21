var webpack = require('webpack');
var path = require('path');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

var options = {
  entry: {
    'app': [ 'babel-polyfill', './app/js/main.js' ],
    'styles': './app/scss/main.scss'
  },
  output: {
    path: __dirname + '/public/static',
    filename: '[name].js'
  },
  devtool: '#cheap-module-source-map',
  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js']
  },
  module: {
    loaders: [
      {
        include: [
          __dirname + '/app/js'
        ],
        test: /\.jsx?$/,
        loader: 'babel-loader',
        query: {
          plugins: [ 'transform-runtime', 'transform-decorators-legacy', 'transform-es2015-modules-amd' ],
          presets: [ 'es2015', 'stage-0', 'react' ],
        }
      },
      {
        include: [
          __dirname + '/app/scss'
        ],
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader')
      },
      {
        include: [
          __dirname + '/app/scss'
        ],
        test: /\.css$/,
        loader: ExtractTextPlugin.extract('style-loader', 'css-loader')
      },
      {
        test: /\.(woff2?|ttf|eot|svg|png)(\?.*?)?$/,
        loader: 'file'
      }
    ]
  },
  plugins: [
    //new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new ExtractTextPlugin('styles.css', {
      allChunks: true
    }),
    new webpack.ProvidePlugin({
      $: 'jquery',
      _: 'lodash',
      React: 'react',
      ReactDOM: 'react-dom',
      autobind: 'autobind-decorator'
    })
    //new webpack.DefinePlugin({
    //  "process.env": {
    //    NODE_ENV: '"production"'
    //  }
    //}),
    //new webpack.NoErrorsPlugin()
  ]
};

module.exports = options;
