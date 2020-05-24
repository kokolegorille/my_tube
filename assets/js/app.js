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

// Polyfill for IE11 and MS Edge 12-18
import "mdn-polyfills/CustomEvent"
import "mdn-polyfills/String.prototype.startsWith"
import "mdn-polyfills/Array.from"
import "mdn-polyfills/NodeList.prototype.forEach"
import "mdn-polyfills/Element.prototype.closest"
import "mdn-polyfills/Element.prototype.matches"
import "child-replace-with-polyfill"
import "url-search-params-polyfill"
import "formdata-polyfill"
import "classlist-polyfill"
import "shim-keyboard-event-key"

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

// ====================================
// Liveview
// ====================================

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
liveSocket.connect()

window.liveSocket = liveSocket