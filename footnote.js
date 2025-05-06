// https://github.com/getzola/zola/issues/1070#issuecomment-1166637092
// mostly unnecessary now that zola supports footnotes natively

function addFootnoteLine() {
  let footer = document.querySelector('footer.footnotes');
  let hr = document.createElement('hr');
  footer.before(hr);
}

// The DOMContentLoaded event fires when the initial HTML
// document has been completely loaded and parsed, without
// waiting for stylesheets, images, and subframes to finish loading.
if (document.readyState !== 'loading') {
  addFootnoteLine();
} else {
  document.addEventListener('DOMContentLoaded', (_event) => addFootnoteLine());
}
