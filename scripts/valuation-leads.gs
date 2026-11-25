/**
 * Valuation leads → Google Sheet
 * --------------------------------------------------------------
 * Paste this whole file into the Sheet's Apps Script editor
 * (Extensions → Apps Script), save, then Deploy → New deployment →
 * type "Web app", Execute as "Me", Who has access "Anyone".
 * Copy the Web app URL (ends in /exec) into LEADS_URL in js/main.js.
 *
 * The website sends each valuation-form submission here as JSON.
 * One row is added per lead to the first tab of the Sheet; the header
 * row is created automatically if the tab is empty.
 * (Kept in the repo for reference; scripts/ is not published.)
 */

const HEADERS = ['Received', 'Name', 'Phone', 'Property area', 'Property type', 'Selling timeline', 'Notes', 'Sent from'];

function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const data = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (data.website) return reply('ignored'); // honeypot field: only bots fill it in
    if (!data.name || !data.phone) return reply('missing fields');

    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
    if (sheet.getLastRow() === 0) {
      sheet.appendRow(HEADERS);
      sheet.getRange(1, 1, 1, HEADERS.length).setFontWeight('bold');
      sheet.setFrozenRows(1);
    }
    sheet.appendRow([
      new Date(),
      clean(data.name),
      clean(data.phone, true), // stored as text: keeps the leading 0
      clean(data.area),
      clean(data.type),
      clean(data.when),
      clean(data.message),
      clean(data.source),
    ]);
    return reply('ok');
  } catch (err) {
    return reply('error: ' + err);
  } finally {
    lock.releaseLock();
  }
}

// Trim, cap the length, and stop text being read as a spreadsheet formula
function clean(value, asText) {
  const s = String(value == null ? '' : value).trim().slice(0, 1000);
  return (asText || /^[=+\-@]/.test(s)) ? "'" + s : s;
}

function reply(text) {
  return ContentService.createTextOutput(text).setMimeType(ContentService.MimeType.TEXT);
}
