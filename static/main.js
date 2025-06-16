function run() {
  addFootnoteLine();
  addTimestamps();
}

function addFootnoteLine() {
  let footer = document.querySelector('footer.footnotes');
  if (footer === null) return;
  let hr = document.createElement('hr');
  footer.before(hr);
}

function addTimestamps() {
  const video = document.querySelector('video');
  if (!video) return;
  for (const elem of document.querySelectorAll(".timestamp")) {
    elem.onclick = function() {
      const stamp = elem.innerText;
      let [min, sec] = stamp.split(':').map(i => parseInt(i));
      sec += min*60;
      console.log(sec);
      video.currentTime = sec;
    };
  }
}

// The DOMContentLoaded event fires when the initial HTML
// document has been completely loaded and parsed, without
// waiting for stylesheets, images, and subframes to finish loading.
if (document.readyState !== 'loading') {
  run()
} else {
  document.addEventListener('DOMContentLoaded', (_event) => run());
}
