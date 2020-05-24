const webpack = require('webpack');
const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const VENDOR_LIBS = [
  'bootstrap', 'jquery', 'popper.js',
];

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
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
    devtool: devMode ? 'source-map' : undefined,
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
      // Obsolete 5.1.1 syntax
      // new CopyWebpackPlugin([{ from: "static/", to: "./" }]),
      // New 6.0.1 syntax
      // https://webpack.js.org/plugins/copy-webpack-plugin/
      new CopyWebpackPlugin({
        patterns: [{ from: "static/", to: "./" }]
      }),
      new webpack.ProvidePlugin({ // inject ES5 modules as global vars
        $: 'jquery',
        jquery: 'jquery', 'window.jQuery': 'jquery',
        Popper: ['popper.js', 'default'],
      })
    ]
  }
};
