// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import "babel-polyfill";

// ====================================
// Bootstrap dynamic file input
// ====================================

import bsCustomFileInput from 'bs-custom-file-input'

$(document).ready(() => bsCustomFileInput.init());

// ====================================
// Limit the size of files, client side
// ====================================

const maxFileSize = 200;

$(document).ready(() => $(".custom-file-input").on("change", e => {
  e.stopPropagation();
  e.stopImmediatePropagation();
  
  const sizeInMB = ((e.currentTarget.files[0].size/1024)/1024).toFixed(4);
  if (sizeInMB > maxFileSize) {
    console.log(`File is too big ${sizeInMB} MB`)
    e.target.value = "";
  }
}));

// ====================================
// Sidebar
// ====================================

$(document).ready(() => {
  // $("#sidebar").mCustomScrollbar({
  //     theme: "minimal"
  // });

  $('#dismiss, .overlay').on('click', () => {
    // hide sidebar
    $('#sidebar').removeClass('active');
    // hide overlay
    $('.overlay').removeClass('active');
  });

  $('#sidebarCollapse').on('click', () => {
      // open sidebar
      $('#sidebar').addClass('active');
      // fade in the overlay
      $('.overlay').addClass('active');
      $('.collapse.in').toggleClass('in');
      $('a[aria-expanded=true]').attr('aria-expanded', 'false');
  });
});
