function run() {
  addFootnoteLine();
  addTimestamps();
  closeDraftPopup();
  expandDetails();
  fixHeaderLink();
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

function closeDraftPopup() {
  const close = document.querySelector('aside.secret > button.close');
  if (!close) return;
  close.onclick = function() {
    close.parentElement.style.display = 'none';
  }
}

function expandDetails() {
  let expanded = false;
  let button = document.getElementById("expandAll");
  if (!button) return;
  let elems = document.querySelectorAll("details.note-content");
  button.onclick = function() {
    if (!expanded) {
      for (let detail of elems) {
        detail.setAttribute("open", "true");
      }
      button.textContent = button.textContent.replace('open', 'close');
      expanded = true;
    } else {
      for (let detail of elems) {
        detail.removeAttribute("open");
      }
      button.textContent = button.textContent.replace('close', 'open');
      expanded = false;
    }
  }
  button.click();
}

function fixHeaderLink() {
  for (const elem of document.querySelectorAll("a.zola-anchor")) {
    elem.innerText = "¶";
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
