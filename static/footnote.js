// https://github.com/getzola/zola/issues/1070#issuecomment-1166637092

// The DOMContentLoaded event fires when the initial HTML
// document has been completely loaded and parsed, without
// waiting for stylesheets, images, and subframes to finish loading.
document.addEventListener('DOMContentLoaded', (_event) => {
  const references = document.getElementsByClassName('footnote-reference')
  // For each footnote reference, set an id so we can refer to it from the definition.
  // If the definition had an id of 'some_id', then the reference has id `some_id_ref`.
  for (const reference of references) {
    const link = reference.firstChild
    const id = link.getAttribute('href').slice(1) // skip the '#'
    link.setAttribute('id', `${id}_ref`)
  }

  const content = document.getElementsByClassName("post-content")[0];
  const footnotes = document.getElementsByClassName('footnote-definition')
  let saved_footnotes = [];
  // For each footnote-definition, add an anchor element with an href to its corresponding reference.
  // The text used for the added anchor is 'Leftwards Arrow with Hook' (U+21A9).
  for (const footnote of footnotes) {
    const id = footnote.getAttribute('id')
    const backReference = document.createElement('a')
    backReference.setAttribute('href', `#${id}_ref`)
    backReference.textContent = '↩'
    footnote.insertBefore(backReference, footnote.children[1])
    // NOTE: can't move these immediately because `getElementsByClassName` is mutable
    saved_footnotes.push(footnote);
  }

  if (saved_footnotes.length === 0) return;
  let section = document.createElement('section');
  for (const footnote of saved_footnotes) {
    // move the footnote to the end of the post
    section.appendChild(footnote);
  }
  let hr = document.createElement('hr');
  content.appendChild(hr);
  content.appendChild(section);
});
