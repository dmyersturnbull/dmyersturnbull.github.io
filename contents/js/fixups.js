
function copyToClipboard(symbol, element) {
  navigator.clipboard.writeText(symbol)
    .then(
      () => {
        // Success: Apply animation to the clicked element
        element.classList.add('copy-animation');
        setTimeout(
          () => { element.classList.remove('copy-animation'); },
          500
        );
      }
    )
    .catch(
      err => { console.error('Failed to copy:', err); }
    );
}
