/**
 * A collection of utility functions for the shader-saver page, meant to make the "real" scripts more declarative.
 * @author Emma Weaver
 * @created 2024-10-22
 */

/**
 * Read a file's contents as a promise.
 * @param {*} file The File to read the contents of.
 * @returns A promise that resolves to the text contents of the given file.
 * @throws When anything goes wrong while reading the file.
 */
function readFile(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (event) => {
            resolve(event.target.result);
        };
        reader.onerror = (event) => {
            reject(event.target.error);
        };
        reader.readAsText(file);
    });
}

/**
 * Listen for changes to an input element on the html page.
 * @param {*} param.elementId The ID of the element to listen for changes to.
 * @param {*} param.onChanges Function to call when the given element is changed.
 */
function listenTo({
    elementId,
    onValue = () => { },
    onClick = () => { },
}) {
    const element = document.getElementById(elementId);
    onValue(element);
    element.addEventListener("change", (event) => onValue(event.target), false);
    element.addEventListener("click", (event) => onClick(event.target), false);
}

/**
 * Sets the preview section's message displayed to the user.
 * @param {*} message The message to display.
 */
function setPreviewMessage(message, color = "blue") {
    const element = document.getElementById("preview_message");
    element.textContent = message;
    element.style.color = color;
}

/**
 * Sets the output section's message displayed to the user.
 * @param {*} message The message to display.
 */
function setOutputMessage(message, color = "blue") {
    const element = document.getElementById("output_message");
    element.textContent = message;
    element.style.color = color;
}
