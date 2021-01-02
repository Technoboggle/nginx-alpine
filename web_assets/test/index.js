/*
The CSS property is always read as text, exactly as it is in the CSS file. This means you'll have to handle any needed 
conversions and calculations yourself.
Considering you always declare the variables you want to access inside `:root`, this function does the job:
*/

function readCssVar(varName) {
  varName = varName.startsWith("--") ? varName : "--" + varName;
  return window.getComputedStyle(document.documentElement).getPropertyValue(varName);
}

/*
In case you need numbers:
*/

function readCssVarAsNumber(varName) {
  return parseInt(readCssVar(varName), 10);
}

/*
The above won't work with calculated CSS properties, though. Say you have something like:
    --width: calc(var(--height) * 3/4);
The function `readCssVar()` will return `calc(var(--height) * 3/4)`. To have the actual calculated value, use the function below:
*/

function readCalculatedCssVarAsNumber(varName) {
  let div = document.getElementById("readCalculatedCssVarAsNumber");
  if (!div) {
    div = document.createElement("div");
    div.setAttribute("id", "readCalculatedCssVarAsNumber");
    div.setAttribute("position", "absolute");  // detach it from the flow so it doesn't break anything
    document.body.appendChild(div);  // won't work unless you actually append it to the DOM
  }
  div.style.strokeWidth = readCssVar(varName);  // apply it to some innocent property
  return parseInt(getComputedStyle(div).getPropertyValue("stroke-width"), 10);  // read it back!
}

/*
Finally, this is how you *set* a property.
*/
function writeCssVar(varName, value) {
  varName = varName.startsWith("--") ? varName : "--" + varName;
  document.documentElement.style.setProperty(varName, value);
}
