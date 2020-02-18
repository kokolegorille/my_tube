const webpack = require('webpack');
const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const VENDOR_LIBS = [
  'bootstrap', 'jquery', 'popper.js',
];

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      // new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    app: './js/app.js',
    vendor: VENDOR_LIBS.concat(glob.sync('./vendor/**/*.js')),
  },
  output: {
    filename: 'js/[name].js',
    path: path.resolve(__dirname, '../priv/static')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      // Load stylesheets
      {
        test: /\.(css|scss)$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader',
        ]
      },
      // Load images
      {
        test: /\.(png|svg|jpe?g|gif)(\?.*$|$)/,
        loader: 'url-loader?limit=10000',
      },
      // Load fonts
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?(\?.*$|$)/,
        use: 'url-loader?&limit=10000&name=/fonts/[name].[ext]',
      },
      {
        test: /\.(eot|ttf|otf)?(\?.*$|$)/,
        loader: 'file-loader?&limit=10000&name=/fonts/[name].[ext]',
      },
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: './css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: './' }]),
    new webpack.ProvidePlugin({ // inject ES5 modules as global vars
      $: 'jquery',
      jquery: 'jquery', 'window.jQuery': 'jquery',
      Popper: ['popper.js', 'default'],
    })
  ]
});
