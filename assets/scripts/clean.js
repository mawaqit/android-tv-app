/// remove specific items from page
function extractContent() {
   const selector = ".header, .footer, .breadcrumb";

   const items = document.querySelectorAll(selector);

   items.forEach((item) => item?.parentElement.removeChild(item));

  return true;
}

function extractDocumentHeight() {
  return document.body.scrollHeight;
}

extractContent();
